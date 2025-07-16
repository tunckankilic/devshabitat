import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import '../core/services/error_handler_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

typedef ProgressCallback = void Function(double progress);

class ImageUploadService extends GetxService {
  final FirebaseStorage _storage;
  final ErrorHandlerService _errorHandler;
  final _uuid = const Uuid();

  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int _chunkSize = 1024 * 1024; // 1MB
  static const int _maxDimension = 2048; // Maximum image dimension
  static const int _thumbnailDimension = 300; // Thumbnail dimension
  static const int _defaultQuality = 85; // Default compression quality

  final Map<String, String> _imageCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final int _maxCacheSize = 100; // Maximum number of cached URLs
  final Duration _cacheExpiry = const Duration(hours: 24);

  ImageUploadService({
    FirebaseStorage? storage,
    ErrorHandlerService? errorHandler,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _errorHandler = errorHandler ?? Get.find();

  Future<String?> uploadImage(
    String imagePath, {
    ProgressCallback? onProgress,
    bool shouldCompress = true,
    bool generateThumbnail = true,
    int? customQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Dosya bulunamadı');
      }

      // Cache kontrolü
      final cacheKey = await _generateCacheKey(file);
      if (_imageCache.containsKey(cacheKey) &&
          _cacheTimestamps.containsKey(cacheKey)) {
        final cacheTime = _cacheTimestamps[cacheKey]!;
        if (DateTime.now().difference(cacheTime) < _cacheExpiry) {
          return _imageCache[cacheKey];
        } else {
          _imageCache.remove(cacheKey);
          _cacheTimestamps.remove(cacheKey);
        }
      }

      var fileToUpload = file;
      var fileSize = await file.length();

      // Dosya boyutu kontrolü ve sıkıştırma
      if (fileSize > _maxFileSize || shouldCompress) {
        fileToUpload = await _optimizeImage(
          file,
          quality: customQuality ?? _defaultQuality,
          maxWidth: maxWidth ?? _maxDimension,
          maxHeight: maxHeight ?? _maxDimension,
        );
        fileSize = await fileToUpload.length();

        if (fileSize > _maxFileSize) {
          throw Exception('Sıkıştırmadan sonra bile dosya boyutu çok büyük');
        }
      }

      final ext = path.extension(imagePath).toLowerCase();
      if (!_isValidImageExtension(ext)) {
        throw Exception('Desteklenmeyen dosya formatı');
      }

      final fileName = '${_uuid.v4()}$ext';
      final ref = _storage.ref().child('images/$fileName');

      String? downloadUrl;
      if (fileSize > _chunkSize) {
        await _uploadInChunks(fileToUpload, ref, onProgress);
      } else {
        await _uploadDirect(fileToUpload, ref, onProgress);
      }

      downloadUrl = await ref.getDownloadURL();

      // Thumbnail oluştur
      if (generateThumbnail) {
        final thumbnailFile = await _generateThumbnail(fileToUpload);
        final thumbnailRef = _storage.ref().child('thumbnails/$fileName');
        await _uploadDirect(thumbnailFile, thumbnailRef, null);
        await thumbnailFile.delete();
      }

      // Cache'e ekle
      _addToCache(cacheKey, downloadUrl);

      return downloadUrl;
    } catch (e) {
      _errorHandler.handleError(
          'Resim yükleme hatası: $e', ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  Future<File> _optimizeImage(
    File file, {
    int quality = _defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final bytes = await file.readAsBytes();
    var image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Resim okunamadı');
    }

    // EXIF rotasyonunu düzelt
    image = img.bakeOrientation(image);

    // Boyut kontrolü ve yeniden boyutlandırma
    if (image.width > (maxWidth ?? _maxDimension) ||
        image.height > (maxHeight ?? _maxDimension)) {
      image = img.copyResize(
        image,
        width: image.width > image.height ? (maxWidth ?? _maxDimension) : null,
        height:
            image.height >= image.width ? (maxHeight ?? _maxDimension) : null,
        interpolation: img.Interpolation.linear,
      );
    }

    // WebP formatına dönüştür ve sıkıştır
    final tempDir = await getTemporaryDirectory();
    final optimizedFile = File('${tempDir.path}/${_uuid.v4()}.webp');

    final compressedBytes = await FlutterImageCompress.compressWithList(
      img.encodeJpg(image, quality: quality), // JPG olarak encode et
      quality: quality,
    );

    await optimizedFile.writeAsBytes(compressedBytes);
    return optimizedFile;
  }

  Future<File> _generateThumbnail(File file) async {
    final bytes = await file.readAsBytes();
    var image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Thumbnail oluşturulamadı');
    }

    // EXIF rotasyonunu düzelt
    image = img.bakeOrientation(image);

    // Thumbnail boyutuna ölçekle
    image = img.copyResize(
      image,
      width: _thumbnailDimension,
      height: _thumbnailDimension,
      interpolation: img.Interpolation.linear,
    );

    final tempDir = await getTemporaryDirectory();
    final thumbnailFile = File('${tempDir.path}/${_uuid.v4()}_thumb.jpg');
    await thumbnailFile.writeAsBytes(img.encodeJpg(image, quality: 70));

    return thumbnailFile;
  }

  Future<String> _generateCacheKey(File file) async {
    final bytes = await file.readAsBytes();
    return bytes.length.toString() +
        file.lastModifiedSync().millisecondsSinceEpoch.toString();
  }

  void _addToCache(String key, String url) {
    _cleanExpiredCache();
    if (_imageCache.length >= _maxCacheSize) {
      final oldestKey = _imageCache.keys.first;
      _imageCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
    _imageCache[key] = url;
    _cacheTimestamps[key] = DateTime.now();
  }

  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) > _cacheExpiry)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _imageCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  void clearCache() {
    _imageCache.clear();
    _cacheTimestamps.clear();
  }

  Future<void> _uploadInChunks(
    File file,
    Reference ref,
    ProgressCallback? onProgress,
  ) async {
    final fileSize = await file.length();
    final chunks = (fileSize / _chunkSize).ceil();
    final completeData = Uint8List(fileSize.toInt());
    var offset = 0;

    for (var i = 0; i < chunks; i++) {
      final chunkStream = file.openRead(i * _chunkSize, (i + 1) * _chunkSize);
      final chunkBytes = await chunkStream.toList();
      final chunk = Uint8List.fromList(chunkBytes.expand((x) => x).toList());
      completeData.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;

      if (onProgress != null) {
        onProgress(offset / fileSize);
      }
    }

    await ref.putData(
      completeData,
      SettableMetadata(contentType: _getContentType(path.extension(file.path))),
    );
  }

  Future<void> _uploadDirect(
    File file,
    Reference ref,
    ProgressCallback? onProgress,
  ) async {
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: _getContentType(path.extension(file.path))),
    );

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      if (onProgress != null) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      }
    });

    await uploadTask;
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  bool _isValidImageExtension(String extension) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return validExtensions.contains(extension.toLowerCase());
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      _errorHandler.handleError(
          'Resim silme hatası: $e', ErrorHandlerService.AUTH_ERROR);
    }
  }
}

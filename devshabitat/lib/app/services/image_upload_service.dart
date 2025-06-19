import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import '../core/services/error_handler_service.dart';

typedef ProgressCallback = void Function(double progress);

class ImageUploadService extends GetxService {
  final FirebaseStorage _storage;
  final ErrorHandlerService _errorHandler;
  final _uuid = const Uuid();

  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int _chunkSize = 1024 * 1024; // 1MB
  static const int _maxDimension = 2048; // Maximum image dimension

  ImageUploadService({
    FirebaseStorage? storage,
    ErrorHandlerService? errorHandler,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _errorHandler = errorHandler ?? Get.find();

  Future<String?> uploadImage(
    String imagePath, {
    ProgressCallback? onProgress,
    bool shouldCompress = true,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Dosya bulunamadı');
      }

      var fileToUpload = file;
      var fileSize = await file.length();

      // Dosya boyutu kontrolü ve sıkıştırma
      if (fileSize > _maxFileSize) {
        if (!shouldCompress) {
          throw Exception('Dosya boyutu 10MB\'dan büyük olamaz');
        }
        fileToUpload = await _compressImage(file);
        fileSize = await fileToUpload.length();

        if (fileSize > _maxFileSize) {
          throw Exception('Sıkıştırmadan sonra bile dosya boyutu çok büyük');
        }
      }

      final ext = path.extension(imagePath).toLowerCase();
      if (!_isValidImageExtension(ext)) {
        throw Exception('Desteklenmeyen dosya formatı');
      }

      final ref = _storage.ref().child('images/${_uuid.v4()}$ext');

      if (fileSize > _chunkSize) {
        await _uploadInChunks(fileToUpload, ref, onProgress);
      } else {
        await _uploadDirect(fileToUpload, ref, onProgress);
      }

      return await ref.getDownloadURL();
    } catch (e) {
      _errorHandler.handleError('Resim yükleme hatası: $e');
      return null;
    }
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

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    var image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Resim okunamadı');
    }

    // Boyut kontrolü ve yeniden boyutlandırma
    if (image.width > _maxDimension || image.height > _maxDimension) {
      image = img.copyResize(
        image,
        width: image.width > image.height ? _maxDimension : null,
        height: image.height >= image.width ? _maxDimension : null,
      );
    }

    // Kalite ayarı ile sıkıştırma
    final compressedBytes = img.encodeJpg(image, quality: 85);
    final compressedFile = File('${file.path}_compressed.jpg');
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
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
      _errorHandler.handleError('Resim silme hatası: $e');
    }
  }
}

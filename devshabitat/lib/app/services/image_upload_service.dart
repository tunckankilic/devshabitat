import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../core/services/error_handler_service.dart';

typedef ProgressCallback = void Function(double progress);

class ImageUploadService extends GetxService {
  final FirebaseStorage _storage;
  final ErrorHandlerService _errorHandler;
  final _uuid = const Uuid();

  static const int _chunkSize = 1024 * 1024; // 1MB chunk size
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB max file size

  ImageUploadService({
    FirebaseStorage? storage,
    ErrorHandlerService? errorHandler,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _errorHandler = errorHandler ?? Get.find();

  static const String _baseUrl = 'https://api.devs-habitat.com/v1';
  static const String _uploadEndpoint = '/upload';

  // Resmi sunucuya yükle
  Future<String?> uploadImage(String imagePath,
      {ProgressCallback? onProgress}) async {
    try {
      final file = File(imagePath);
      if (await file.length() > _maxFileSize) {
        throw Exception('Dosya boyutu 10MB\'dan büyük olamaz');
      }

      final ext = path.extension(imagePath);
      final ref = _storage.ref().child('images/${_uuid.v4()}$ext');

      if (await file.length() > _chunkSize) {
        // Büyük dosyalar için chunk upload
        final uploadTask = ref.putData(
          await _createChunkedUpload(file, onProgress),
          SettableMetadata(contentType: _getContentType(ext)),
        );

        await uploadTask;
      } else {
        // Küçük dosyalar için normal upload
        final uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: _getContentType(ext)),
        );

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (onProgress != null) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgress(progress);
          }
        });

        await uploadTask;
      }

      return await ref.getDownloadURL();
    } catch (e) {
      _errorHandler.handleError(e);
      return null;
    }
  }

  // Chunked upload için veri oluştur
  Future<Uint8List> _createChunkedUpload(
      File file, ProgressCallback? onProgress) async {
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

    return completeData;
  }

  // Resmi sıkıştır
  Future<File> compressImage(File imageFile,
      {ProgressCallback? onProgress}) async {
    try {
      final img.Image? image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) throw Exception('Resim okunamadı');

      if (onProgress != null) onProgress(0.3);

      // WebP formatına dönüştür ve sıkıştır
      final compressedBytes = img.encodeJpg(image, quality: 80);

      if (onProgress != null) onProgress(0.6);

      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      if (onProgress != null) onProgress(1.0);

      return tempFile;
    } catch (e) {
      _errorHandler.handleError(e);
      rethrow;
    }
  }

  // Resmi yeniden boyutlandır
  Future<File> resizeImage(File imageFile,
      {ProgressCallback? onProgress}) async {
    try {
      final img.Image? image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) throw Exception('Resim okunamadı');

      if (onProgress != null) onProgress(0.3);

      // Maksimum 1080p boyutuna ölçekle
      img.Image resizedImage = image;
      if (image.width > 1920 || image.height > 1080) {
        resizedImage = img.copyResize(
          image,
          width: image.width > 1920 ? 1920 : null,
          height: image.height > 1080 ? 1080 : null,
        );
      }

      if (onProgress != null) onProgress(0.6);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 80));

      if (onProgress != null) onProgress(1.0);

      return tempFile;
    } catch (e) {
      _errorHandler.handleError(e);
      rethrow;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      _errorHandler.handleError(e);
    }
  }

  // Dosya uzantısına göre content type belirle
  String _getContentType(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
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
}

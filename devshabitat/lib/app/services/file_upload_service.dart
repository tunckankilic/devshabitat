import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../core/services/error_handler_service.dart';
import '../core/config/app_config.dart';

class FileUploadService extends GetxService {
  static FileUploadService get to => Get.find();

  final ErrorHandlerService _errorHandler = Get.find();
  final AppConfig _config = Get.find();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String?> uploadFile(
    File file,
    String directory, {
    String? customFileName,
    Map<String, String>? metadata,
  }) async {
    try {
      // Dosya validasyonu
      final fileName = path.basename(file.path);
      final fileSize = await file.length();

      final validationError = _errorHandler.validateFile(fileName, fileSize);
      if (validationError != null) {
        await _errorHandler.handleError(
          validationError,
          ErrorHandlerService.VALIDATION_ERROR,
        );
        return null;
      }

      // MIME type kontrolü
      final mimeType = lookupMimeType(file.path);
      if (mimeType == null || !_isAllowedMimeType(mimeType)) {
        await _errorHandler.handleError(
          'Geçersiz dosya türü',
          ErrorHandlerService.VALIDATION_ERROR,
        );
        return null;
      }

      // Güvenli dosya adı oluştur
      final safeFileName = customFileName ?? _generateSafeFileName(fileName);
      final storagePath = '$directory/$safeFileName';

      // Metadata hazırla
      final uploadMetadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalName': fileName,
          if (metadata != null) ...metadata,
        },
      );

      // Dosyayı yükle
      final ref = _storage.ref(storagePath);
      await ref.putFile(file, uploadMetadata);

      // Download URL döndür
      return await ref.getDownloadURL();
    } catch (e, stackTrace) {
      await _errorHandler.handleError(
        e,
        ErrorHandlerService.FILE_ERROR,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  String _generateSafeFileName(String originalName) {
    final extension = path.extension(originalName);
    final uniqueId = _uuid.v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$timestamp-$uniqueId$extension'.toLowerCase();
  }

  bool _isAllowedMimeType(String mimeType) {
    final allowedTypes = [
      'image/jpeg',
      'image/png',
      'application/pdf',
    ];
    return allowedTypes.contains(mimeType);
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e, stackTrace) {
      await _errorHandler.handleError(
        e,
        ErrorHandlerService.FILE_ERROR,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, dynamic>?> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      final metadata = await ref.getMetadata();
      return metadata.customMetadata;
    } catch (e, stackTrace) {
      await _errorHandler.handleError(
        e,
        ErrorHandlerService.FILE_ERROR,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}

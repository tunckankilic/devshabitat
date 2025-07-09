import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logger/logger.dart';
import '../core/services/error_handler_service.dart';
import '../core/config/security_config.dart';
import '../core/error/error_handler.dart';

class FileUploadService extends GetxService {
  static FileUploadService get to => Get.find();

  final ErrorHandlerService _errorHandler = Get.find();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();
  final Logger _logger = Logger();

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

  // Dosya yükleme
  Future<String> uploadSecureFile({
    required File file,
    required String folder,
    List<String>? allowedTypes,
    int? maxSizeMB,
    bool compressImage = true,
  }) async {
    try {
      // Dosya güvenlik kontrolü
      await _validateFile(file, allowedTypes, maxSizeMB);

      // Güvenli dosya adı oluştur
      final fileName = _generateSecureFileName(file.path);
      final fileExtension = path.extension(file.path).toLowerCase();

      // Resim sıkıştırma
      File fileToUpload = file;
      if (compressImage && _isImageFile(fileExtension)) {
        fileToUpload = await _compressImage(file);
      }

      // Dosya yükleme yolu
      final storagePath = '$folder/$fileName$fileExtension';
      final storageRef = _storage.ref().child(storagePath);

      // Metadata oluştur
      final metadata = SettableMetadata(
        contentType: lookupMimeType(file.path),
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalName': path.basename(file.path),
          'fileSize': fileToUpload.lengthSync().toString(),
        },
      );

      // Dosyayı yükle
      await storageRef.putFile(fileToUpload, metadata);

      // Download URL al
      final downloadUrl = await storageRef.getDownloadURL();

      _logger.i('File uploaded successfully: $storagePath');
      return downloadUrl;
    } catch (e) {
      _logger.e('Error uploading file: $e');
      rethrow;
    }
  }

  // Dosya güvenlik kontrolü
  Future<void> _validateFile(
    File file,
    List<String>? allowedTypes,
    int? maxSizeMB,
  ) async {
    final fileName = path.basename(file.path);
    final fileExtension =
        path.extension(file.path).toLowerCase().replaceAll('.', '');
    final fileSizeInBytes = await file.length();

    // Dosya güvenlik kontrolü
    if (!SecurityConfig.isFileSecure(
      fileName: fileName,
      fileType: fileExtension,
      fileSizeInBytes: fileSizeInBytes,
      allowedTypes: allowedTypes,
    )) {
      ErrorHandler.throwError(
        'Geçersiz dosya formatı veya boyutu',
        code: 'INVALID_FILE',
      );
    }

    // Özel boyut kontrolü
    if (maxSizeMB != null) {
      final fileSizeMB = fileSizeInBytes / (1024 * 1024);
      if (fileSizeMB > maxSizeMB) {
        ErrorHandler.throwError(
          'Dosya boyutu en fazla $maxSizeMB MB olmalıdır',
          code: 'FILE_TOO_LARGE',
        );
      }
    }

    // Mime type kontrolü
    final mimeType = lookupMimeType(file.path);
    if (mimeType == null) {
      ErrorHandler.throwError(
        'Dosya tipi belirlenemedi',
        code: 'UNKNOWN_FILE_TYPE',
      );
    }

    // Zararlı dosya kontrolü
    if (_isPotentiallyDangerousFile(fileExtension, mimeType)) {
      ErrorHandler.throwError(
        'Güvenlik nedeniyle bu dosya tipi kabul edilmemektedir',
        code: 'DANGEROUS_FILE_TYPE',
      );
    }
  }

  // Güvenli dosya adı oluştur
  String _generateSecureFileName(String originalPath) {
    final originalName = path.basenameWithoutExtension(originalPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomString = _generateRandomString(8);

    // Dosya adını güvenli hale getir
    final safeName = originalName
        .replaceAll(
            RegExp(r'[^a-zA-Z0-9]'), '_') // Sadece alfanumerik ve alt çizgi
        .toLowerCase()
        .substring(0, originalName.length > 32 ? 32 : originalName.length);

    return '${safeName}_${timestamp}_$randomString';
  }

  // Güvenli rastgele string oluştur
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Resim sıkıştırma
  Future<File> _compressImage(File file) async {
    final fileExtension = path.extension(file.path).toLowerCase();
    if (!_isImageFile(fileExtension)) return file;

    try {
      final dir = path.dirname(file.path);
      final fileName = path.basenameWithoutExtension(file.path);
      final targetPath = path.join(dir, '${fileName}_compressed$fileExtension');

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        keepExif: false,
      );

      return result != null ? File(result.path) : file;
    } catch (e) {
      _logger.w('Image compression failed: $e');
      return file;
    }
  }

  // Resim dosyası kontrolü
  bool _isImageFile(String extension) {
    return SecurityConfig.ALLOWED_IMAGE_TYPES.contains(
      extension.toLowerCase().replaceAll('.', ''),
    );
  }

  // Zararlı dosya kontrolü
  bool _isPotentiallyDangerousFile(String extension, String mimeType) {
    // Tehlikeli uzantılar
    final dangerousExtensions = [
      'exe',
      'dll',
      'so',
      'sh',
      'bat',
      'cmd',
      'ps1',
      'vbs',
      'js',
      'php',
      'py',
      'rb',
      'pl',
      'jar',
      'app',
    ];

    // Tehlikeli mime tipleri
    final dangerousMimeTypes = [
      'application/x-msdownload',
      'application/x-executable',
      'application/x-dosexec',
      'application/x-msdos-program',
      'application/x-python-code',
      'application/x-ruby',
      'application/x-perl',
      'application/java-archive',
    ];

    return dangerousExtensions.contains(extension.toLowerCase()) ||
        dangerousMimeTypes.contains(mimeType.toLowerCase());
  }

  // Toplu dosya yükleme
  Future<List<String>> uploadMultipleFiles({
    required List<File> files,
    required String folder,
    List<String>? allowedTypes,
    int? maxSizeMB,
    bool compressImages = true,
  }) async {
    final uploadedUrls = <String>[];

    for (var file in files) {
      try {
        final url = await uploadSecureFile(
          file: file,
          folder: folder,
          allowedTypes: allowedTypes,
          maxSizeMB: maxSizeMB,
          compressImage: compressImages,
        );
        uploadedUrls.add(url);
      } catch (e) {
        // Hata durumunda yüklenmiş dosyaları temizle
        for (var url in uploadedUrls) {
          await deleteFile(url).catchError((_) {});
        }
        rethrow;
      }
    }

    return uploadedUrls;
  }

  // Dosya metadata güncelleme
  Future<void> updateFileMetadata({
    required String fileUrl,
    required Map<String, String> metadata,
  }) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      final newMetadata = SettableMetadata(
        customMetadata: metadata,
      );
      await ref.updateMetadata(newMetadata);
      _logger.i('File metadata updated successfully: $fileUrl');
    } catch (e) {
      _logger.e('Error updating file metadata: $e');
      rethrow;
    }
  }
}

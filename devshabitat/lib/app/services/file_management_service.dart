import 'dart:io';

import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img;
import '../core/services/error_handler_service.dart';

enum AppFileType { image, document, audio, video, other }

class FileManagementService extends GetxService {
  static FileManagementService get to => Get.find();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final Logger _logger = Logger();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();

  // Upload progress tracking
  final RxMap<String, double> uploadProgress = <String, double>{}.obs;
  final RxBool isUploading = false.obs;

  // File size limits (MB)
  static const int maxImageSize = 10;
  static const int maxDocumentSize = 50;
  static const int maxAudioSize = 100;
  static const int maxVideoSize = 500;

  // Supported formats
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];
  static const List<String> supportedDocumentFormats = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'xls',
    'xlsx',
  ];
  static const List<String> supportedAudioFormats = [
    'mp3',
    'wav',
    'aac',
    'ogg',
  ];
  static const List<String> supportedVideoFormats = [
    'mp4',
    'avi',
    'mov',
    'mkv',
  ];

  // Image picker methods
  Future<File?> pickImageFromCamera({int quality = 80}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: quality,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      _logger.e('Kameradan resim seçme hatası: $e');
      _errorHandler.handleError(
        'Kameradan resim seçilemedi: $e',
        'IMAGE_PICK_ERROR',
      );
      return null;
    }
  }

  Future<File?> pickImageFromGallery({int quality = 80}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      _logger.e('Galeriden resim seçme hatası: $e');
      _errorHandler.handleError(
        'Galeriden resim seçilemedi: $e',
        'IMAGE_PICK_ERROR',
      );
      return null;
    }
  }

  Future<List<File>> pickMultipleImages({int quality = 80}) async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: quality,
      );
      return pickedFiles.map((file) => File(file.path)).toList();
    } catch (e) {
      _logger.e('Çoklu resim seçme hatası: $e');
      _errorHandler.handleError(
        'Resimler seçilemedi: $e',
        'MULTIPLE_IMAGE_PICK_ERROR',
      );
      return [];
    }
  }

  // File picker methods
  Future<File?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedDocumentFormats,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // File size check
        final sizeInMB = await file.length() / (1024 * 1024);
        if (sizeInMB > maxDocumentSize) {
          throw Exception(
            'Dosya boyutu ${maxDocumentSize}MB\'dan büyük olamaz',
          );
        }

        return file;
      }
      return null;
    } catch (e) {
      _logger.e('Doküman seçme hatası: $e');
      _errorHandler.handleError(
        'Doküman seçilemedi: $e',
        'DOCUMENT_PICK_ERROR',
      );
      return null;
    }
  }

  Future<File?> pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedAudioFormats,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // File size check
        final sizeInMB = await file.length() / (1024 * 1024);
        if (sizeInMB > maxAudioSize) {
          throw Exception(
            'Ses dosyası boyutu ${maxAudioSize}MB\'dan büyük olamaz',
          );
        }

        return file;
      }
      return null;
    } catch (e) {
      _logger.e('Ses dosyası seçme hatası: $e');
      _errorHandler.handleError(
        'Ses dosyası seçilemedi: $e',
        'AUDIO_PICK_ERROR',
      );
      return null;
    }
  }

  Future<File?> pickVideoFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedVideoFormats,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // File size check
        final sizeInMB = await file.length() / (1024 * 1024);
        if (sizeInMB > maxVideoSize) {
          throw Exception(
            'Video dosyası boyutu ${maxVideoSize}MB\'dan büyük olamaz',
          );
        }

        return file;
      }
      return null;
    } catch (e) {
      _logger.e('Video dosyası seçme hatası: $e');
      _errorHandler.handleError(
        'Video dosyası seçilemedi: $e',
        'VIDEO_PICK_ERROR',
      );
      return null;
    }
  }

  // Upload methods
  Future<String?> uploadImage(
    File imageFile,
    String folder, {
    String? fileName,
    bool optimize = true,
  }) async {
    try {
      isUploading.value = true;

      File fileToUpload = imageFile;

      // Optimize image if requested
      if (optimize) {
        fileToUpload = await _optimizeImage(imageFile) ?? imageFile;
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last;
      final uploadFileName = fileName ?? 'image_$timestamp.$extension';

      // Upload to Firebase Storage
      final ref = _storage.ref().child('$folder/$uploadFileName');
      final uploadTask = ref.putFile(fileToUpload);

      // Track progress
      final taskId = uploadFileName;
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        uploadProgress[taskId] = progress;
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      uploadProgress.remove(taskId);
      isUploading.value = false;

      _logger.i('Resim başarıyla yüklendi: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      isUploading.value = false;
      _logger.e('Resim yükleme hatası: $e');
      _errorHandler.handleError('Resim yüklenemedi: $e', 'IMAGE_UPLOAD_ERROR');
      return null;
    }
  }

  Future<String?> uploadFile(
    File file,
    String folder,
    AppFileType fileType, {
    String? fileName,
  }) async {
    try {
      isUploading.value = true;

      // File size validation
      final sizeInMB = await file.length() / (1024 * 1024);
      final maxSize = _getMaxSizeForFileType(fileType);
      if (sizeInMB > maxSize) {
        throw Exception('Dosya boyutu ${maxSize}MB\'dan büyük olamaz');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final uploadFileName =
          fileName ?? '${fileType.name}_$timestamp.$extension';

      // Upload to Firebase Storage
      final ref = _storage.ref().child('$folder/$uploadFileName');
      final uploadTask = ref.putFile(file);

      // Track progress
      final taskId = uploadFileName;
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        uploadProgress[taskId] = progress;
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      uploadProgress.remove(taskId);
      isUploading.value = false;

      _logger.i('Dosya başarıyla yüklendi: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      isUploading.value = false;
      _logger.e('Dosya yükleme hatası: $e');
      _errorHandler.handleError('Dosya yüklenemedi: $e', 'FILE_UPLOAD_ERROR');
      return null;
    }
  }

  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
    String folder, {
    bool optimize = true,
  }) async {
    final downloadUrls = <String>[];

    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      final fileName =
          'image_${DateTime.now().millisecondsSinceEpoch}_$i.${file.path.split('.').last}';

      final url = await uploadImage(
        file,
        folder,
        fileName: fileName,
        optimize: optimize,
      );
      if (url != null) {
        downloadUrls.add(url);
      }
    }

    return downloadUrls;
  }

  // Image optimization
  Future<File?> _optimizeImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      // Resize if too large
      img.Image resizedImage = image;
      if (image.width > 1920 || image.height > 1920) {
        resizedImage = img.copyResize(
          image,
          width: 1920,
          height: 1920,
          maintainAspect: true,
        );
      }

      // Compress
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);

      // Save optimized image
      final optimizedFile = File('${imageFile.path}_optimized.jpg');
      await optimizedFile.writeAsBytes(compressedBytes);

      return optimizedFile;
    } catch (e) {
      _logger.e('Resim optimizasyon hatası: $e');
      return null;
    }
  }

  // File deletion
  Future<bool> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      _logger.i('Dosya silindi: $downloadUrl');
      return true;
    } catch (e) {
      _logger.e('Dosya silme hatası: $e');
      _errorHandler.handleError('Dosya silinemedi: $e', 'FILE_DELETE_ERROR');
      return false;
    }
  }

  // Cache management
  Future<void> clearCache() async {
    try {
      // Clear temporary files
      final tempDir = Directory.systemTemp;
      final tempFiles = tempDir
          .listSync()
          .where(
            (file) =>
                file.path.contains('image_picker') ||
                file.path.contains('file_picker') ||
                file.path.contains('_optimized'),
          )
          .toList();

      for (final file in tempFiles) {
        try {
          await file.delete();
        } catch (e) {
          // Ignore individual file deletion errors
        }
      }

      _logger.i('Cache temizlendi');
    } catch (e) {
      _logger.e('Cache temizleme hatası: $e');
    }
  }

  // Helper methods
  int _getMaxSizeForFileType(AppFileType fileType) {
    switch (fileType) {
      case AppFileType.image:
        return maxImageSize;
      case AppFileType.document:
        return maxDocumentSize;
      case AppFileType.audio:
        return maxAudioSize;
      case AppFileType.video:
        return maxVideoSize;
      default:
        return maxDocumentSize;
    }
  }

  AppFileType getFileTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();

    if (supportedImageFormats.contains(ext)) return AppFileType.image;
    if (supportedDocumentFormats.contains(ext)) return AppFileType.document;
    if (supportedAudioFormats.contains(ext)) return AppFileType.audio;
    if (supportedVideoFormats.contains(ext)) return AppFileType.video;

    return AppFileType.other;
  }

  String getFileIcon(String extension) {
    final fileType = getFileTypeFromExtension(extension);

    switch (fileType) {
      case AppFileType.image:
        return '🖼️';
      case AppFileType.document:
        return '📄';
      case AppFileType.audio:
        return '🎵';
      case AppFileType.video:
        return '🎥';
      default:
        return '📁';
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool isFileTypeSupported(String extension) {
    return getFileTypeFromExtension(extension) != AppFileType.other;
  }
}

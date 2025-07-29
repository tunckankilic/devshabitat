import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FileStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Dosya yükleme
  Future<UploadTask> uploadFile({
    required File file,
    required String userId,
    required String conversationId,
    required String messageId,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = fileName.split('.').last;
      final storagePath =
          'uploads/$userId/$conversationId/$messageId/$timestamp.$fileExtension';

      final ref = _storage.ref().child(storagePath);
      return ref.putFile(file);
    } catch (e) {
      throw 'Dosya yüklenirken bir hata oluştu: $e';
    }
  }

  // Dosya URL'sini al
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Dosya URL\'si alınırken bir hata oluştu: $e';
    }
  }

  // Dosya sil
  Future<void> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (e) {
      throw 'Dosya silinirken bir hata oluştu: $e';
    }
  }

  // Dosya boyutunu kontrol et
  bool isValidFileSize(File file, {int maxSizeInMB = 10}) {
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return fileSizeInMB <= maxSizeInMB;
  }

  // Dosya türünü kontrol et
  bool isValidFileType(String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  // Dosya türüne göre MIME type al
  String getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'avi':
        return 'video/x-msvideo';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }

  // Dosya boyutunu formatla
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

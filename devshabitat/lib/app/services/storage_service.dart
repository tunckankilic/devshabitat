import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Get.find<Logger>();

  Future<String?> uploadProfileImage(String userId, String localPath) async {
    try {
      _logger.i('Starting profile image upload for user: $userId');

      final file = File(localPath);
      if (!await file.exists()) {
        _logger.e('File does not exist: $localPath');
        throw Exception('Dosya bulunamadı');
      }

      final ext = path.extension(localPath);
      final fileName = 'profile$ext'; // Sabit bir dosya adı kullan
      final ref = _storage.ref().child('profile_images/$userId/$fileName');

      _logger.d('Uploading file to: ${ref.fullPath}');

      final metadata = SettableMetadata(
        contentType: 'image/${ext.replaceAll('.', '')}',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = await ref.putFile(file, metadata);

      if (uploadTask.state == TaskState.success) {
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        _logger.i('Profile image upload successful. URL: $downloadUrl');
        return downloadUrl;
      } else {
        _logger.e('Upload failed with state: ${uploadTask.state}');
        throw Exception('Yükleme başarısız oldu');
      }
    } catch (e) {
      _logger.e('Error uploading profile image: $e');
      throw Exception('Profil fotoğrafı yüklenirken bir hata oluştu: $e');
    }
  }

  Future<String?> uploadCommunityImage(String localPath, String folder) async {
    try {
      final file = File(localPath);
      final ext = path.extension(localPath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
      final ref = _storage.ref().child('$folder/$fileName');

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Topluluk görseli yüklenirken bir hata oluştu: $e');
    }
  }

  Future<String?> uploadEventImage(String eventId, String localPath) async {
    try {
      final file = File(localPath);
      final ext = path.extension(localPath);
      final ref = _storage.ref().child('event_images/$eventId$ext');

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Etkinlik görseli yüklenirken bir hata oluştu: $e');
    }
  }

  Future<String?> uploadAttachment(String chatId, String localPath) async {
    try {
      final file = File(localPath);
      final ext = path.extension(localPath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
      final ref = _storage.ref().child('attachments/$chatId/$fileName');

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Dosya yüklenirken bir hata oluştu: $e');
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Dosya silinirken bir hata oluştu: $e');
    }
  }
}

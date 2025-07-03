import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfileImage(String userId, String localPath) async {
    try {
      final file = File(localPath);
      final ext = path.extension(localPath);
      final ref = _storage.ref().child('profile_images/$userId$ext');

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
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

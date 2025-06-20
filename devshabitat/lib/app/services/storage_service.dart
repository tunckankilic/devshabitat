import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfileImage(String userId, String filePath) async {
    try {
      // Dosya boyutunu optimize et
      final File file = File(filePath);
      final img.Image? image = img.decodeImage(file.readAsBytesSync());

      if (image == null) return null;

      // Resmi yeniden boyutlandır (max 800x800)
      final img.Image resizedImage = img.copyResize(
        image,
        width: image.width > 800 ? 800 : image.width,
        height: image.height > 800 ? 800 : image.height,
      );

      // Optimize edilmiş resmi geçici bir dosyaya kaydet
      final String tempPath = path.join(
        path.dirname(filePath),
        'optimized_${path.basename(filePath)}',
      );
      File(tempPath).writeAsBytesSync(img.encodeJpg(resizedImage, quality: 80));

      // Storage referansını oluştur
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath)}';
      final Reference ref =
          _storage.ref().child('users/$userId/profile/$fileName');

      // Dosyayı yükle
      final UploadTask uploadTask = ref.putFile(
        File(tempPath),
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Yükleme tamamlandığında URL'i al
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Geçici dosyayı sil
      await File(tempPath).delete();

      // Eski profil fotoğrafını sil
      await _deleteOldProfileImages(userId, fileName);

      return downloadUrl;
    } catch (e) {
      print('Profil fotoğrafı yüklenirken hata: $e');
      return null;
    }
  }

  Future<void> _deleteOldProfileImages(
      String userId, String exceptFileName) async {
    try {
      final ListResult result =
          await _storage.ref().child('users/$userId/profile').listAll();

      for (var item in result.items) {
        if (path.basename(item.fullPath) != exceptFileName) {
          await item.delete();
        }
      }
    } catch (e) {
      print('Eski profil fotoğrafları silinirken hata: $e');
    }
  }

  Future<void> deleteAllUserImages(String userId) async {
    try {
      final Reference userRef = _storage.ref().child('users/$userId');
      final ListResult result = await userRef.listAll();

      for (var item in result.items) {
        await item.delete();
      }

      for (var prefix in result.prefixes) {
        final ListResult subResult = await prefix.listAll();
        for (var item in subResult.items) {
          await item.delete();
        }
      }
    } catch (e) {
      print('Kullanıcı fotoğrafları silinirken hata: $e');
    }
  }
}

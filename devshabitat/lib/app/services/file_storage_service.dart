import 'dart:io';
import 'dart:math' show pow;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class FileStorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final RxDouble uploadProgress = 0.0.obs;
  final RxBool isUploading = false.obs;
  final Map<String, UploadTask> _uploadTasks = {};
  final Map<String, int> _retryAttempts = {};
  final int maxRetries = 3;
  final int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  final List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  final List<String> allowedFileExtensions = ['pdf', 'txt'];

  // Dosya yükleme işlemi
  Future<UploadTask> uploadFile({
    required File file,
    required String userId,
    required String conversationId,
    required String messageId,
  }) async {
    if (!_validateFileSize(file)) {
      throw Exception('Dosya boyutu 10MB\'dan büyük olamaz');
    }

    final fileName = file.path.split('/').last;
    final ref = _storage.ref().child('messages/$userId/$messageId/$fileName');
    return ref.putFile(file);
  }

  // Resim yükleme işlemi
  Future<UploadTask?> uploadImage({
    required String userId,
    required String conversationId,
    required String messageId,
    required File imageFile,
  }) async {
    final compressedImage = await _compressImage(imageFile);
    return await uploadFile(
      userId: userId,
      conversationId: conversationId,
      messageId: messageId,
      file: compressedImage,
    );
  }

  // İndirme URL'sini al
  Future<String?> getDownloadURL(String storagePath) async {
    try {
      final ref = _storage.ref(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('URL alma hatası: $e');
      return null;
    }
  }

  // Dosya silme işlemi
  Future<bool> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref(storagePath);
      await ref.delete();
      return true;
    } catch (e) {
      print('Dosya silme hatası: $e');
      return false;
    }
  }

  // Dosya boyutu kontrolü
  bool _validateFileSize(File file) {
    return file.lengthSync() <= maxFileSizeBytes;
  }

  // Resim sıkıştırma
  Future<File> _compressImage(File imageFile) async {
    final img.Image? image = img.decodeImage(await imageFile.readAsBytes());
    if (image == null) throw Exception('Resim okunamadı');

    // Maksimum 1080p boyutuna ölçekle
    img.Image resizedImage = image;
    if (image.width > 1920 || image.height > 1080) {
      resizedImage = img.copyResize(
        image,
        width: image.width > 1920 ? 1920 : null,
        height: image.height > 1080 ? 1080 : null,
      );
    }

    // WebP formatına dönüştür ve sıkıştır
    final compressedBytes = img.encodeJpg(
      resizedImage,
      quality: 80,
    );

    // Geçici dosya oluştur
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressedBytes);

    return tempFile;
  }

  // Firebase Storage'a yükleme
  Future<UploadTask> _uploadFileToStorage(File file, String storagePath) async {
    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;

      final ref = _storage.ref(storagePath);
      final UploadTask uploadTask = ref.putFile(file);
      _uploadTasks[storagePath] = uploadTask;
      _retryAttempts[storagePath] = 0;

      // İlerleme takibi
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          uploadProgress.value =
              snapshot.bytesTransferred / snapshot.totalBytes;
        },
        onError: (error) => _handleUploadError(storagePath, file),
        cancelOnError: true,
      );

      return uploadTask;
    } catch (e) {
      return await _handleUploadError(storagePath, file);
    }
  }

  // Yükleme hatası yönetimi
  Future<UploadTask> _handleUploadError(String storagePath, File file) async {
    final attempts = _retryAttempts[storagePath] ?? 0;
    if (attempts < maxRetries) {
      _retryAttempts[storagePath] = attempts + 1;
      await Future.delayed(Duration(seconds: pow(2, attempts).toInt()));
      return _uploadFileToStorage(file, storagePath);
    } else {
      isUploading.value = false;
      uploadProgress.value = 0.0;
      _uploadTasks.remove(storagePath);
      _retryAttempts.remove(storagePath);
      throw Exception('Yükleme hatası');
    }
  }

  // Servis kapatıldığında
  @override
  void onClose() {
    for (var task in _uploadTasks.values) {
      task.cancel();
    }
    _uploadTasks.clear();
    _retryAttempts.clear();
    super.onClose();
  }
}

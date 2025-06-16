import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/file_storage_service.dart';
import '../models/message_model.dart';

class FileUploadController extends GetxController {
  final FileStorageService _storageService = Get.find<FileStorageService>();
  final RxList<UploadTask> activeUploads = <UploadTask>[].obs;
  final RxMap<String, double> uploadProgress = <String, double>{}.obs;
  final RxBool isUploading = false.obs;
  final RxList<Map<String, dynamic>> uploadQueue = <Map<String, dynamic>>[].obs;

  // Dosya seçimi için ImagePicker ve FilePicker instance'ları
  final ImagePicker _imagePicker = ImagePicker();

  // Resim seçme metodu
  Future<File?> selectImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Resim seçilirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Dosya seçme metodu
  Future<File?> selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return File(result.files.first.path!);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Dosya seçilirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // İlerleme durumu ile dosya yükleme
  Future<AttachmentData?> uploadWithProgress(
    File file,
    String userId,
    String messageId,
  ) async {
    try {
      isUploading.value = true;
      final String fileName = file.path.split('/').last;
      final String fileExtension = fileName.split('.').last.toLowerCase();

      // Dosya türünü belirle
      AttachmentType attachmentType = _determineAttachmentType(fileExtension);

      // Yükleme görevi oluştur
      final UploadTask uploadTask = await _storageService.uploadFile(
        file: file,
        userId: userId,
        conversationId: messageId,
        messageId: messageId,
      );

      // Aktif yüklemelere ekle
      activeUploads.add(uploadTask);

      // İlerleme durumunu takip et
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          uploadProgress[messageId] = progress;
        },
        onError: (error) {
          Get.snackbar(
            'Hata',
            'Dosya yüklenirken bir hata oluştu: $error',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );

      // Yükleme tamamlanana kadar bekle
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Yükleme tamamlandığında aktif listeden kaldır
      activeUploads.remove(uploadTask);
      uploadProgress.remove(messageId);

      return AttachmentData(
        type: attachmentType,
        url: downloadUrl,
        name: fileName,
        size: await file.length(),
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Dosya yüklenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  // Yükleme işlemini iptal et
  void cancelUpload(String messageId) {
    final upload = activeUploads.firstWhereOrNull(
      (task) => task.snapshot.ref.fullPath.contains(messageId),
    );

    if (upload != null) {
      upload.cancel();
      activeUploads.remove(upload);
      uploadProgress.remove(messageId);
    }
  }

  // Çevrimdışı kuyruğa ekle
  void addToQueue(Map<String, dynamic> uploadData) {
    uploadQueue.add(uploadData);
  }

  // Kuyruktaki yüklemeleri işle
  Future<void> processQueue() async {
    if (uploadQueue.isEmpty) return;

    for (var uploadData in uploadQueue) {
      if (await _checkConnectivity()) {
        final File file = File(uploadData['filePath']);
        if (await file.exists()) {
          await uploadWithProgress(
            file,
            uploadData['userId'],
            uploadData['messageId'],
          );
        }
        uploadQueue.remove(uploadData);
      } else {
        break; // Bağlantı yoksa işlemi durdur
      }
    }
  }

  // Bağlantı kontrolü
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Dosya türünü belirle
  AttachmentType _determineAttachmentType(String extension) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv'];
    final audioExtensions = ['mp3', 'wav', 'ogg', 'm4a'];

    if (imageExtensions.contains(extension)) {
      return AttachmentType.image;
    } else if (videoExtensions.contains(extension)) {
      return AttachmentType.video;
    } else if (audioExtensions.contains(extension)) {
      return AttachmentType.audio;
    }
    return AttachmentType.file;
  }

  @override
  void onInit() {
    super.onInit();
    // Çevrimdışı kuyruğu periyodik olarak kontrol et
    ever(uploadQueue, (_) => processQueue());
  }

  @override
  void onClose() {
    // Aktif yüklemeleri iptal et
    for (var upload in activeUploads) {
      upload.cancel();
    }
    activeUploads.clear();
    uploadProgress.clear();
    super.onClose();
  }
}

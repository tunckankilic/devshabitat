import 'dart:io';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadController extends GetxController {
  final _imagePicker = ImagePicker();
  final Rx<File?> _selectedImage = Rx<File?>(null);
  final RxBool _isUploading = false.obs;
  final RxString _error = ''.obs;
  final RxDouble _uploadProgress = 0.0.obs;

  // Getters
  File? get selectedImage => _selectedImage.value;
  bool get isUploading => _isUploading.value;
  String get error => _error.value;
  double get uploadProgress => _uploadProgress.value;

  // Galeriden resim seçme
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _cropImage(image.path);
      }
    } catch (e) {
      _error.value = 'Resim seçilirken bir hata oluştu: $e';
    }
  }

  // Kameradan resim çekme
  Future<void> takeImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        await _cropImage(image.path);
      }
    } catch (e) {
      _error.value = 'Fotoğraf çekilirken bir hata oluştu: $e';
    }
  }

  // Resmi kırpma
  Future<void> _cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 80,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (croppedFile != null) {
        _selectedImage.value = File(croppedFile.path);
      }
    } catch (e) {
      _error.value = 'Resim kırpılırken bir hata oluştu: $e';
    }
  }

  // Resmi yükleme
  Future<String?> uploadImage() async {
    if (_selectedImage.value == null) {
      _error.value = 'Lütfen bir resim seçin';
      return null;
    }

    try {
      _isUploading.value = true;
      _error.value = '';
      _uploadProgress.value = 0.0;

      // TODO: Resmi sunucuya yükle
      // Örnek yükleme simülasyonu:
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        _uploadProgress.value = i / 100;
      }

      // TODO: Sunucudan dönen URL'i al
      final String imageUrl = 'https://example.com/profile/image.jpg';

      Get.snackbar(
        'Başarılı',
        'Profil resmi başarıyla yüklendi',
        snackPosition: SnackPosition.BOTTOM,
      );

      return imageUrl;
    } catch (e) {
      _error.value = 'Resim yüklenirken bir hata oluştu: $e';
      return null;
    } finally {
      _isUploading.value = false;
      _uploadProgress.value = 0.0;
    }
  }

  // Seçili resmi temizleme
  void clearSelectedImage() {
    _selectedImage.value = null;
    _error.value = '';
  }
}

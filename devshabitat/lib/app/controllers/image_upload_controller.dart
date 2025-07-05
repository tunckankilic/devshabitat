import 'dart:io';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_upload_service.dart';
import '../core/services/error_handler_service.dart';

class ImageUploadController extends GetxController {
  final _imagePicker = ImagePicker();
  final _imageUploadService = Get.find<ImageUploadService>();
  final _errorHandler = Get.find<ErrorHandlerService>();
  final Rx<File?> _selectedImage = Rx<File?>(null);
  final RxBool _isUploading = false.obs;
  final RxString _error = ''.obs;
  final RxDouble _uploadProgress = 0.0.obs;
  final RxBool _isCompressing = false.obs;

  // Getters
  File? get selectedImage => _selectedImage.value;
  bool get isUploading => _isUploading.value;
  String get error => _error.value;
  double get uploadProgress => _uploadProgress.value;
  bool get isCompressing => _isCompressing.value;

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
      _errorHandler.handleError('Resim seçilirken bir hata oluştu: $e',
          ErrorHandlerService.FILE_ERROR);
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
      _errorHandler.handleError('Fotoğraf çekilirken bir hata oluştu: $e',
          ErrorHandlerService.FILE_ERROR);
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
        _isCompressing.value = true;
        _selectedImage.value = File(croppedFile.path);
        _isCompressing.value = false;
      }
    } catch (e) {
      _errorHandler.handleError('Resim kırpılırken bir hata oluştu: $e',
          ErrorHandlerService.FILE_ERROR);
      _error.value = 'Resim kırpılırken bir hata oluştu: $e';
      _isCompressing.value = false;
    }
  }

  // Resmi yükleme
  Future<String?> uploadImage() async {
    if (_selectedImage.value == null) {
      _error.value = 'Lütfen bir resim seçin';
      _errorHandler.handleWarning('Lütfen bir resim seçin');
      return null;
    }

    try {
      _isUploading.value = true;
      _error.value = '';

      // Resmi sunucuya yükle
      final imageUrl = await _imageUploadService.uploadImage(
        _selectedImage.value!.path,
        onProgress: (progress) {
          _uploadProgress.value =
              0.5 + (progress * 0.5); // Yükleme işlemi kalan %50
        },
      );

      if (imageUrl != null) {
        _errorHandler.handleSuccess('Profil resmi başarıyla yüklendi');
        _uploadProgress.value = 1.0;
        return imageUrl;
      } else {
        throw Exception('Resim yükleme başarısız');
      }
    } catch (e) {
      _errorHandler.handleError('Resim yüklenirken bir hata oluştu: $e',
          ErrorHandlerService.FILE_ERROR);
      _error.value = 'Resim yüklenirken bir hata oluştu: $e';
      return null;
    } finally {
      _isUploading.value = false;
    }
  }

  // Seçili resmi temizleme
  void clearSelectedImage() {
    _selectedImage.value = null;
    _error.value = '';
    _uploadProgress.value = 0.0;
    _isCompressing.value = false;
    _isUploading.value = false;
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../controllers/registration_controller.dart';
import '../../../../services/storage_service.dart';

class PersonalInfoStep extends GetView<RegistrationController> {
  final StorageService _storageService = Get.find<StorageService>();

  PersonalInfoStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Photo
        Center(
          child: Stack(
            children: [
              Obx(() {
                final photoUrl = controller.photoUrlController.text;
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  child: photoUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        )
                      : photoUrl.startsWith('http')
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: photoUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            )
                          : ClipOval(
                              child: Image.file(
                                File(photoUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                );
              }),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    onPressed: () => _showImageSourceDialog(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Bio
        TextFormField(
          controller: controller.bioController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Hakkımda',
            hintText: 'Kendinizi kısaca tanıtın',
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.description),
          ),
        ),
        const SizedBox(height: 24),

        // Location
        TextFormField(
          controller: controller.locationController,
          decoration: const InputDecoration(
            labelText: 'Konum',
            hintText: 'Şehir, Ülke',
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
        const SizedBox(height: 24),

        // Info Text
        const Text(
          'Bu bilgileri daha sonra profilinizden güncelleyebilirsiniz.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fotoğraf Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          cropStyle: CropStyle.circle,
          compressQuality: 80,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Fotoğrafı Düzenle',
              toolbarColor: Get.theme.primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Fotoğrafı Düzenle',
              aspectRatioLockEnabled: true,
              minimumAspectRatio: 1.0,
            ),
          ],
        );

        if (croppedFile != null) {
          // Yükleme başladığında loading göster
          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );

          // Firebase Storage'a yükle
          final userId = controller.getCurrentUserId();
          if (userId != null) {
            final downloadUrl = await _storageService.uploadProfileImage(
              userId,
              croppedFile.path,
            );

            if (downloadUrl != null) {
              controller.photoUrlController.text = downloadUrl;
              Get.back(); // Loading dialogu kapat
              Get.snackbar(
                'Başarılı',
                'Profil fotoğrafı güncellendi',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } else {
              Get.back(); // Loading dialogu kapat
              Get.snackbar(
                'Hata',
                'Fotoğraf yüklenemedi',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          }
        }
      }
    } catch (e) {
      Get.back(); // Loading dialogu kapat
      Get.snackbar(
        'Hata',
        'Fotoğraf seçilirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

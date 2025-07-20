import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/responsive_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../controllers/registration_controller.dart';
import '../../../../services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfoStep extends GetView<RegistrationController> {
  final _responsiveController = Get.find<ResponsiveController>();
  final StorageService _storageService = Get.find<StorageService>();

  PersonalInfoStep({Key? key}) : super(key: key);

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 70,
          maxWidth: 500,
          maxHeight: 500,
        );

        if (croppedFile != null) {
          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );

          final userId = controller.getCurrentUserId();
          if (userId != null) {
            final downloadUrl = await _storageService.uploadProfileImage(
              userId,
              croppedFile.path,
            );

            if (downloadUrl != null) {
              controller.photoUrlController.text = downloadUrl;
              Get.back();
              Get.snackbar(
                'Başarılı',
                'Profil fotoğrafı güncellendi',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            }
          }
        }
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Hata',
        'Fotoğraf seçilirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool _isValidLocationFormat(String value) {
    if (value.isEmpty) return true; // Empty is valid

    try {
      final parts = value.split(',').map((e) => e.trim()).toList();
      if (parts.length == 2) {
        final lat = double.parse(parts[0]);
        final lng = double.parse(parts[1]);
        return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void _updateLocation(String value) {
    if (value.isEmpty) {
      controller.location.value = null;
      return;
    }

    try {
      final parts = value.split(',').map((e) => e.trim()).toList();
      if (parts.length == 2) {
        final lat = double.parse(parts[0]);
        final lng = double.parse(parts[1]);

        if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          controller.location.value = GeoPoint(lat, lng);

          // Başarılı koordinat girişi feedback'i
          if (value.contains(',') && parts.length == 2) {
            Get.snackbar(
              'Başarılı',
              'Konum koordinatları güncellendi',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.8),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        } else {
          // Geçersiz koordinat aralığı
          Get.snackbar(
            'Geçersiz Koordinat',
            'Enlem: -90 ile 90, Boylam: -180 ile 180 arasında olmalı',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      // Geçersiz format - sadece virgül içeriyorsa uyarı ver
      if (value.contains(',')) {
        Get.snackbar(
          'Geçersiz Format',
          'Lütfen koordinatları "enlem, boylam" formatında girin',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: _responsiveController.responsivePadding(all: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  width: _responsiveController.responsiveValue(
                    mobile: 120.0,
                    tablet: 160.0,
                  ),
                  height: _responsiveController.responsiveValue(
                    mobile: 120.0,
                    tablet: 160.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Obx(() {
                    final photoUrl = controller.photoUrlController.text;
                    return ClipOval(
                      child: photoUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: _responsiveController.responsiveValue(
                                mobile: 60.0,
                                tablet: 80.0,
                              ),
                              color: Colors.grey,
                            )
                          : Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.error,
                                size: _responsiveController.responsiveValue(
                                  mobile: 60.0,
                                  tablet: 80.0,
                                ),
                                color: Colors.red,
                              ),
                            ),
                    );
                  }),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: _responsiveController.responsiveValue(
                      mobile: 18.0,
                      tablet: 24.0,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        size: _responsiveController.responsiveValue(
                          mobile: 18.0,
                          tablet: 24.0,
                        ),
                        color: Colors.white,
                      ),
                      onPressed: () => _pickImage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 24.0,
            tablet: 32.0,
          )),
          TextFormField(
            controller: controller.bioController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Hakkımda',
              hintText: 'Kendinizi kısaca tanıtın',
              prefixIcon: Icon(
                Icons.description,
                size: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 16.0,
              ),
            ),
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
            ),
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 24.0,
          )),
          Obx(() {
            final locationText = controller.locationController.text;
            final isValidLocation = _isValidLocationFormat(locationText);

            return TextFormField(
              controller: controller.locationController,
              onChanged: _updateLocation,
              decoration: InputDecoration(
                labelText: 'Konum Koordinatları',
                hintText: 'Örn: 41.0082, 28.9784',
                prefixIcon: Icon(
                  Icons.location_on,
                  size: _responsiveController.responsiveValue(
                    mobile: 24.0,
                    tablet: 32.0,
                  ),
                ),
                suffixIcon: locationText.isNotEmpty
                    ? Icon(
                        isValidLocation ? Icons.check_circle : Icons.error,
                        color: isValidLocation ? Colors.green : Colors.red,
                        size: _responsiveController.responsiveValue(
                          mobile: 20.0,
                          tablet: 28.0,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    _responsiveController.responsiveValue(
                      mobile: 8.0,
                      tablet: 12.0,
                    ),
                  ),
                ),
                contentPadding: _responsiveController.responsivePadding(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                helperText: locationText.isNotEmpty && !isValidLocation
                    ? 'Geçerli koordinat formatı: enlem, boylam'
                    : null,
                helperStyle: TextStyle(
                  color: Colors.red,
                  fontSize: _responsiveController.responsiveValue(
                    mobile: 12.0,
                    tablet: 14.0,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                  mobile: 16.0,
                  tablet: 18.0,
                ),
              ),
            );
          }),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 24.0,
          )),
          TextFormField(
            controller: controller.locationNameController,
            decoration: InputDecoration(
              labelText: 'Konum Adı',
              hintText: 'Şehir, Ülke',
              prefixIcon: Icon(
                Icons.place,
                size: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 16.0,
              ),
            ),
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
            ),
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 24.0,
            tablet: 32.0,
          )),
          Text(
            'Minimum 3 yetenek ekleyin',
            style: TextStyle(
              color: Colors.grey,
              fontSize: _responsiveController.responsiveValue(
                mobile: 12.0,
                tablet: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../controllers/registration_controller.dart';
import '../../../../services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfoStep extends GetView<RegistrationController> {
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
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil Fotoğrafı
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  child: Obx(() {
                    final photoUrl = controller.photoUrlController.text;
                    return ClipOval(
                      child: photoUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 60.sp,
                              color: Colors.grey,
                            )
                          : Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.error,
                                size: 60.sp,
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
                    radius: 18.r,
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Bio
          TextFormField(
            controller: controller.bioController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Hakkımda',
              hintText: 'Kendinizi kısaca tanıtın',
              prefixIcon: Icon(Icons.description, size: 24.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),

          // Konum
          Obx(() {
            final locationText = controller.locationController.text;
            final isValidLocation = _isValidLocationFormat(locationText);

            return TextFormField(
              controller: controller.locationController,
              onChanged: _updateLocation,
              decoration: InputDecoration(
                labelText: 'Konum Koordinatları',
                hintText: 'Örn: 41.0082, 28.9784',
                prefixIcon: Icon(Icons.location_on, size: 24.sp),
                suffixIcon: locationText.isNotEmpty
                    ? Icon(
                        isValidLocation ? Icons.check_circle : Icons.error,
                        color: isValidLocation ? Colors.green : Colors.red,
                        size: 20.sp,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: locationText.isEmpty
                        ? Colors.grey
                        : isValidLocation
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: locationText.isEmpty
                        ? Theme.of(context).primaryColor
                        : isValidLocation
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                helperText: locationText.isNotEmpty && !isValidLocation
                    ? 'Geçerli koordinat formatı: enlem, boylam'
                    : null,
                helperStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ),
              style: TextStyle(fontSize: 16.sp),
            );
          }),
          SizedBox(height: 16.h),

          // Konum Adı
          TextFormField(
            controller: controller.locationNameController,
            decoration: InputDecoration(
              labelText: 'Konum Adı',
              hintText: 'Şehir, Ülke',
              prefixIcon: Icon(Icons.place, size: 24.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 24.h),

          // Bilgilendirme Metni
          Text(
            'Bu bilgileri daha sonra profilinizden güncelleyebilirsiniz.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

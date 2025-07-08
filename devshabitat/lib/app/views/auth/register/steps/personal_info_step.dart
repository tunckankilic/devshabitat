import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  void _updateLocation(String value) {
    try {
      final parts = value.split(',').map((e) => e.trim()).toList();
      if (parts.length == 2) {
        final lat = double.parse(parts[0]);
        final lng = double.parse(parts[1]);
        if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          controller.location.value = GeoPoint(lat, lng);
        }
      }
    } catch (e) {
      // Geçersiz format - işlem yapma
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
          TextFormField(
            controller: controller.locationController,
            onChanged: _updateLocation,
            decoration: InputDecoration(
              labelText: 'Konum Koordinatları',
              hintText: 'Örn: 41.0082, 28.9784',
              prefixIcon: Icon(Icons.location_on, size: 24.sp),
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

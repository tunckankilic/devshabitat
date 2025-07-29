// ignore_for_file: deprecated_member_use

import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/responsive_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../controllers/registration_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../controllers/location/location_controller.dart';
import '../../../../services/location/location_tracking_service.dart';
import '../../../../services/location/maps_service.dart';
import '../../../../services/location/geofence_service.dart';

class PersonalInfoStep extends GetView<RegistrationController> {
  final _responsiveController = Get.find<ResponsiveController>();

  PersonalInfoStep({super.key});

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024, // Maksimum genişlik
        maxHeight: 1024, // Maksimum yükseklik
        imageQuality: 85, // Kalite
      );

      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 70,
          maxWidth: 500,
          maxHeight: 500,
        );

        if (croppedFile != null) {
          // Fotoğrafı sadece local'de sakla, yükleme yapma
          controller.photoUrlController.text = croppedFile.path; // Local path

          Get.snackbar(
            'Başarılı',
            'Fotoğraf seçildi. Kayıt tamamlandığında yüklenecek.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Fotoğraf seçilirken hata oluştu: $e',
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
              AppStrings.success,
              AppStrings.locationCoordinatesUpdated,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.8),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        } else {
          // Geçersiz koordinat aralığı
          Get.snackbar(
            AppStrings.invalidCoordinates,
            AppStrings.coordinatesValidationMessage,
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
          AppStrings.invalidFormat,
          AppStrings.coordinatesFormatHint,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  // Otomatik konum alma fonksiyonu
  Future<void> _getCurrentLocation() async {
    try {
      // Loading dialog göster
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Konumunuz alınıyor...',
                  style: TextStyle(
                    fontSize: _responsiveController.responsiveValue(
                      mobile: 16.0,
                      tablet: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Location controller'ı güvenli şekilde al veya oluştur
      LocationController locationController;
      try {
        locationController = Get.find<LocationController>();
      } catch (e) {
        // LocationController yoksa, gerekli servisleri de oluştur
        Get.put(LocationTrackingService());
        Get.put(MapsService());
        Get.put(GeofenceService());
        locationController = Get.put(LocationController());
      }

      await locationController.refreshLocationServices();

      if (locationController.currentLocation.value != null) {
        final loc = locationController.currentLocation.value!;

        // Koordinatları doldur
        controller.locationController.text =
            "${loc.latitude.toStringAsFixed(6)}, ${loc.longitude.toStringAsFixed(6)}";
        controller.location.value = GeoPoint(loc.latitude, loc.longitude);

        // Adres bilgisini al ve doldur
        final address =
            await locationController.getAddressFromCurrentLocation();
        if (address != null && address.isNotEmpty) {
          controller.locationNameController.text = address;
        }

        Get.back(); // Loading dialog'u kapat
        Get.snackbar(
          'Başarılı',
          'Konumunuz başarıyla alındı!',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.back();
        Get.snackbar(
          'Uyarı',
          'Konum bilgisi alınamadı. Lütfen manuel olarak girin.',
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.warning, color: Colors.white),
        );
      }
    } catch (e) {
      Get.back(); // Loading dialog'u kapat

      String errorMessage = 'Konum alınamadı.';
      if (e.toString().contains('permission')) {
        errorMessage =
            'Konum izni gerekli. Lütfen uygulama ayarlarından konum iznini aktifleştirin.';
      } else if (e.toString().contains('service')) {
        errorMessage =
            'Konum servisleri kapalı. Lütfen cihaz ayarlarından GPS\'i açın.';
      }

      Get.snackbar(
        'Hata',
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // Manuel konum girişi için dialog
  void _showManualLocationEntry() {
    Get.snackbar(
      'Manuel Giriş',
      'Koordinatları "enlem, boylam" formatında giriniz (örn: 41.0082, 28.9784)',
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info, color: Colors.white),
    );
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
              labelText: AppStrings.bio,
              hintText: AppStrings.bioHint,
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
                labelText: AppStrings.locationCoordinates,
                hintText: AppStrings.locationCoordinatesHint,
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
                    ? AppStrings.coordinatesFormatHint
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

          // Konum seçim butonları
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: Icon(
                    Icons.my_location,
                    size: _responsiveController.responsiveValue(
                      mobile: 20.0,
                      tablet: 24.0,
                    ),
                  ),
                  label: Text(
                    'Mevcut Konumumu Kullan',
                    style: TextStyle(
                      fontSize: _responsiveController.responsiveValue(
                        mobile: 14.0,
                        tablet: 16.0,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: _responsiveController.responsivePadding(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  width: _responsiveController.responsiveValue(
                mobile: 8.0,
                tablet: 12.0,
              )),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showManualLocationEntry,
                  icon: Icon(
                    Icons.edit_location,
                    size: _responsiveController.responsiveValue(
                      mobile: 20.0,
                      tablet: 24.0,
                    ),
                  ),
                  label: Text(
                    'Manuel Giriş',
                    style: TextStyle(
                      fontSize: _responsiveController.responsiveValue(
                        mobile: 14.0,
                        tablet: 16.0,
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: _responsiveController.responsivePadding(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 12.0,
            tablet: 16.0,
          )),

          TextFormField(
            controller: controller.locationNameController,
            decoration: InputDecoration(
              labelText: AppStrings.locationName,
              hintText: AppStrings.locationNameHint,
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
            AppStrings.minimumSkillsHint,
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

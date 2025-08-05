import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../controllers/responsive_controller.dart';
import '../../../../controllers/registration_controller.dart';
import '../../../../controllers/location/location_controller.dart';
import '../../../../constants/app_strings.dart';

// Debouncer sınıfı
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class PersonalInfoStep extends GetView<RegistrationController> {
  final _responsiveController = Get.find<ResponsiveController>();
  final _debouncer = Debouncer(milliseconds: 500);

  PersonalInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: _responsiveController.responsivePadding(all: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileImage(),
          SizedBox(height: 24),
          _buildBioField(),
          SizedBox(height: 16),
          _buildLocationFields(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: GetBuilder<RegistrationController>(
        id: 'profile_image',
        builder: (controller) {
          final photoUrl = controller.photoUrlController.text;
          return Stack(
            children: [
              _buildImageContainer(photoUrl),
              _buildImagePickerButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageContainer(String photoUrl) {
    return Container(
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
      child: ClipOval(child: _buildImage(photoUrl)),
    );
  }

  Widget _buildImage(String photoUrl) {
    if (photoUrl.isEmpty) {
      return const Icon(Icons.person);
    }

    if (photoUrl.startsWith('http')) {
      return _buildNetworkImage(photoUrl);
    }

    return _buildLocalImage(photoUrl);
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildLocalImage(String path) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
    );
  }

  Widget _buildImagePickerButton() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: CircleAvatar(
        backgroundColor: Theme.of(Get.context!).primaryColor,
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
    );
  }

  Widget _buildBioField() {
    return TextFormField(
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
            _responsiveController.responsiveValue(mobile: 8.0, tablet: 12.0),
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
    );
  }

  Widget _buildLocationFields() {
    return GetBuilder<RegistrationController>(
      id: 'location_fields',
      builder: (controller) {
        return Column(
          children: [
            _buildLocationInput(),
            const SizedBox(height: 16),
            _buildLocationButtons(),
            const SizedBox(height: 16),
            _buildLocationNameInput(),
          ],
        );
      },
    );
  }

  Widget _buildLocationInput() {
    return TextFormField(
      controller: controller.locationTextController,
      onChanged: (value) => _updateLocation(value),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            _responsiveController.responsiveValue(mobile: 8.0, tablet: 12.0),
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
    );
  }

  Widget _buildLocationButtons() {
    return Row(
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
        const SizedBox(width: 8),
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
    );
  }

  Widget _buildLocationNameInput() {
    return TextFormField(
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
            _responsiveController.responsiveValue(mobile: 8.0, tablet: 12.0),
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
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Loading göster
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        // Image processing'i arka planda yap
        final croppedFile = await compute<Map<String, dynamic>, String?>(
          _processCropImage,
          {
            'path': image.path,
            'maxWidth': 500,
            'maxHeight': 500,
            'quality': 70,
          },
        );

        // Dialog'u kapat
        Get.back();

        if (croppedFile != null) {
          controller.photoUrlController.text = croppedFile;
          controller.update(['profile_image']); // GetBuilder için update

          Get.snackbar(
            'Başarılı',
            'Fotoğraf seçildi. Kayıt tamamlandığında yüklenecek.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.back(); // Hata durumunda dialog'u kapat
      Get.snackbar(
        'Hata',
        'Fotoğraf seçilirken hata oluştu: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Isolate'de çalışacak image processing
  static Future<String?> _processCropImage(Map<String, dynamic> params) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: params['path'],
        maxWidth: params['maxWidth'],
        maxHeight: params['maxHeight'],
        compressQuality: params['quality'],
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      return croppedFile?.path;
    } catch (e) {
      return null;
    }
  }

  void _updateLocation(String value) {
    _debouncer.run(() {
      if (value.isEmpty) {
        controller.location.value = null;
        return;
      }

      try {
        // Farklı format desteği ekle
        final coordinates = _parseCoordinates(value);
        if (coordinates != null) {
          final lat = coordinates['latitude']!;
          final lng = coordinates['longitude']!;

          if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
            controller.location.value = GeoPoint(lat, lng);

            // Sadece geçerli koordinat girildiğinde ve önceki değerden farklıysa bildirim göster
            if (controller.lastValidLocation?.latitude != lat ||
                controller.lastValidLocation?.longitude != lng) {
              controller.lastValidLocation = GeoPoint(lat, lng);
              Get.snackbar(
                'Başarılı',
                'Konum koordinatları güncellendi',
                backgroundColor: Colors.green.withOpacity(0.8),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            }
          }
        }
      } catch (e) {
        // Hata mesajını sadece kullanıcı yazmayı bitirdiğinde göster
        if (value.isNotEmpty) {
          Get.snackbar(
            'Hata',
            'Geçersiz koordinat formatı. Örnek: 41.0082, 28.9784 veya 41°N 28°E',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    });
  }

  Map<String, double>? _parseCoordinates(String input) {
    // Virgülle ayrılmış format: "41.0082, 28.9784"
    final commaPattern = RegExp(r'^(-?\d+\.?\d*),\s*(-?\d+\.?\d*)$');

    // Boşlukla ayrılmış format: "41.0082 28.9784"
    final spacePattern = RegExp(r'^(-?\d+\.?\d*)\s+(-?\d+\.?\d*)$');

    // Derece formatı: "41°N 28°E" veya "41°S 28°W"
    final degreePattern = RegExp(
      r'^(\d+)°([NS])\s+(\d+)°([EW])$',
      caseSensitive: false,
    );

    if (commaPattern.hasMatch(input) || spacePattern.hasMatch(input)) {
      final parts = input.split(RegExp(r'[,\s]+'));
      return {
        'latitude': double.parse(parts[0].trim()),
        'longitude': double.parse(parts[1].trim()),
      };
    } else if (degreePattern.hasMatch(input)) {
      final match = degreePattern.firstMatch(input)!;
      var lat = double.parse(match.group(1)!);
      var lng = double.parse(match.group(3)!);

      if (match.group(2)!.toUpperCase() == 'S') lat = -lat;
      if (match.group(4)!.toUpperCase() == 'W') lng = -lng;

      return {'latitude': lat, 'longitude': lng};
    }

    return null;
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Loading dialog göster
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: true,
      );

      // GPS servislerini kontrol et
      final locationService = Get.find<LocationController>();
      if (!await locationService.checkLocationServices()) {
        Get.back(); // Loading dialog'u kapat
        await _showLocationServicesDialog();
        return;
      }

      // GPS izinlerini kontrol et
      if (!await locationService.checkLocationPermission()) {
        Get.back(); // Loading dialog'u kapat
        await _showPermissionDialog();
        return;
      }

      // Konum al
      final location = await locationService.getCurrentLocation();
      Get.back(); // Loading dialog'u kapat

      if (location != null &&
          location.latitude != null &&
          location.longitude != null) {
        controller.locationTextController.text =
            "${location.latitude!.toStringAsFixed(6)}, ${location.longitude!.toStringAsFixed(6)}";
        controller.location.value = GeoPoint(
          location.latitude!,
          location.longitude!,
        );

        // Adres bilgisini al
        final address = await compute<Map<String, double>, String?>(
          _fetchAddress,
          {'lat': location.latitude!, 'lng': location.longitude!},
        );

        if (address != null) {
          controller.locationNameController.text = address;
        }

        Get.snackbar(
          'Başarılı',
          'Konumunuz alındı',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.back(); // Loading dialog'u kapat
      Get.snackbar(
        'Hata',
        'Konum alınamadı: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _showLocationServicesDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('GPS Kapalı'),
        content: const Text('Konum servislerini açmak ister misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hayır'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Evet'),
          ),
        ],
      ),
    );

    if (result == true) {
      await Get.find<LocationController>().openLocationSettings();
    }
  }

  Future<void> _showPermissionDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konum İzni Gerekli'),
        content: const Text(
          'Konumunuzu almak için izin vermeniz gerekiyor. İzin vermek ister misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hayır'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Evet'),
          ),
        ],
      ),
    );

    if (result == true) {
      await Get.find<LocationController>().requestLocationPermission();
    }
  }

  // Isolate'de çalışacak statik metod
  static Future<String?> _fetchAddress(Map<String, double> coords) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coords['lat']!,
        coords['lng']!,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

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
}

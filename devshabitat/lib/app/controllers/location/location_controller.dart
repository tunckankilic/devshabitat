import 'package:get/get.dart';
import '../../models/location/location_model.dart';
import '../../services/location/location_tracking_service.dart';
import '../../services/location/maps_service.dart';

class LocationController extends GetxController {
  final LocationTrackingService _trackingService =
      Get.find<LocationTrackingService>();
  final MapsService _mapsService = Get.find<MapsService>();

  final currentLocation = Rxn<LocationModel>();
  final lastKnownLocation = Rxn<LocationModel>();
  final isTrackingEnabled = false.obs;
  final locationPermissionGranted = false.obs;
  final locationServicesEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final location = await _trackingService.getCurrentLocation();
      if (location != null) {
        currentLocation.value = location;
        lastKnownLocation.value = location;
      }

      // Konum servislerinin durumunu kontrol et
      locationServicesEnabled.value = await _checkLocationServices();
      locationPermissionGranted.value = await _checkLocationPermission();

      // Konum değişikliklerini dinle
      ever(currentLocation, (LocationModel? location) {
        if (location != null) {
          lastKnownLocation.value = location;
        }
      });
    } catch (e) {
      print('Konum başlatma hatası: $e');
    }
  }

  Future<bool> _checkLocationServices() async {
    try {
      // Geolocator servisi üzerinden kontrol
      return await _trackingService.getCurrentLocation() != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkLocationPermission() async {
    try {
      // Konum izinlerini kontrol et
      await _trackingService.getCurrentLocation();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> startLocationTracking() async {
    if (!locationPermissionGranted.value || !locationServicesEnabled.value) {
      await _initializeLocation();
    }

    if (locationPermissionGranted.value && locationServicesEnabled.value) {
      _trackingService.startTracking();
      isTrackingEnabled.value = true;
    }
  }

  void stopLocationTracking() {
    _trackingService.stopTracking();
    isTrackingEnabled.value = false;
  }

  Future<void> updateCurrentLocation() async {
    final location = await _trackingService.getCurrentLocation();
    if (location != null) {
      currentLocation.value = location;
    }
  }

  Future<String?> getAddressFromCurrentLocation() async {
    if (currentLocation.value == null) return null;

    return _mapsService.getAddressFromCoordinates(
      currentLocation.value!.latitude,
      currentLocation.value!.longitude,
    );
  }

  double? getDistanceFromCurrentLocation(LocationModel destination) {
    if (currentLocation.value == null) return null;

    return _mapsService.calculateDistance(
      currentLocation.value!,
      destination,
    );
  }

  @override
  void onClose() {
    stopLocationTracking();
    super.onClose();
  }
}

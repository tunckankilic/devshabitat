import 'dart:async';
import 'package:get/get.dart';
import 'package:location/location.dart';
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
  StreamSubscription<LocationData?>? _locationSubscription;

  LocationModel _convertToLocationModel(LocationData data) {
    return LocationModel(
      latitude: data.latitude ?? 0,
      longitude: data.longitude ?? 0,
      accuracy: data.accuracy,
      altitude: data.altitude,
      speed: data.speed,
      heading: data.heading,
      timestamp: DateTime.fromMillisecondsSinceEpoch(data.time?.toInt() ?? 0),
    );
  }

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final locationData = await _trackingService.getCurrentLocation();
      if (locationData != null) {
        final location = _convertToLocationModel(locationData);
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
      return await _trackingService.getCurrentLocation() != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkLocationPermission() async {
    try {
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
      _locationSubscription?.cancel();
      _locationSubscription = _trackingService.getLocationStream().listen(
        (locationData) {
          if (locationData != null) {
            currentLocation.value = _convertToLocationModel(locationData);
          }
        },
        onError: (error) {
          print('Konum takip hatası: $error');
        },
      );
      isTrackingEnabled.value = true;
    }
  }

  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    isTrackingEnabled.value = false;
  }

  Future<void> updateCurrentLocation() async {
    final locationData = await _trackingService.getCurrentLocation();
    if (locationData != null) {
      currentLocation.value = _convertToLocationModel(locationData);
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
    _locationSubscription?.cancel();
    super.onClose();
  }
}

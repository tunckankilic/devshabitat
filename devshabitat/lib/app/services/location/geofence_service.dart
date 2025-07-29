import 'dart:async';
import 'package:geofence_flutter/geofence_flutter.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:location/location.dart';
import '../../models/location/geofence_model.dart';
import '../../models/location/location_model.dart';

class GeofenceService extends GetxService {
  final activeGeofences = <GeofenceModel>[].obs;
  final isGeofenceServiceActive = false.obs;
  StreamSubscription<GeofenceEvent>? _geofenceEventStream;
  final Logger _logger = Logger();
  final Location _location = Location();

  Future<void> initializeGeofencing() async {
    try {
      // Geofence servisi zaten başlatılmışsa tekrar başlatma
      if (isGeofenceServiceActive.value) {
        _logger.w('Geofence service is already active');
        return;
      }

      // Location permission kontrolü
      if (!await _checkLocationPermission()) {
        throw Exception('Location permission not granted');
      }

      // Mevcut konumu al
      final currentLocation = await _getCurrentLocation();

      // Geofence servisini başlat
      await Geofence.startGeofenceService(
        pointedLatitude: currentLocation.latitude.toString(),
        pointedLongitude: currentLocation.longitude.toString(),
        radiusMeter: "100.0", // 100 metre yarıçap
        eventPeriodInSeconds: 10,
      );

      // Geofence event stream'i dinle
      _geofenceEventStream = Geofence.getGeofenceStream()?.listen(
        (GeofenceEvent event) {
          _handleGeofenceEvent(event);
        },
        onError: (error) {
          _logger.e('Geofence stream error: $error');
          isGeofenceServiceActive.value = false;
        },
      );

      isGeofenceServiceActive.value = true;
      _logger.i('Geofence service initialized successfully');
    } catch (e) {
      _logger.e('Geofence initialization error: $e');
      isGeofenceServiceActive.value = false;
      rethrow;
    }
  }

  Future<bool> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _logger.w('Location service is not enabled');
          return false;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          _logger.w('Location permission denied');
          return false;
        }
      }

      return true;
    } catch (e) {
      _logger.e('Error checking location permission: $e');
      return false;
    }
  }

  Future<LocationData> _getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      _logger.i(
          'Current location: ${locationData.latitude}, ${locationData.longitude}');
      return locationData;
    } catch (e) {
      _logger.w('Could not get current location, using default (Istanbul): $e');
      // Fallback to Istanbul coordinates
      return LocationData.fromMap({
        'latitude': 41.0082,
        'longitude': 28.9784,
      });
    }
  }

  void _handleGeofenceEvent(GeofenceEvent event) {
    _logger.i('Geofence Event - Type: ${event.toString()}');

    // Event tipine göre işlem yap
    switch (event) {
      case GeofenceEvent.init:
        _logger.i('Geofence servisi başlatıldı');
        break;
      case GeofenceEvent.enter:
        _logger.i('Geofence alanına giriş yapıldı');
        _onGeofenceEnter();
        break;
      case GeofenceEvent.exit:
        _logger.i('Geofence alanından çıkış yapıldı');
        _onGeofenceExit();
        break;
    }
  }

  void _onGeofenceEnter() {
    // Geofence alanına giriş event'i
    // Burada bildirim gösterilebilir, analytics event'i gönderilebilir vb.
    Get.snackbar(
      'Geofence Giriş',
      'Tanımlı bir alan içine girdiniz',
      snackPosition: SnackPosition.TOP,
    );
  }

  void _onGeofenceExit() {
    // Geofence alanından çıkış event'i
    // Burada bildirim gösterilebilir, analytics event'i gönderilebilir vb.
    Get.snackbar(
      'Geofence Çıkış',
      'Tanımlı alandan ayrıldınız',
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<void> stopGeofencing() async {
    try {
      await Geofence.stopGeofenceService();
      await _geofenceEventStream?.cancel();
      _geofenceEventStream = null;
      isGeofenceServiceActive.value = false;
      _logger.i('Geofence service stopped successfully');
    } catch (e) {
      _logger.e('Error stopping geofence service: $e');
      isGeofenceServiceActive.value = false;
    }
  }

  Future<void> addGeofence(GeofenceModel geofence) async {
    try {
      await Geofence.startGeofenceService(
        pointedLatitude: geofence.latitude.toString(),
        pointedLongitude: geofence.longitude.toString(),
        radiusMeter: geofence.radius.toString(),
        eventPeriodInSeconds: 10,
      );

      activeGeofences.add(geofence);
      isGeofenceServiceActive.value = true;

      _logger.i(
          'Geofence added: ${geofence.id} at (${geofence.latitude}, ${geofence.longitude}) with radius ${geofence.radius}m');
    } catch (e) {
      _logger.e('Error adding geofence: $e');
      rethrow;
    }
  }

  Future<void> removeGeofence(String geofenceId) async {
    try {
      // Mevcut implementasyonda tek bir geofence destekleniyor
      await stopGeofencing();
      final removedCount = activeGeofences.length;
      activeGeofences.removeWhere((geofence) => geofence.id == geofenceId);

      if (removedCount > activeGeofences.length) {
        _logger.i('Geofence removed: $geofenceId');
      } else {
        _logger.w('Geofence not found: $geofenceId');
      }
    } catch (e) {
      _logger.e('Error removing geofence: $e');
    }
  }

  Future<void> clearGeofences() async {
    try {
      await stopGeofencing();
      final clearedCount = activeGeofences.length;
      activeGeofences.clear();
      _logger.i('All geofences cleared ($clearedCount items)');
    } catch (e) {
      _logger.e('Error clearing geofences: $e');
    }
  }

  bool isLocationInAnyGeofence(LocationModel location) {
    return activeGeofences.any((geofence) =>
        geofence.isPointInside(location.latitude, location.longitude));
  }

  @override
  void onClose() {
    stopGeofencing();
    _logger.i('GeofenceService disposed');
    super.onClose();
  }
}

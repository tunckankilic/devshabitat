import 'dart:async';
import 'dart:math';
import 'package:devshabitat/app/models/location/location_model.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/location/developer_location_model.dart';
import 'package:logger/logger.dart';

class BatteryOptimizedSettings {
  final LocationAccuracy accuracy;
  final int interval;

  BatteryOptimizedSettings({
    required this.accuracy,
    required this.interval,
  });
}

class LocationTrackingService extends GetxService {
  final Location _location = Location();
  StreamController<LocationData>? _locationController;
  StreamSubscription<LocationData>? _locationSubscription;
  final Logger _logger = Get.find<Logger>();
  bool _isDisposed = false;

  // Battery optimization settings
  LocationAccuracy _currentAccuracy = LocationAccuracy.balanced;
  int _currentInterval = 30000; // Start with 30 seconds
  Timer? _batteryOptimizationTimer;

  Future<LocationTrackingService> init() async {
    try {
      await _location.requestPermission();
      await _initializeOptimalSettings();
      _startBatteryOptimization();
      return this;
    } catch (e) {
      _logger.e('Location tracking service initialization error: $e');
      rethrow;
    }
  }

  Future<void> _initializeOptimalSettings() async {
    // Get battery level and adjust settings accordingly
    final batteryLevel = await _getBatteryOptimizedSettings();
    await _location.changeSettings(
      accuracy: batteryLevel.accuracy,
      interval: batteryLevel.interval,
    );
    _currentAccuracy = batteryLevel.accuracy;
    _currentInterval = batteryLevel.interval;
  }

  Future<BatteryOptimizedSettings> _getBatteryOptimizedSettings() async {
    // Mock battery level - in real app use battery_plus package
    final isLowPowerMode = false; // await Battery().isInBatterySaveMode();

    if (isLowPowerMode) {
      return BatteryOptimizedSettings(
        accuracy: LocationAccuracy.low,
        interval: 60000, // 1 minute
      );
    } else {
      return BatteryOptimizedSettings(
        accuracy: LocationAccuracy.balanced,
        interval: 30000, // 30 seconds
      );
    }
  }

  void _startBatteryOptimization() {
    _batteryOptimizationTimer?.cancel();
    _batteryOptimizationTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _adjustSettingsBasedOnUsage(),
    );
  }

  Future<void> _adjustSettingsBasedOnUsage() async {
    if (_isDisposed) return;

    try {
      final settings = await _getBatteryOptimizedSettings();
      if (settings.accuracy != _currentAccuracy ||
          settings.interval != _currentInterval) {
        await updateLocationSettings(
          accuracy: settings.accuracy,
          interval: settings.interval,
        );
      }
    } catch (e) {
      _logger.e('Error adjusting location settings: $e');
    }
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      if (_isDisposed) {
        throw Exception('Service disposed');
      }
      return await _location.getLocation();
    } catch (e) {
      _logger.e('Error getting current location: $e');
      Get.snackbar('Hata', 'Konum alınamadı');
      return null;
    }
  }

  Stream<LocationData?> getLocationStream() {
    try {
      // Önceki stream'i temizle
      _disposeLocationStream();

      if (_isDisposed) {
        return Stream.value(null);
      }

      _locationController = StreamController<LocationData>.broadcast();

      _locationSubscription = _location.onLocationChanged.listen(
        (locationData) {
          if (!_isDisposed &&
              _locationController != null &&
              !_locationController!.isClosed) {
            _locationController!.add(locationData);
          }
        },
        onError: (error) {
          _logger.e('Location stream error: $error');
          Get.snackbar('Hata', 'Konum güncellemesi alınamadı');
        },
        cancelOnError: false,
      );

      return _locationController!.stream;
    } catch (e) {
      _logger.e('Error creating location stream: $e');
      return Stream.value(null);
    }
  }

  void _disposeLocationStream() {
    _locationSubscription?.cancel();
    _locationSubscription = null;

    if (_locationController != null && !_locationController!.isClosed) {
      _locationController!.close();
    }
    _locationController = null;
  }

  Future<void> updateLocationSettings({
    required LocationAccuracy accuracy,
    required int interval,
  }) async {
    try {
      if (_isDisposed) return;
      await _location.changeSettings(
        accuracy: accuracy,
        interval: interval,
      );
      _currentAccuracy = accuracy;
      _currentInterval = interval;
      _logger.i(
          'Location settings updated: accuracy=$accuracy, interval=${interval}ms');
    } catch (e) {
      _logger.e('Error updating location settings: $e');
    }
  }

  Future<bool> checkBackgroundMode() async {
    try {
      if (_isDisposed) return false;
      return await _location.isBackgroundModeEnabled();
    } catch (e) {
      _logger.e('Error checking background mode: $e');
      return false;
    }
  }

  Future<bool> enableBackgroundMode() async {
    try {
      if (_isDisposed) return false;
      return await _location.enableBackgroundMode();
    } catch (e) {
      _logger.e('Error enabling background mode: $e');
      return false;
    }
  }

  Future<void> disableBackgroundMode() async {
    try {
      if (_isDisposed) return;
      await _location.enableBackgroundMode(enable: false);
    } catch (e) {
      _logger.e('Error disabling background mode: $e');
    }
  }

  Future<void> updateUserLocation({
    required String userId,
    required GeoPoint location,
  }) async {
    try {
      if (_isDisposed) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'location': location});
    } catch (e) {
      _logger.e('Error updating user location: $e');
      throw Exception('Konum güncellenirken hata oluştu: $e');
    }
  }

  Future<void> removeUserLocation({required String userId}) async {
    try {
      if (_isDisposed) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'location': FieldValue.delete()});
    } catch (e) {
      _logger.e('Error removing user location: $e');
      throw Exception('Konum silinirken hata oluştu: $e');
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    _batteryOptimizationTimer?.cancel();
    _disposeLocationStream();
    super.onClose();
  }

  // Helper methods
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Dünya'nın yarıçapı (km)

    // Radyana çevirme
    final lat1 = point1.latitude * (pi / 180);
    final lon1 = point1.longitude * (pi / 180);
    final lat2 = point2.latitude * (pi / 180);
    final lon2 = point2.longitude * (pi / 180);

    // Enlem ve boylam farkları
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    // Haversine formülü
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Mesafeyi kilometre cinsinden hesaplama
    return earthRadius * c;
  }

  static bool isWithinRadius(LatLng center, LatLng point, double radiusKm) {
    final distance = calculateDistance(center, point);
    return distance <= radiusKm;
  }

  Future<List<DeveloperLocationModel>> getNearbyDevelopers(
    LocationModel currentLocation,
    double radiusKm,
  ) async {
    try {
      if (_isDisposed) return [];

      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final developers = snapshot.docs
          .map((doc) => DeveloperLocationModel.fromFirestore(doc))
          .where((dev) => isWithinRadius(
                LatLng(currentLocation.latitude, currentLocation.longitude),
                LatLng(dev.location.latitude, dev.location.longitude),
                radiusKm,
              ))
          .toList();
      return developers;
    } catch (e) {
      _logger.e('Error getting nearby developers: $e');
      throw Exception('Yakındaki geliştiriciler alınırken hata oluştu: $e');
    }
  }

  Future<void> updateLocationNotificationSettings({
    required String userId,
    required bool enabled,
  }) async {
    try {
      if (_isDisposed) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'locationNotificationsEnabled': enabled});
    } catch (e) {
      _logger.e('Error updating location notification settings: $e');
      throw Exception('Bildirim ayarları güncellenirken hata oluştu: $e');
    }
  }

  Future<void> updateNotificationSettings({
    required String userId,
    required bool enabled,
    required String notificationType,
  }) async {
    try {
      if (_isDisposed) return;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'notifications': {
          notificationType: {
            'enabled': enabled,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        }
      });
    } catch (e) {
      _logger.e('Error updating notification settings: $e');
      throw Exception('Bildirim ayarları güncellenirken hata oluştu: $e');
    }
  }
}

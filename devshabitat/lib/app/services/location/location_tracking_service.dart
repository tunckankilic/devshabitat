import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/location/developer_location_model.dart';
import '../../models/location/location_model.dart';
import 'package:logger/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:devshabitat/app/services/location/location_cache_service.dart';
import 'package:flutter/material.dart';

class BatteryOptimizedSettings {
  final LocationAccuracy accuracy;
  final int interval;
  final String reason;

  BatteryOptimizedSettings({
    required this.accuracy,
    required this.interval,
    required this.reason,
  });
}

class LocationTrackingService extends GetxService {
  final Location _location = Location();
  final LocationCacheService _cacheService = Get.find();
  StreamController<LocationData>? _locationController;
  StreamSubscription<LocationData>? _locationSubscription;
  final Logger _logger = Get.find();
  bool _isDisposed = false;

  // Battery optimization settings
  LocationAccuracy _currentAccuracy = LocationAccuracy.balanced;
  int _currentInterval = 30000; // Start with 30 seconds
  Timer? _batteryOptimizationTimer;

  // Device info for intelligent optimization
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  bool _isLowEndDevice = false;
  String _lastOptimizationReason = '';

  // Usage tracking
  DateTime _lastLocationRequest = DateTime.now();
  int _locationRequestCount = 0;

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
    try {
      // Cihaz bilgilerini al
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _isLowEndDevice =
            androidInfo.version.sdkInt < 29 ||
            androidInfo.supportedAbis.length < 2;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _isLowEndDevice =
            !iosInfo.isPhysicalDevice ||
            double.parse(iosInfo.systemVersion) < 13.0;
      }

      // Platform bazlı optimizasyonlar
      if (Platform.isIOS) {
        await _optimizeForIOS();
      } else if (Platform.isAndroid) {
        await _optimizeForAndroid();
      }

      // Düşük performanslı cihazlar için ek optimizasyonlar
      if (_isLowEndDevice) {
        _currentInterval = 60000; // 1 dakika
        _currentAccuracy = LocationAccuracy.balanced;
        _lastOptimizationReason = 'Düşük performanslı cihaz optimizasyonu';
      }
    } catch (e) {
      _logger.e('Konum optimizasyonu başlatılamadı: $e');
      // Varsayılan ayarları kullan
      _currentInterval = 30000;
      _currentAccuracy = LocationAccuracy.balanced;
    }
  }

  Future<void> _optimizeForIOS() async {
    await _location.changeSettings(
      accuracy: _isLowEndDevice
          ? LocationAccuracy.balanced
          : LocationAccuracy.high,
      interval: _currentInterval,
      distanceFilter: 10,
    );

    // iOS özel ayarlar
    if (_isLowEndDevice) {
      await _location.enableBackgroundMode(enable: false);
    } else {
      await _location.enableBackgroundMode(enable: true);
    }
  }

  Future<void> _optimizeForAndroid() async {
    await _location.changeSettings(
      accuracy: _currentAccuracy,
      interval: _currentInterval,
      distanceFilter: _isLowEndDevice ? 20 : 10,
    );

    // Android özel ayarlar
    if (!_isLowEndDevice) {
      await _location.changeNotificationOptions(
        channelName: "Konum Güncellemeleri",
        title: "Konum Takibi Aktif",
        subtitle: "Yakındaki geliştiricileri bulmak için konum kullanılıyor",
        description: "Arka planda konum güncellemeleri alınıyor",
        color: Colors.blue,
      );
    }
  }

  void _startBatteryOptimization() {
    _batteryOptimizationTimer?.cancel();
    _batteryOptimizationTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _adjustLocationSettings(),
    );
  }

  Future<void> _adjustLocationSettings() async {
    try {
      final now = DateTime.now();
      final timeSinceLastRequest = now.difference(_lastLocationRequest);
      final hourOfDay = now.hour;

      BatteryOptimizedSettings newSettings;

      // Gece saatleri optimizasyonu (23:00 - 06:00)
      if (hourOfDay >= 23 || hourOfDay < 6) {
        newSettings = BatteryOptimizedSettings(
          accuracy: LocationAccuracy.balanced,
          interval: 120000, // 2 dakika
          reason: 'Gece modu optimizasyonu',
        );
      }
      // Düşük kullanım optimizasyonu
      else if (timeSinceLastRequest.inHours > 2) {
        newSettings = BatteryOptimizedSettings(
          accuracy: LocationAccuracy.balanced,
          interval: 60000, // 1 dakika
          reason: 'Düşük kullanım optimizasyonu',
        );
      }
      // Normal mod
      else {
        newSettings = BatteryOptimizedSettings(
          accuracy: _isLowEndDevice
              ? LocationAccuracy.balanced
              : LocationAccuracy.high,
          interval: _isLowEndDevice ? 45000 : 30000, // 45 veya 30 saniye
          reason: 'Normal mod',
        );
      }

      // Ayarları güncelle
      if (newSettings.interval != _currentInterval ||
          newSettings.accuracy != _currentAccuracy) {
        _currentInterval = newSettings.interval;
        _currentAccuracy = newSettings.accuracy;
        _lastOptimizationReason = newSettings.reason;

        await _location.changeSettings(
          accuracy: newSettings.accuracy,
          interval: newSettings.interval,
        );

        _logger.i('Konum ayarları güncellendi: ${newSettings.reason}');
      }
    } catch (e) {
      _logger.e('Konum ayarları güncellenirken hata: $e');
    }
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      if (_isDisposed) {
        throw Exception('Service disposed');
      }

      // Önce önbellekten kontrol et
      final cachedLocation = await _cacheService.getLastLocation();
      if (cachedLocation != null) {
        _logger.d('Konum önbellekten alındı');
        return LocationData.fromMap({
          'latitude': cachedLocation.latitude,
          'longitude': cachedLocation.longitude,
          'accuracy': cachedLocation.accuracy,
          'speed': cachedLocation.speed,
          'heading': cachedLocation.heading,
        });
      }

      // Track usage for optimization
      _lastLocationRequest = DateTime.now();
      _locationRequestCount++;

      final location = await _location.getLocation();

      // Konumu önbelleğe al
      await _cacheService.cacheLocation(
        LocationModel(
          latitude: location.latitude!,
          longitude: location.longitude!,
          accuracy: location.accuracy!,
          timestamp: DateTime.now(),
          speed: location.speed,
          heading: location.heading,
        ),
      );

      // Log location request for analytics
      _logger.d(
        'Location request #$_locationRequestCount - Optimization: $_lastOptimizationReason',
      );

      return location;
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
        (locationData) async {
          if (!_isDisposed &&
              _locationController != null &&
              !_locationController!.isClosed) {
            // Konumu önbelleğe al
            await _cacheService.cacheLocation(
              LocationModel(
                latitude: locationData.latitude!,
                longitude: locationData.longitude!,
                accuracy: locationData.accuracy!,
                timestamp: DateTime.now(),
                speed: locationData.speed,
                heading: locationData.heading,
              ),
            );

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
      await _location.changeSettings(accuracy: accuracy, interval: interval);
      _currentAccuracy = accuracy;
      _currentInterval = interval;
      _logger.i(
        'Location settings updated: accuracy=$accuracy, interval=${interval}ms - Reason: $_lastOptimizationReason',
      );
    } catch (e) {
      _logger.e('Error updating location settings: $e');
    }
  }

  // Getter methods for monitoring
  Map<String, dynamic> get optimizationInfo => {
    'currentAccuracy': _currentAccuracy.toString(),
    'currentInterval': _currentInterval,
    'lastOptimizationReason': _lastOptimizationReason,
    'isLowEndDevice': _isLowEndDevice,
    'locationRequestCount': _locationRequestCount,
    'lastLocationRequest': _lastLocationRequest.toIso8601String(),
  };

  bool get isLowEndDevice => _isLowEndDevice;
  String get lastOptimizationReason => _lastOptimizationReason;
  int get locationRequestCount => _locationRequestCount;

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
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'location': location,
      });
    } catch (e) {
      _logger.e('Error updating user location: $e');
      throw Exception('Konum güncellenirken hata oluştu: $e');
    }
  }

  Future<void> removeUserLocation({required String userId}) async {
    try {
      if (_isDisposed) return;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'location': FieldValue.delete(),
      });
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
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
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

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      final developers = snapshot.docs
          .map((doc) => DeveloperLocationModel.fromFirestore(doc))
          .where(
            (dev) => isWithinRadius(
              LatLng(currentLocation.latitude, currentLocation.longitude),
              LatLng(dev.location.latitude, dev.location.longitude),
              radiusKm,
            ),
          )
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
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'locationNotificationsEnabled': enabled,
      });
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
          },
        },
      });
    } catch (e) {
      _logger.e('Error updating notification settings: $e');
      throw Exception('Bildirim ayarları güncellenirken hata oluştu: $e');
    }
  }
}

import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:devshabitat/app/models/location/location_model.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/location/developer_location_model.dart';
import 'package:logger/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
  StreamController<LocationData>? _locationController;
  StreamSubscription<LocationData>? _locationSubscription;
  final Logger _logger = Get.find<Logger>();
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
    try {
      // Device performance analysis
      await _analyzeDeviceCapabilities();

      // Usage pattern analysis
      final usagePattern = _analyzeUsagePattern();

      // Time-based optimization
      final timeBasedOptimization = _getTimeBasedOptimization();

      // Network status consideration
      final isNetworkLimited = await _isNetworkLimited();

      // Determine optimal settings
      LocationAccuracy accuracy;
      int interval;
      String reason;

      if (_isLowEndDevice) {
        accuracy = LocationAccuracy.low;
        interval = 60000; // 1 minute
        reason = 'Low-end device optimization';
      } else if (usagePattern == 'background') {
        accuracy = LocationAccuracy.balanced;
        interval = 45000; // 45 seconds
        reason = 'Background usage pattern';
      } else if (timeBasedOptimization == 'night') {
        accuracy = LocationAccuracy.low;
        interval = 120000; // 2 minutes
        reason = 'Night time optimization';
      } else if (isNetworkLimited) {
        accuracy = LocationAccuracy.balanced;
        interval = 30000; // 30 seconds
        reason = 'Network limited optimization';
      } else if (usagePattern == 'active') {
        accuracy = LocationAccuracy.high;
        interval = 15000; // 15 seconds
        reason = 'Active usage pattern';
      } else {
        accuracy = LocationAccuracy.balanced;
        interval = 30000; // 30 seconds
        reason = 'Default balanced settings';
      }

      _lastOptimizationReason = reason;
      _logger.i('Battery optimization applied: $reason');

      return BatteryOptimizedSettings(
        accuracy: accuracy,
        interval: interval,
        reason: reason,
      );
    } catch (e) {
      _logger.e('Error in battery optimization: $e');
      return BatteryOptimizedSettings(
        accuracy: LocationAccuracy.balanced,
        interval: 30000,
        reason: 'Fallback to default settings',
      );
    }
  }

  Future<void> _analyzeDeviceCapabilities() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Consider device as low-end if it has less than 3GB RAM or old Android version
        final totalMemoryMB =
            (androidInfo.systemFeatures.contains('android.hardware.ram.normal'))
                ? 2048
                : 4096;
        final sdkInt = androidInfo.version.sdkInt;

        _isLowEndDevice = totalMemoryMB < 3072 || sdkInt < 28; // Android 9.0

        if (_isLowEndDevice) {
          _logger.i(
              'Low-end Android device detected: SDK $sdkInt, estimated RAM ${totalMemoryMB}MB');
        }
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final model = iosInfo.model.toLowerCase();

        // Consider older iOS devices as low-end
        _isLowEndDevice = model.contains('iphone 6') ||
            model.contains('iphone 7') ||
            model.contains('iphone se') ||
            iosInfo.systemVersion.startsWith('13') ||
            iosInfo.systemVersion.startsWith('14');

        if (_isLowEndDevice) {
          _logger.i(
              'Low-end iOS device detected: ${iosInfo.model}, iOS ${iosInfo.systemVersion}');
        }
      }
    } catch (e) {
      _logger.w('Could not analyze device capabilities: $e');
      _isLowEndDevice = false;
    }
  }

  String _analyzeUsagePattern() {
    final now = DateTime.now();
    final timeSinceLastRequest = now.difference(_lastLocationRequest).inMinutes;

    if (timeSinceLastRequest < 2) {
      return 'active'; // Very frequent requests
    } else if (timeSinceLastRequest < 10) {
      return 'moderate'; // Regular usage
    } else {
      return 'background'; // Infrequent usage
    }
  }

  String _getTimeBasedOptimization() {
    final hour = DateTime.now().hour;

    if (hour >= 23 || hour <= 6) {
      return 'night'; // Night time (11 PM - 6 AM)
    } else if (hour >= 9 && hour <= 18) {
      return 'day'; // Work hours
    } else {
      return 'evening'; // Evening hours
    }
  }

  Future<bool> _isNetworkLimited() async {
    try {
      // Check if user is on cellular data or limited connection
      // This is a simplified check - in real app, use connectivity_plus
      return false; // For now, assume good network
    } catch (e) {
      _logger.w('Could not check network status: $e');
      return false;
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

      // Track usage for optimization
      _lastLocationRequest = DateTime.now();
      _locationRequestCount++;

      final location = await _location.getLocation();

      // Log location request for analytics
      _logger.d(
          'Location request #$_locationRequestCount - Optimization: $_lastOptimizationReason');

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
          'Location settings updated: accuracy=$accuracy, interval=${interval}ms - Reason: $_lastOptimizationReason');
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

// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import 'package:location/location.dart';
import '../../models/location/location_model.dart';
import '../../models/location/geofence_model.dart';
import '../../services/location/location_tracking_service.dart';
import '../../services/location/geofence_service.dart';
import '../../services/location/maps_service.dart';
import '../../core/services/memory_manager_service.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart'; // Added for Get.snackbar
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firestore
import 'package:geocoding/geocoding.dart'
    hide Location; // Added for placemarkFromCoordinates
import '../auth_controller.dart'; // Added for AuthController

class LocationController extends GetxController with MemoryManagementMixin {
  final LocationTrackingService _trackingService =
      Get.find<LocationTrackingService>();
  final GeofenceService _geofenceService = Get.find<GeofenceService>();
  final MapsService _mapsService = Get.find<MapsService>();
  final Logger _logger = Logger();

  // Enhanced reactive variables
  final currentLocation = Rxn<LocationModel>();
  final lastKnownLocation = Rxn<LocationModel>();
  final isTrackingEnabled = false.obs;
  final locationPermissionGranted = false.obs;
  final locationServicesEnabled = false.obs;
  final geofenceServiceActive = false.obs;
  final activeGeofences = <GeofenceModel>[].obs;
  final locationServiceStatus = ''.obs;
  final isLocationLoading = false.obs;
  final locationError = ''.obs;

  // Device optimization properties
  final isLowEndDevice = false.obs;
  final batteryOptimized = true.obs;
  final trackingAccuracy = 'balanced'.obs; // high, balanced, low
  final updateInterval = 30.obs; // seconds

  StreamSubscription<LocationData?>? _locationSubscription;
  Timer? _statusUpdateTimer;

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
    _bindGeofenceService();
    _startStatusMonitoring();
  }

  // Enhanced location initialization with device optimization
  Future<void> _initializeLocation() async {
    try {
      isLocationLoading.value = true;
      locationError.value = '';

      // Check device capabilities for optimization
      await _checkDeviceCapabilities();

      // Apply device-specific optimizations
      await _applyDeviceOptimizations();

      // Initialize permissions and services
      await _checkLocationPermissions();
      await _checkLocationServices();

      // Start location tracking if permissions granted
      if (locationPermissionGranted.value && locationServicesEnabled.value) {
        await startLocationTracking();
      }

      locationServiceStatus.value = 'Location services initialized';
      _logger.i('Location services initialized successfully');
    } catch (e) {
      locationError.value = 'Location initialization failed: $e';
      _logger.e('Location initialization error: $e');
    } finally {
      isLocationLoading.value = false;
    }
  }

  // Device capability detection
  Future<void> _checkDeviceCapabilities() async {
    try {
      // This would typically use device_info_plus to detect device specs
      // For now, we'll use a simplified approach
      final deviceCapabilityScore = await _calculateDeviceCapabilityScore();

      isLowEndDevice.value = deviceCapabilityScore < 0.6;

      if (isLowEndDevice.value) {
        trackingAccuracy.value = 'low';
        updateInterval.value = 60; // Longer intervals for low-end devices
        batteryOptimized.value = true;
      } else {
        trackingAccuracy.value = 'balanced';
        updateInterval.value = 30;
        batteryOptimized.value = false;
      }

      _logger.i(
          'Device capability: ${isLowEndDevice.value ? "Low-end" : "High-end"}');
    } catch (e) {
      _logger.e('Device capability check failed: $e');
    }
  }

  Future<double> _calculateDeviceCapabilityScore() async {
    // Simplified device scoring - in real implementation would use device_info_plus
    // Returns score between 0.0 (low-end) and 1.0 (high-end)
    return 0.75; // Default to mid-range device
  }

  // Apply device-specific optimizations
  Future<void> _applyDeviceOptimizations() async {
    try {
      if (isLowEndDevice.value) {
        // Low-end device optimizations
        _logger.i('Applying low-end device optimizations');
      } else {
        // High-end device optimizations
        _logger.i('Applying high-end device optimizations');
      }
    } catch (e) {
      _logger.e('Device optimization failed: $e');
    }
  }

  // Enhanced permission checking
  Future<void> _checkLocationPermissions() async {
    try {
      // Try to get current location to check permissions
      final location = await _trackingService.getCurrentLocation();
      locationPermissionGranted.value = location != null;

      if (location == null) {
        locationError.value = 'Location permission not granted';
        locationServiceStatus.value = 'Permission required';
      }
    } catch (e) {
      locationPermissionGranted.value = false;
      locationError.value = 'Permission check failed: $e';
      _logger.e('Permission check error: $e');
    }
  }

  // Enhanced service checking
  Future<void> _checkLocationServices() async {
    try {
      // Use Location package directly for service check
      final location = Location();
      final servicesEnabled = await location.serviceEnabled();
      locationServicesEnabled.value = servicesEnabled;

      if (!servicesEnabled) {
        locationError.value = 'Location services disabled';
        locationServiceStatus.value = 'Services disabled';
      }
    } catch (e) {
      locationServicesEnabled.value = false;
      locationError.value = 'Service check failed: $e';
      _logger.e('Service check error: $e');
    }
  }

  // Bind with enhanced GeofenceService
  void _bindGeofenceService() {
    // Listen to geofence service status
    ever(_geofenceService.isGeofenceServiceActive, (bool isActive) {
      geofenceServiceActive.value = isActive;
      if (isActive) {
        locationServiceStatus.value = 'Geofence monitoring active';
      }
    });

    // Listen to active geofences
    ever(_geofenceService.activeGeofences, (List<GeofenceModel> geofences) {
      activeGeofences.value = geofences;
      _logger.i('Active geofences updated: ${geofences.length}');
    });
  }

  // Enhanced location tracking with intelligent settings
  Future<void> startLocationTracking() async {
    try {
      if (!locationPermissionGranted.value || !locationServicesEnabled.value) {
        throw Exception('Location permissions or services not available');
      }

      isTrackingEnabled.value = true;
      locationServiceStatus.value = 'Starting location tracking...';

      // Update tracking with device-optimized settings
      await _trackingService.updateLocationSettings(
        accuracy: _getLocationAccuracy(),
        interval: updateInterval.value * 1000, // Convert to milliseconds
      );

      // Subscribe to location updates
      _locationSubscription = _trackingService.getLocationStream().listen(
        (LocationData? locationData) {
          if (locationData != null) {
            final location = _convertToLocationModel(locationData);
            currentLocation.value = location;
            lastKnownLocation.value = location;
            locationServiceStatus.value = 'Location updated';
          }
        },
        onError: (error) {
          locationError.value = 'Location tracking error: $error';
          _logger.e('Location tracking error: $error');
        },
      );

      locationServiceStatus.value = 'Location tracking active';
      _logger.i('Location tracking started successfully');
    } catch (e) {
      isTrackingEnabled.value = false;
      locationError.value = 'Failed to start tracking: $e';
      _logger.e('Location tracking start error: $e');
    }
  }

  // Get device-optimized location accuracy
  LocationAccuracy _getLocationAccuracy() {
    switch (trackingAccuracy.value) {
      case 'high':
        return LocationAccuracy.high;
      case 'low':
        return LocationAccuracy.low;
      default:
        return LocationAccuracy.balanced;
    }
  }

  // Enhanced geofence management
  Future<void> initializeGeofencing() async {
    try {
      if (!locationPermissionGranted.value) {
        throw Exception('Location permission required for geofencing');
      }

      await _geofenceService.initializeGeofencing();
      locationServiceStatus.value = 'Geofencing initialized';
      _logger.i('Geofencing initialized successfully');
    } catch (e) {
      locationError.value = 'Geofencing initialization failed: $e';
      _logger.e('Geofencing initialization error: $e');
    }
  }

  Future<void> addGeofence(GeofenceModel geofence) async {
    try {
      await _geofenceService.addGeofence(geofence);
      locationServiceStatus.value = 'Geofence added: ${geofence.id}';
      _logger.i('Geofence added: ${geofence.id}');
    } catch (e) {
      locationError.value = 'Failed to add geofence: $e';
      _logger.e('Add geofence error: $e');
    }
  }

  // Status monitoring
  void _startStatusMonitoring() {
    _statusUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateServiceStatus();
    });
  }

  void _updateServiceStatus() {
    if (isTrackingEnabled.value && currentLocation.value != null) {
      final locationTimestamp = currentLocation.value!.timestamp;
      if (locationTimestamp != null) {
        final age = DateTime.now().difference(locationTimestamp);
        if (age.inMinutes > 5) {
          locationServiceStatus.value =
              'Location data stale (${age.inMinutes}m old)';
        }
      }
    }
  }

  // User controls for optimization
  Future<void> setTrackingAccuracy(String accuracy) async {
    trackingAccuracy.value = accuracy;
    await _applyTrackingSettings();
  }

  Future<void> setUpdateInterval(int seconds) async {
    updateInterval.value = seconds;
    await _applyTrackingSettings();
  }

  Future<void> toggleBatteryOptimization() async {
    batteryOptimized.value = !batteryOptimized.value;
    await _applyTrackingSettings();
  }

  Future<void> _applyTrackingSettings() async {
    if (isTrackingEnabled.value) {
      await stopLocationTracking();
      await startLocationTracking();
    }
  }

  // Stop tracking
  Future<void> stopLocationTracking() async {
    try {
      await _locationSubscription?.cancel();
      _locationSubscription = null;
      // Note: LocationTrackingService doesn't have stopTracking method
      // Instead we just stop listening to the stream
      isTrackingEnabled.value = false;
      locationServiceStatus.value = 'Location tracking stopped';
      _logger.i('Location tracking stopped');
    } catch (e) {
      locationError.value = 'Failed to stop tracking: $e';
      _logger.e('Stop tracking error: $e');
    }
  }

  Future<void> stopGeofencing() async {
    try {
      await _geofenceService.stopGeofencing();
      locationServiceStatus.value = 'Geofencing stopped';
      _logger.i('Geofencing stopped');
    } catch (e) {
      locationError.value = 'Failed to stop geofencing: $e';
      _logger.e('Stop geofencing error: $e');
    }
  }

  // Get address from current location
  Future<String?> getAddressFromCurrentLocation() async {
    try {
      if (currentLocation.value != null) {
        return await _mapsService.getAddressFromCoordinates(
          currentLocation.value!.latitude,
          currentLocation.value!.longitude,
        );
      }
      return null;
    } catch (e) {
      _logger.e('Error getting address from current location: $e');
      return null;
    }
  }

  // Refresh all location services
  Future<void> refreshLocationServices() async {
    await stopLocationTracking();
    await stopGeofencing();
    await _initializeLocation();
  }

  // Get comprehensive status
  Map<String, dynamic> getLocationStatus() {
    return {
      'tracking_enabled': isTrackingEnabled.value,
      'permissions_granted': locationPermissionGranted.value,
      'services_enabled': locationServicesEnabled.value,
      'geofence_active': geofenceServiceActive.value,
      'current_location': currentLocation.value?.toJson(),
      'accuracy_setting': trackingAccuracy.value,
      'update_interval': updateInterval.value,
      'battery_optimized': batteryOptimized.value,
      'device_type': isLowEndDevice.value ? 'low-end' : 'high-end',
      'status': locationServiceStatus.value,
      'error': locationError.value,
    };
  }

  // Location History Management
  final RxList<Map<String, dynamic>> locationHistory =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingHistory = false.obs;
  final RxString historyError = ''.obs;
  final RxInt historyRetentionDays = 30.obs;

  // Load location history
  Future<void> loadLocationHistory() async {
    try {
      isLoadingHistory.value = true;
      historyError.value = '';

      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Calculate date range
      final endDate = DateTime.now();
      final startDate =
          endDate.subtract(Duration(days: historyRetentionDays.value));

      // Query location history from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('location_history')
          .where('userId', isEqualTo: currentUser.uid)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      final history = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'address': data['address'],
          'placeName': data['placeName'],
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
          'accuracy': data['accuracy'],
          'type': data['type'] ?? 'automatic', // automatic, manual, check-in
        };
      }).toList();

      locationHistory.value = history;
      _logger.i('Loaded ${history.length} location history entries');
    } catch (e) {
      historyError.value = 'Konum geçmişi yüklenirken hata oluştu: $e';
      _logger.e('Load location history error: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // Save location to history
  Future<void> saveLocationToHistory(
    double latitude,
    double longitude, {
    String? address,
    String? placeName,
    String type = 'automatic',
  }) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) return;

      // Get address if not provided
      String finalAddress = address ?? '';
      String finalPlaceName = placeName ?? '';

      if (finalAddress.isEmpty) {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          finalAddress =
              '${placemark.street}, ${placemark.locality}, ${placemark.country}';
          finalPlaceName =
              placemark.name ?? placemark.street ?? 'Unknown Location';
        }
      }

      final locationData = {
        'userId': currentUser.uid,
        'latitude': latitude,
        'longitude': longitude,
        'address': finalAddress,
        'placeName': finalPlaceName,
        'timestamp': FieldValue.serverTimestamp(),
        'accuracy': currentLocation.value?.accuracy ?? 0.0,
        'type': type,
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('location_history')
          .add(locationData);

      // Add to local history
      final newEntry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'latitude': latitude,
        'longitude': longitude,
        'address': finalAddress,
        'placeName': finalPlaceName,
        'timestamp': DateTime.now(),
        'accuracy': currentLocation.value?.accuracy ?? 0.0,
        'type': type,
      };

      locationHistory.insert(0, newEntry);

      _logger.i('Location saved to history: $finalPlaceName');
    } catch (e) {
      _logger.e('Save location to history error: $e');
    }
  }

  // Clear location history
  Future<void> clearLocationHistory() async {
    try {
      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Delete from Firestore
      final batch = FirebaseFirestore.instance.batch();
      final querySnapshot = await FirebaseFirestore.instance
          .collection('location_history')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Clear local history
      locationHistory.clear();

      Get.snackbar(
        'Başarılı',
        'Konum geçmişi temizlendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _logger.i('Location history cleared');
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Konum geçmişi temizlenirken hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _logger.e('Clear location history error: $e');
    }
  }

  // Delete specific location entry
  Future<void> deleteLocationEntry(String entryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('location_history')
          .doc(entryId)
          .delete();

      locationHistory.removeWhere((entry) => entry['id'] == entryId);

      Get.snackbar(
        'Başarılı',
        'Konum girişi silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _logger.i('Location entry deleted: $entryId');
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Konum girişi silinirken hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _logger.e('Delete location entry error: $e');
    }
  }

  // Navigate to location on map
  Future<void> navigateToLocation(
      double latitude, double longitude, String placeName) async {
    try {
      // This would open a map application or navigate within the app
      Get.snackbar(
        'Harita',
        '$placeName konumuna yönlendiriliyor...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      _logger.i('Navigate to location: $placeName ($latitude, $longitude)');
    } catch (e) {
      _logger.e('Navigate to location error: $e');
    }
  }

  // Check-in to current location manually
  Future<void> checkInToCurrentLocation(String placeName) async {
    try {
      if (currentLocation.value == null) {
        throw Exception('Mevcut konum bulunamadı');
      }

      await saveLocationToHistory(
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
        placeName: placeName,
        type: 'check-in',
      );

      Get.snackbar(
        'Check-in',
        '$placeName konumuna check-in yapıldı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _logger.i('Checked in to: $placeName');
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Check-in yapılırken hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _logger.e('Check-in error: $e');
    }
  }

  // Get location statistics
  Map<String, dynamic> getLocationStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: 7));
    final thisMonth = DateTime(now.year, now.month, 1);

    final todayCount = locationHistory.where((entry) {
      final timestamp = entry['timestamp'] as DateTime;
      return timestamp.isAfter(today);
    }).length;

    final weekCount = locationHistory.where((entry) {
      final timestamp = entry['timestamp'] as DateTime;
      return timestamp.isAfter(thisWeek);
    }).length;

    final monthCount = locationHistory.where((entry) {
      final timestamp = entry['timestamp'] as DateTime;
      return timestamp.isAfter(thisMonth);
    }).length;

    final checkInCount = locationHistory.where((entry) {
      return entry['type'] == 'check-in';
    }).length;

    return {
      'total_entries': locationHistory.length,
      'today_entries': todayCount,
      'week_entries': weekCount,
      'month_entries': monthCount,
      'check_ins': checkInCount,
      'retention_days': historyRetentionDays.value,
    };
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    _statusUpdateTimer?.cancel();
    super.onClose();
  }
}

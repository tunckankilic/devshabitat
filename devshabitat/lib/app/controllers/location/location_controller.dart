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

  @override
  void onClose() {
    _locationSubscription?.cancel();
    _statusUpdateTimer?.cancel();
    super.onClose();
  }
}

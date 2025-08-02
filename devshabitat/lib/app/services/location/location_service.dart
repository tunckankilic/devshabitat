import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/error_handler_service.dart';
import '../../core/services/memory_manager_service.dart';
import '../../models/location/location_model.dart';

class LocationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ErrorHandlerService _errorHandler = Get.find();
  final MemoryManagerService _memoryManager = Get.find();

  StreamSubscription<Position>? _positionStream;
  Timer? _locationUpdateTimer;
  final _locationUpdateInterval = const Duration(minutes: 5);
  final _minDistanceFilter = 100.0; // meters

  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isTrackingEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLocationPermission();
  }

  @override
  void onClose() {
    _stopLocationTracking();
    super.onClose();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          _errorHandler.showWarning(
            'Location permission denied. Some features may not work.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorHandler.showWarning(
          'Location permission permanently denied. '
          'Please enable it in settings.',
        );
        return;
      }

      // Start tracking if permission granted
      await startLocationTracking();
    } catch (e) {
      _errorHandler.handleError(e, 'checkLocationPermission');
    }
  }

  Future<void> startLocationTracking() async {
    if (isTrackingEnabled.value) return;

    try {
      // Get initial position
      final position = await Geolocator.getCurrentPosition();
      currentPosition.value = position;
      await _updateUserLocation(position);

      // Start position stream
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: _minDistanceFilter.toInt(),
            ),
          ).listen(
            (Position position) async {
              currentPosition.value = position;
              await _updateUserLocation(position);
            },
            onError: (error) {
              _errorHandler.handleError(error, 'locationStream');
            },
          );

      // Start periodic updates
      _locationUpdateTimer = Timer.periodic(_locationUpdateInterval, (_) async {
        if (currentPosition.value != null) {
          await _updateUserLocation(currentPosition.value!);
        }
      });

      isTrackingEnabled.value = true;
      _memoryManager.optimizeMemory();
    } catch (e) {
      _errorHandler.handleError(e, 'startLocationTracking');
    }
  }

  Future<void> _updateUserLocation(Position position) async {
    try {
      final userId = Get.find<String>(tag: 'userId');
      final locationData = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
        speed: position.speed,
        heading: position.heading,
        userId: userId,
      );

      await _firestore
          .collection('user_locations')
          .doc(userId)
          .set(locationData.toJson());
    } catch (e) {
      _errorHandler.handleError(e, 'updateUserLocation');
    }
  }

  void _stopLocationTracking() {
    _positionStream?.cancel();
    _locationUpdateTimer?.cancel();
    isTrackingEnabled.value = false;
    _memoryManager.optimizeMemory();
  }

  Future<List<LocationModel>> getNearbyLocations({
    required double latitude,
    required double longitude,
    double radius = 5000, // meters
  }) async {
    try {
      // Calculate bounding box for initial filtering
      final lat = 0.0144927536231884; // degrees per kilometer
      final lon = 0.0181818181818182; // degrees per kilometer
      final distance = radius / 1000; // convert to kilometers

      final lowerLat = latitude - (lat * distance);
      final lowerLon = longitude - (lon * distance);
      final upperLat = latitude + (lat * distance);
      final upperLon = longitude + (lon * distance);

      final snapshot = await _firestore
          .collection('user_locations')
          .where('location', isGreaterThan: GeoPoint(lowerLat, lowerLon))
          .where('location', isLessThan: GeoPoint(upperLat, upperLon))
          .get();

      return snapshot.docs
          .map((doc) => LocationModel.fromJson(doc.data()))
          .where((location) {
            // Calculate actual distance
            final distance = Geolocator.distanceBetween(
              latitude,
              longitude,
              location.latitude,
              location.longitude,
            );
            return distance <= radius;
          })
          .toList();
    } catch (e) {
      _errorHandler.handleError(e, 'getNearbyLocations');
      return [];
    }
  }

  Future<void> toggleLocationTracking(bool enable) async {
    if (enable) {
      await startLocationTracking();
    } else {
      _stopLocationTracking();
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      currentPosition.value = position;
      return position;
    } catch (e) {
      _errorHandler.handleError(e, 'getCurrentPosition');
      return null;
    }
  }

  Stream<List<LocationModel>> watchNearbyLocations({
    required double latitude,
    required double longitude,
    double radius = 5000, // meters
  }) {
    // Calculate bounding box
    final lat = 0.0144927536231884;
    final lon = 0.0181818181818182;
    final distance = radius / 1000;

    final lowerLat = latitude - (lat * distance);
    final lowerLon = longitude - (lon * distance);
    final upperLat = latitude + (lat * distance);
    final upperLon = longitude + (lon * distance);

    return _firestore
        .collection('user_locations')
        .where('location', isGreaterThan: GeoPoint(lowerLat, lowerLon))
        .where('location', isLessThan: GeoPoint(upperLat, upperLon))
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LocationModel.fromJson(doc.data()))
              .where((location) {
                final distance = Geolocator.distanceBetween(
                  latitude,
                  longitude,
                  location.latitude,
                  location.longitude,
                );
                return distance <= radius;
              })
              .toList();
        });
  }
}

import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationTrackingService extends GetxService {
  final Location _location = Location();
  StreamController<LocationData>? _locationController;

  Future<LocationTrackingService> init() async {
    await _location.requestPermission();
    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 15000, // 15 seconds
    );
    return this;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      return await _location.getLocation();
    } catch (e) {
      Get.snackbar('Hata', 'Konum alınamadı');
      return null;
    }
  }

  Stream<LocationData?> getLocationStream() {
    _locationController?.close();
    _locationController = StreamController<LocationData>.broadcast();

    _location.onLocationChanged.listen(
      (locationData) {
        if (!_locationController!.isClosed) {
          _locationController!.add(locationData);
        }
      },
      onError: (error) {
        Get.snackbar('Hata', 'Konum güncellemesi alınamadı');
      },
    );

    return _locationController!.stream;
  }

  Future<void> updateLocationSettings({
    required LocationAccuracy accuracy,
    required int interval,
  }) async {
    await _location.changeSettings(
      accuracy: accuracy,
      interval: interval,
    );
  }

  Future<bool> checkBackgroundMode() async {
    return await _location.isBackgroundModeEnabled();
  }

  Future<bool> enableBackgroundMode() async {
    return await _location.enableBackgroundMode();
  }

  Future<void> disableBackgroundMode() async {
    await _location.enableBackgroundMode(enable: false);
  }

  @override
  void onClose() {
    _locationController?.close();
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
}

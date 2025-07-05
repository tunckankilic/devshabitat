import 'dart:async';
import 'dart:math';
import 'package:devshabitat/app/models/location/location_model.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/location/developer_location_model.dart';

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

  Future<void> updateUserLocation({
    required String userId,
    required GeoPoint location,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'location': location});
    } catch (e) {
      throw Exception('Konum güncellenirken hata oluştu: $e');
    }
  }

  Future<void> removeUserLocation({required String userId}) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'location': FieldValue.delete()});
    } catch (e) {
      throw Exception('Konum silinirken hata oluştu: $e');
    }
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

  Future<List<DeveloperLocationModel>> getNearbyDevelopers(
    LocationModel currentLocation,
    double radiusKm,
  ) async {
    try {
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
      throw Exception('Yakındaki geliştiriciler alınırken hata oluştu: $e');
    }
  }

  Future<void> updateLocationNotificationSettings({
    required String userId,
    required bool enabled,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'locationNotificationsEnabled': enabled});
    } catch (e) {
      throw Exception('Bildirim ayarları güncellenirken hata oluştu: $e');
    }
  }

  Future<void> updateNotificationSettings({
    required String userId,
    required bool enabled,
    required String notificationType,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'notifications': {
          notificationType: {
            'enabled': enabled,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        }
      });
    } catch (e) {
      throw Exception('Bildirim ayarları güncellenirken hata oluştu: $e');
    }
  }
}

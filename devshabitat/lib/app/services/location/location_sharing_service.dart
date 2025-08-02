import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/location/geofence_model.dart';
import 'location_tracking_service.dart';

class LocationSharingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationTrackingService _trackingService = Get.find();

  final RxMap<String, LatLng> sharedLocations = <String, LatLng>{}.obs;
  final RxList<GeofenceModel> activeGeofences = <GeofenceModel>[].obs;

  StreamSubscription? _locationSubscription;
  String? _userId;

  Future<LocationSharingService> init(String userId) async {
    _userId = userId;
    return this;
  }

  Future<void> startSharingLocation({
    required List<String> shareWithUserIds,
    Duration? duration,
  }) async {
    if (_userId == null) throw Exception('Kullanıcı kimliği gerekli');

    final locationStream = _trackingService.getLocationStream();

    _locationSubscription = locationStream.listen((locationData) {
      if (locationData != null) {
        final location = GeoPoint(
          locationData.latitude!,
          locationData.longitude!,
        );

        // Konum güncelleme
        _firestore.collection('shared_locations').doc(_userId).set({
          'location': location,
          'timestamp': FieldValue.serverTimestamp(),
          'shared_with': shareWithUserIds,
          'expires_at': duration != null
              ? Timestamp.fromDate(DateTime.now().add(duration))
              : null,
        });
      }
    });
  }

  Future<void> stopSharingLocation() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    if (_userId != null) {
      await _firestore.collection('shared_locations').doc(_userId).delete();
    }
  }

  Stream<Map<String, LatLng>> getSharedLocations(List<String> userIds) {
    return _firestore
        .collection('shared_locations')
        .where('shared_with', arrayContains: _userId)
        .snapshots()
        .map((snapshot) {
          final Map<String, LatLng> locations = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final GeoPoint? geoPoint = data['location'] as GeoPoint?;

            if (geoPoint != null) {
              locations[doc.id] = LatLng(geoPoint.latitude, geoPoint.longitude);
            }
          }

          sharedLocations.value = locations;
          return locations;
        });
  }

  Future<void> addGeofence(GeofenceModel geofence) async {
    await _firestore.collection('geofences').doc().set(geofence.toJson());

    activeGeofences.add(geofence);
  }

  Future<void> removeGeofence(String geofenceId) async {
    await _firestore.collection('geofences').doc(geofenceId).delete();

    activeGeofences.removeWhere((g) => g.id == geofenceId);
  }

  Stream<List<GeofenceModel>> getGeofences() {
    return _firestore.collection('geofences').snapshots().map((snapshot) {
      final geofences = snapshot.docs
          .map((doc) => GeofenceModel.fromJson(doc.data()))
          .toList();

      activeGeofences.value = geofences;
      return geofences;
    });
  }

  bool isUserInGeofence(LatLng userLocation, GeofenceModel geofence) {
    return LocationTrackingService.isWithinRadius(
      LatLng(geofence.latitude, geofence.longitude),
      userLocation,
      geofence.radius ?? 100.0, // Default radius: 100 meters
    );
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    super.onClose();
  }
}

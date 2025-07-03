import 'dart:async';
import 'package:geofence_flutter/geofence_flutter.dart';
import 'package:get/get.dart';
import '../../models/location/geofence_model.dart';
import '../../models/location/location_model.dart';

class GeofenceService extends GetxService {
  final activeGeofences = <GeofenceModel>[].obs;
  StreamSubscription<GeofenceEvent>? _geofenceEventStream;

  Future<void> initializeGeofencing() async {
    await Geofence.startGeofenceService(
      pointedLatitude: "0.0", // Varsayılan değer, addGeofence ile güncellenecek
      pointedLongitude:
          "0.0", // Varsayılan değer, addGeofence ile güncellenecek
      radiusMeter: "100.0", // Varsayılan değer, addGeofence ile güncellenecek
      eventPeriodInSeconds: 10,
    );

    _geofenceEventStream = Geofence.getGeofenceStream()?.listen(
      (GeofenceEvent event) {
        print('Geofence Event: ${event.toString()}');
      },
    );
  }

  Future<void> startGeofencing() async {
    // Geofence servisi zaten initializeGeofencing ile başlatılıyor
  }

  Future<void> stopGeofencing() async {
    await Geofence.stopGeofenceService();
    await _geofenceEventStream?.cancel();
  }

  void addGeofence(GeofenceModel geofence) async {
    await Geofence.startGeofenceService(
      pointedLatitude: geofence.latitude.toString(),
      pointedLongitude: geofence.longitude.toString(),
      radiusMeter: geofence.radius.toString(),
      eventPeriodInSeconds: 10,
    );
    activeGeofences.add(geofence);
  }

  void removeGeofence(String geofenceId) {
    // Mevcut implementasyonda tek bir geofence destekleniyor
    stopGeofencing();
    activeGeofences.removeWhere((geofence) => geofence.id == geofenceId);
  }

  void clearGeofences() {
    stopGeofencing();
    activeGeofences.clear();
  }

  bool isLocationInAnyGeofence(LocationModel location) {
    return activeGeofences.any((geofence) =>
        geofence.isPointInside(location.latitude, location.longitude));
  }

  @override
  void onClose() {
    stopGeofencing();
    super.onClose();
  }
}

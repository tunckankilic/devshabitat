import 'package:geofence_service/geofence_service.dart';
import 'package:get/get.dart';
import '../../models/location/geofence_model.dart';
import '../../models/location/location_model.dart';

class GeofenceService extends GetxService {
  final _geofenceService = GeofenceService.instance;
  final activeGeofences = <GeofenceModel>[].obs;
  final geofenceStatus = GeofenceStatus.idle.obs;

  Future<void> initializeGeofencing() async {
    await _geofenceService.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: false,
      printDevLog: false,
    );

    _geofenceService
      ..addGeofenceStatusChangeListener(_onGeofenceStatusChanged)
      ..addLocationChangeListener(_onLocationChanged)
      ..addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged)
      ..addActivityChangeListener(_onActivityChanged);
  }

  void _onGeofenceStatusChanged(Geofence geofence,
      GeofenceRadius geofenceRadius, GeofenceStatus geofenceStatus) {
    print('Geofence Status: $geofenceStatus');
    this.geofenceStatus.value = geofenceStatus;
  }

  void _onLocationChanged(Location location) {
    print('Location: ${location.latitude}, ${location.longitude}');
  }

  void _onLocationServicesStatusChanged(bool status) {
    print('Location Services Status: $status');
  }

  void _onActivityChanged(Activity activity) {
    print('Activity: ${activity.type}');
  }

  Future<void> startGeofencing() async {
    await _geofenceService.start();
  }

  Future<void> stopGeofencing() async {
    await _geofenceService.stop();
  }

  void addGeofence(GeofenceModel geofence) {
    final newGeofence = Geofence(
      id: geofence.id,
      latitude: geofence.latitude,
      longitude: geofence.longitude,
      radius: [
        GeofenceRadius(id: 'radius_${geofence.id}', length: geofence.radius),
      ],
    );

    _geofenceService.addGeofence(newGeofence);
    activeGeofences.add(geofence);
  }

  void removeGeofence(String geofenceId) {
    _geofenceService.removeGeofence(geofenceId);
    activeGeofences.removeWhere((geofence) => geofence.id == geofenceId);
  }

  void clearGeofences() {
    _geofenceService.clearGeofenceList();
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

import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:location/location.dart';
import '../../models/location/geofence_model.dart';
import 'location_tracking_service.dart';

class GeofenceService extends GetxService {
  final LocationTrackingService _trackingService = Get.find();
  final Logger _logger = Get.find();

  final RxList<GeofenceModel> activeGeofences = <GeofenceModel>[].obs;
  final RxBool isGeofenceServiceActive = false.obs;

  StreamSubscription? _locationSubscription;
  Timer? _geofenceCheckTimer;

  // Optimize edilmiş değerler
  static const double _defaultRadius = 100.0; // metre
  static const Duration _checkInterval = Duration(minutes: 1);
  static const int _maxActiveGeofences = 20;

  @override
  void onInit() {
    super.onInit();
    _initializeGeofencing();
  }

  Future<void> _initializeGeofencing() async {
    try {
      isGeofenceServiceActive.value = true;
      await _startGeofenceMonitoring();
      _logger.i('Geofence service initialized');
    } catch (e) {
      _logger.e('Geofence initialization error: $e');
      isGeofenceServiceActive.value = false;
    }
  }

  Future<void> _startGeofenceMonitoring() async {
    _locationSubscription?.cancel();
    _geofenceCheckTimer?.cancel();

    // Konum değişikliklerini dinle
    _locationSubscription = _trackingService.getLocationStream().listen(
      _handleLocationUpdate,
    );

    // Periyodik kontrol başlat
    _geofenceCheckTimer = Timer.periodic(_checkInterval, (_) {
      _checkActiveGeofences();
    });
  }

  void _handleLocationUpdate(LocationData? locationData) {
    if (locationData == null) return;

    for (var geofence in activeGeofences) {
      final distance = Geolocator.distanceBetween(
        locationData.latitude!,
        locationData.longitude!,
        geofence.latitude,
        geofence.longitude,
      );

      final wasInside = geofence.isInside;
      final isInside = distance <= (geofence.radius ?? _defaultRadius);

      if (isInside != wasInside) {
        geofence.isInside = isInside;
        _handleGeofenceTransition(geofence, isInside);
      }
    }
  }

  void _handleGeofenceTransition(GeofenceModel geofence, bool isInside) {
    try {
      if (isInside) {
        _logger.i('Entered geofence: ${geofence.id}');
        _executeGeofenceActions(geofence, 'enter');
      } else {
        _logger.i('Exited geofence: ${geofence.id}');
        _executeGeofenceActions(geofence, 'exit');
      }
    } catch (e) {
      _logger.e('Geofence transition error: $e');
    }
  }

  Future<void> _executeGeofenceActions(
    GeofenceModel geofence,
    String trigger,
  ) async {
    try {
      final actions = trigger == 'enter'
          ? geofence.onEnterActions
          : geofence.onExitActions;

      for (var action in actions ?? []) {
        switch (action.type) {
          case 'notification':
            // Bildirim gönder
            break;
          case 'event':
            // Etkinlik tetikle
            break;
          case 'status':
            // Durum güncelle
            break;
        }
      }
    } catch (e) {
      _logger.e('Execute geofence actions error: $e');
    }
  }

  Future<void> addGeofence(GeofenceModel geofence) async {
    try {
      if (activeGeofences.length >= _maxActiveGeofences) {
        throw Exception('Maximum geofence limit reached');
      }

      if (!activeGeofences.any((g) => g.id == geofence.id)) {
        activeGeofences.add(geofence);
        _logger.i('Added geofence: ${geofence.id}');
      }
    } catch (e) {
      _logger.e('Add geofence error: $e');
      rethrow;
    }
  }

  Future<void> removeGeofence(String geofenceId) async {
    try {
      activeGeofences.removeWhere((g) => g.id == geofenceId);
      _logger.i('Removed geofence: $geofenceId');
    } catch (e) {
      _logger.e('Remove geofence error: $e');
      rethrow;
    }
  }

  void _checkActiveGeofences() {
    try {
      // Geofence'lerin geçerliliğini kontrol et
      final now = DateTime.now();
      activeGeofences.removeWhere((geofence) {
        final isExpired =
            geofence.expirationDate != null &&
            geofence.expirationDate!.isBefore(now);
        if (isExpired) {
          _logger.i('Geofence expired: ${geofence.id}');
        }
        return isExpired;
      });
    } catch (e) {
      _logger.e('Check active geofences error: $e');
    }
  }

  Future<void> initializeGeofencing() async {
    try {
      isGeofenceServiceActive.value = true;
      await _startGeofenceMonitoring();
      _logger.i('Geofence service initialized');
    } catch (e) {
      _logger.e('Geofence initialization error: $e');
      isGeofenceServiceActive.value = false;
      rethrow;
    }
  }

  Future<void> stopGeofencing() async {
    try {
      _locationSubscription?.cancel();
      _geofenceCheckTimer?.cancel();
      activeGeofences.clear();
      isGeofenceServiceActive.value = false;
      _logger.i('Geofence service stopped');
    } catch (e) {
      _logger.e('Stop geofencing error: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    _geofenceCheckTimer?.cancel();
    activeGeofences.clear();
    isGeofenceServiceActive.value = false;
    super.onClose();
  }
}

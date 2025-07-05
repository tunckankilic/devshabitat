import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/location/location_model.dart';
import '../../models/location/map_marker_model.dart';
import '../../services/location/maps_service.dart';
import 'package:location/location.dart';
import 'package:devshabitat/app/services/location/location_tracking_service.dart';
import 'package:permission_handler/permission_handler.dart';

class MapController extends GetxController {
  final MapsService _mapsService = Get.find<MapsService>();
  final LocationTrackingService _locationService;
  late GoogleMapController _mapController;

  final mapController = Rxn<GoogleMapController>();
  final currentLocation = Rxn<LocationModel>();
  final markers = <Marker>{}.obs;
  final selectedMarker = Rxn<MapMarkerModel>();
  final isLoading = false.obs;

  final mapStyle = ''.obs;
  final isDarkMode = false.obs;

  // Observable variables
  final currentPosition =
      const LatLng(41.0082, 28.9784).obs; // İstanbul merkezi
  final mapType = MapType.normal.obs;
  final showFilters = false.obs;
  final searchRadius = 10.0.obs;
  final showOnlineOnly = false.obs;
  final visibleDevelopers = <String>[].obs;
  final selectedCategories = <String>[].obs;
  final developerMarkers = <Marker>{}.obs;

  // Location settings
  final locationPermissionGranted = false.obs;
  final backgroundLocationEnabled = false.obs;
  final locationSharingEnabled = false.obs;
  final updateInterval = 15.obs; // seconds
  final locationAccuracy = 'balanced'.obs;
  final nearbyEventNotifications = true.obs;
  final nearbyDeveloperNotifications = true.obs;

  final locationNotificationsEnabled = false.obs;

  MapController({
    required LocationTrackingService locationService,
  }) : _locationService = locationService;

  @override
  void onInit() {
    super.onInit();
    _initializeMap();
    _checkLocationPermission();
    _initializeLocation();
    _startLocationUpdates();
  }

  @override
  void onClose() {
    mapController.value?.dispose();
    _mapController.dispose();
    super.onClose();
  }

  Future<void> _initializeMap() async {
    markers.value = _mapsService.markers;
    // Harita stilini yükle
    await _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    final style = isDarkMode.value
        ? 'assets/map_styles/dark_style.json'
        : 'assets/map_styles/light_style.json';

    try {
      mapStyle.value = await rootBundle.loadString(style);
      await mapController.value?.setMapStyle(mapStyle.value);
    } catch (e) {
      print('Harita stili yükleme hatası: $e');
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (mapStyle.value.isNotEmpty) {
      controller.setMapStyle(mapStyle.value);
    }
  }

  Future<void> animateToLocation(LocationModel location) async {
    final controller = mapController.value;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  Future<void> addMarker(MapMarkerModel marker) async {
    _mapsService.addMarker(marker);
    markers.value = _mapsService.markers;
  }

  void removeMarker(String markerId) {
    _mapsService.removeMarker(markerId);
    markers.value = _mapsService.markers;
  }

  void clearMarkers() {
    _mapsService.clearMarkers();
    markers.value = _mapsService.markers;
  }

  Future<void> toggleMapStyle() async {
    isDarkMode.value = !isDarkMode.value;
    await _loadMapStyle();
  }

  Future<String?> getAddressFromLocation(LocationModel location) async {
    return _mapsService.getAddressFromCoordinates(
      location.latitude,
      location.longitude,
    );
  }

  Future<LocationModel?> getLocationFromAddress(String address) async {
    return _mapsService.getCoordinatesFromAddress(address);
  }

  void onCameraMove(CameraPosition position) {
    currentPosition.value = position.target;
    _updateVisibleDevelopers();
  }

  void onMapTap(LatLng position) {
    // Haritaya tıklandığında filtreleri kapat
    if (showFilters.value) {
      showFilters.value = false;
    }
  }

  void zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }

  void centerOnUserLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      final latLng = LatLng(location.latitude!, location.longitude!);
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15),
      );
    }
  }

  void toggleMapType() {
    mapType.value =
        mapType.value == MapType.normal ? MapType.satellite : MapType.normal;
  }

  void toggleFilters() {
    showFilters.value = !showFilters.value;
  }

  void updateSearchRadius(double value) {
    searchRadius.value = value;
    _updateVisibleDevelopers();
  }

  void updateSelectedCategories(List<String> categories) {
    selectedCategories.value = categories;
    _updateVisibleDevelopers();
  }

  void toggleOnlineOnly(bool value) {
    showOnlineOnly.value = value;
    _updateVisibleDevelopers();
  }

  void refreshDevelopers() {
    _updateVisibleDevelopers();
  }

  Future<void> _initializeLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      currentPosition.value = LatLng(
        location.latitude!,
        location.longitude!,
      );
    }
  }

  void _startLocationUpdates() {
    _locationService.getLocationStream().listen((location) {
      if (location != null) {
        // Kullanıcının konumu değiştiğinde güncelle
        currentPosition.value = LatLng(
          location.latitude!,
          location.longitude!,
        );
        _updateVisibleDevelopers();
      }
    });
  }

  void _updateVisibleDevelopers() async {
    if (currentLocation.value == null) return;

    await filterAndCreateDeveloperMarkers();

    final nearbyDevelopers = await _locationService.getNearbyDevelopers(
      currentLocation.value!,
      searchRadius.value,
    );

    visibleDevelopers.value = nearbyDevelopers
        .where((dev) =>
            !selectedCategories.isNotEmpty ||
            dev.skills.any((skill) => selectedCategories.contains(skill)))
        .map((dev) => dev.id)
        .toList();
  }

  // Location permission methods
  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    locationPermissionGranted.value = status.isGranted;

    if (status.isGranted) {
      final backgroundStatus = await Permission.locationAlways.status;
      backgroundLocationEnabled.value = backgroundStatus.isGranted;
    }
  }

  Future<void> requestLocationPermission(bool value) async {
    if (value) {
      final status = await Permission.location.request();
      locationPermissionGranted.value = status.isGranted;
    } else {
      locationPermissionGranted.value = false;
      backgroundLocationEnabled.value = false;
    }
  }

  Future<void> toggleBackgroundLocation(bool value) async {
    if (value) {
      final status = await Permission.locationAlways.request();
      backgroundLocationEnabled.value = status.isGranted;
    } else {
      backgroundLocationEnabled.value = false;
    }
  }

  // Location sharing methods
  void toggleLocationSharing(bool value) async {
    locationSharingEnabled.value = value;
    if (value) {
      await shareLocation();
      _startLocationUpdates();
    } else {
      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser != null) {
        await _locationService.removeUserLocation(userId: currentUser.uid);
      }
    }
  }

  // Notification methods
  void toggleNearbyEventNotifications(bool value) async {
    nearbyEventNotifications.value = value;
    final currentUser = Get.find<AuthController>().currentUser;
    if (currentUser != null) {
      await _locationService.updateNotificationSettings(
          userId: currentUser.uid, enabled: value, notificationType: 'events');
    }
  }

  void toggleNearbyDeveloperNotifications(bool value) async {
    nearbyDeveloperNotifications.value = value;
    final currentUser = Get.find<AuthController>().currentUser;
    if (currentUser != null) {
      await _locationService.updateNotificationSettings(
          userId: currentUser.uid,
          enabled: value,
          notificationType: 'developers');
    }
  }

  Future<void> filterAndCreateDeveloperMarkers() async {
    try {
      final developers = await _locationService.getNearbyDevelopers(
        currentLocation.value!,
        searchRadius.value,
      );

      developerMarkers.clear();
      for (final dev in developers) {
        final marker = Marker(
          markerId: MarkerId(dev.id),
          position: LatLng(dev.location.latitude, dev.location.longitude),
          infoWindow: InfoWindow(
            title: dev.name,
            snippet: dev.skills.join(', '),
          ),
          onTap: () => navigateToProfile(dev.id),
        );
        developerMarkers.add(marker);
      }
    } catch (e) {
      print('Error creating developer markers: $e');
    }
  }

  Future<void> shareLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      final currentUser = Get.find<AuthController>().currentUser;
      if (position != null && currentUser != null) {
        await _locationService.updateUserLocation(
          userId: currentUser.uid,
          location: GeoPoint(position.latitude!, position.longitude!),
        );
        Get.snackbar('Başarılı', 'Konumunuz güncellendi');
      }
    } catch (e) {
      print('Error sharing location: $e');
      Get.snackbar('Hata', 'Konum paylaşılırken bir hata oluştu');
    }
  }

  Future<void> updateNotificationSettings({required bool enabled}) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser != null) {
        await _locationService.updateLocationNotificationSettings(
          userId: currentUser.uid,
          enabled: enabled,
        );
        locationNotificationsEnabled.value = enabled;
        Get.snackbar(
          'Başarılı',
          enabled
              ? 'Konum bildirimleri açıldı'
              : 'Konum bildirimleri kapatıldı',
        );
      }
    } catch (e) {
      print('Error updating notification settings: $e');
      Get.snackbar('Hata', 'Ayarlar güncellenirken bir hata oluştu');
    }
  }

  void navigateToProfile(String userId) {
    Get.toNamed('/profile/$userId');
  }
}

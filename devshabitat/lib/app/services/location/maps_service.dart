import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../../models/location/location_model.dart';
import '../../models/location/map_marker_model.dart';
import 'dart:math';

class MapsService extends GetxService {
  final markers = <Marker>{}.obs;
  final selectedLocation = Rxn<LocationModel>();

  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return null;
    } catch (e) {
      print('Adres çözümleme hatası: $e');
      return null;
    }
  }

  Future<LocationModel?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LocationModel(
          latitude: location.latitude,
          longitude: location.longitude,
          address: address,
        );
      }
      return null;
    } catch (e) {
      print('Koordinat çözümleme hatası: $e');
      return null;
    }
  }

  void addMarker(MapMarkerModel markerModel) {
    markers.add(markerModel.toMarker());
  }

  void removeMarker(String markerId) {
    markers.removeWhere((marker) => marker.markerId.value == markerId);
  }

  void clearMarkers() {
    markers.clear();
  }

  double calculateDistance(LocationModel start, LocationModel end) {
    // Haversine formülü ile mesafe hesaplama
    const double earthRadius = 6371; // km cinsinden
    final double lat1 = start.latitude * (pi / 180);
    final double lat2 = end.latitude * (pi / 180);
    final double deltaLat = (end.latitude - start.latitude) * (pi / 180);
    final double deltaLng = (end.longitude - start.longitude) * (pi / 180);

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}

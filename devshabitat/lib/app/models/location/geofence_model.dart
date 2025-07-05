import 'package:json_annotation/json_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

part 'geofence_model.g.dart';

@JsonSerializable()
class GeofenceModel {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final double radius; // metre cinsinden
  final List<String>? notifyUserIds;
  final bool isActive;

  const GeofenceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.notifyUserIds,
    this.isActive = true,
  });

  LatLng get center => LatLng(latitude, longitude);

  bool isPointInside(double lat, double lng) {
    const double earthRadius = 6371000; // metre cinsinden dünya yarıçapı

    final double lat1 = latitude * (pi / 180);
    final double lat2 = lat * (pi / 180);
    final double deltaLat = (lat - latitude) * (pi / 180);
    final double deltaLng = (lng - longitude) * (pi / 180);

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance <= radius;
  }

  factory GeofenceModel.fromJson(Map<String, dynamic> json) =>
      _$GeofenceModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeofenceModelToJson(this);
}

import 'package:json_annotation/json_annotation.dart';
import 'dart:math';
part 'geofence_model.g.dart';

@JsonSerializable()
class GeofenceModel {
  final String id;
  final double latitude;
  final double longitude;
  final double radius; // metre cinsinden
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;

  GeofenceModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.name,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.expiresAt,
  });

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

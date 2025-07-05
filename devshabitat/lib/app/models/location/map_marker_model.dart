import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_marker_model.g.dart';

enum MarkerCategory { user, event, community, place, custom }

@JsonSerializable()
class CustomMapMarker {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final MarkerCategory category;
  final String? iconPath;
  final Map<String, dynamic>? metadata;

  const CustomMapMarker({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.iconPath,
    this.metadata,
  });

  LatLng get position => LatLng(latitude, longitude);

  factory CustomMapMarker.fromJson(Map<String, dynamic> json) =>
      _$CustomMapMarkerFromJson(json);

  Map<String, dynamic> toJson() => _$CustomMapMarkerToJson(this);
}

class MapMarkerModel {
  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String snippet;

  MapMarkerModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.snippet = '',
  });

  Marker toMarker() {
    return Marker(
      markerId: MarkerId(id),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
    );
  }
}

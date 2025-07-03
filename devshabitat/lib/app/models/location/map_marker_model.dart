import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_marker_model.g.dart';

@JsonSerializable()
class MapMarkerModel {
  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String? snippet;
  @JsonKey(ignore: true)
  final BitmapDescriptor? icon;
  final bool isVisible;
  final bool isDraggable;

  MapMarkerModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.snippet,
    this.icon,
    this.isVisible = true,
    this.isDraggable = false,
  });

  Marker toMarker() {
    return Marker(
      markerId: MarkerId(id),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      icon: icon ?? BitmapDescriptor.defaultMarker,
      visible: isVisible,
      draggable: isDraggable,
    );
  }

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) =>
      _$MapMarkerModelFromJson(json);

  Map<String, dynamic> toJson() => _$MapMarkerModelToJson(this);
}

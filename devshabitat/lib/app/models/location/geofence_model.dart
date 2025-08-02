import 'package:json_annotation/json_annotation.dart';

part 'geofence_model.g.dart';

@JsonSerializable()
class GeofenceAction {
  final String type;
  final Map<String, dynamic>? data;

  GeofenceAction({
    required this.type,
    this.data,
  });

  factory GeofenceAction.fromJson(Map<String, dynamic> json) =>
      _$GeofenceActionFromJson(json);
  Map<String, dynamic> toJson() => _$GeofenceActionToJson(this);
}

@JsonSerializable()
class GeofenceModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double? radius;
  final List<GeofenceAction>? onEnterActions;
  final List<GeofenceAction>? onExitActions;
  final DateTime? expirationDate;
  final Map<String, dynamic>? metadata;

  @JsonKey(ignore: true)
  bool isInside = false;

  GeofenceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radius,
    this.onEnterActions,
    this.onExitActions,
    this.expirationDate,
    this.metadata,
  });

  factory GeofenceModel.fromJson(Map<String, dynamic> json) =>
      _$GeofenceModelFromJson(json);
  Map<String, dynamic> toJson() => _$GeofenceModelToJson(this);
}

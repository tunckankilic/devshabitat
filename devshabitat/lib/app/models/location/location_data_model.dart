import 'package:json_annotation/json_annotation.dart';
import 'package:location/location.dart';

part 'location_data_model.g.dart';

@JsonSerializable()
class LocationDataModel {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime? timestamp;

  LocationDataModel({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.timestamp,
  });

  factory LocationDataModel.fromLocationData(LocationData data) {
    return LocationDataModel(
      latitude: data.latitude ?? 0,
      longitude: data.longitude ?? 0,
      accuracy: data.accuracy,
      altitude: data.altitude,
      speed: data.speed,
      heading: data.heading,
      timestamp: data.time != null
          ? DateTime.fromMillisecondsSinceEpoch(data.time!.toInt())
          : null,
    );
  }

  factory LocationDataModel.fromJson(Map<String, dynamic> json) =>
      _$LocationDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDataModelToJson(this);
}

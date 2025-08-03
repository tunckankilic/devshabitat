import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
import 'location_data_model.dart';

part 'location_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class LocationModel extends HiveObject {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final double accuracy;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final double? speed;

  @HiveField(5)
  final double? heading;

  @HiveField(6)
  final double? altitude;

  @HiveField(7)
  final String? address;

  @HiveField(8)
  final String? userId;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.speed,
    this.heading,
    this.altitude,
    this.address,
    this.userId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);

  factory LocationModel.fromLocationData(LocationDataModel data) {
    return LocationModel(
      latitude: data.latitude,
      longitude: data.longitude,
      accuracy: data.accuracy ?? 0,
      timestamp: data.timestamp ?? DateTime.now(),
      speed: data.speed,
      heading: data.heading,
      altitude: data.altitude,
    );
  }

  LocationDataModel toLocationData() {
    return LocationDataModel(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      timestamp: timestamp,
    );
  }
}

class LocationModelAdapter extends TypeAdapter<LocationModel> {
  @override
  final int typeId = 1;

  @override
  LocationModel read(BinaryReader reader) {
    return LocationModel(
      latitude: reader.readDouble(),
      longitude: reader.readDouble(),
      accuracy: reader.readDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      speed: reader.readBool() ? reader.readDouble() : null,
      heading: reader.readBool() ? reader.readDouble() : null,
      altitude: reader.readBool() ? reader.readDouble() : null,
      address: reader.readBool() ? reader.readString() : null,
      userId: reader.readBool() ? reader.readString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, LocationModel obj) {
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
    writer.writeDouble(obj.accuracy);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.speed != null);
    if (obj.speed != null) writer.writeDouble(obj.speed!);
    writer.writeBool(obj.heading != null);
    if (obj.heading != null) writer.writeDouble(obj.heading!);
    writer.writeBool(obj.altitude != null);
    if (obj.altitude != null) writer.writeDouble(obj.altitude!);
    writer.writeBool(obj.address != null);
    if (obj.address != null) writer.writeString(obj.address!);
    writer.writeBool(obj.userId != null);
    if (obj.userId != null) writer.writeString(obj.userId!);
  }
}

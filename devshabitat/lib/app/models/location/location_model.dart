import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_data_model.dart';

class LocationModel {
  final String userId;
  final GeoPoint location;
  final double accuracy;
  final DateTime timestamp;
  final double speed;
  final double heading;
  final String? address;

  double get latitude => location.latitude;
  double get longitude => location.longitude;

  LocationModel({
    required this.userId,
    required this.location,
    required this.accuracy,
    required this.timestamp,
    required this.speed,
    required this.heading,
    this.address,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      userId: json['userId'] as String,
      location: json['location'] as GeoPoint,
      accuracy: (json['accuracy'] as num).toDouble(),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      speed: (json['speed'] as num).toDouble(),
      heading: (json['heading'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }

  factory LocationModel.fromLocationData(LocationDataModel data) {
    return LocationModel(
      userId:
          '', // Boş string olarak bırakıyoruz çünkü bu bilgi LocationDataModel'de yok
      location: GeoPoint(data.latitude, data.longitude),
      accuracy: data.accuracy ?? 0.0,
      timestamp: data.timestamp ?? DateTime.now(),
      speed: data.speed ?? 0.0,
      heading: data.heading ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'location': location,
      'accuracy': accuracy,
      'timestamp': Timestamp.fromDate(timestamp),
      'speed': speed,
      'heading': heading,
      'address': address,
    };
  }

  LocationDataModel toLocationData() {
    return LocationDataModel(
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: accuracy,
      speed: speed,
      heading: heading,
      timestamp: timestamp,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

class GeoPointConverter
    implements JsonConverter<GeoPoint?, Map<String, dynamic>?> {
  const GeoPointConverter();

  @override
  GeoPoint? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return GeoPoint(json['latitude'] as double, json['longitude'] as double);
  }

  @override
  Map<String, dynamic>? toJson(GeoPoint? geoPoint) {
    if (geoPoint == null) return null;
    return {
      'latitude': geoPoint.latitude,
      'longitude': geoPoint.longitude,
    };
  }
}

enum EventType { workshop, meetup, conference, hackathon, other }

enum EventLocation { online, offline }

@JsonSerializable()
class EventModel {
  final String id;
  final String title;
  final String description;
  final String organizerId;
  final EventType type;
  final EventLocation location;
  @GeoPointConverter()
  final GeoPoint? geoPoint;
  final String? coverImageUrl;
  final String? venueAddress;
  final String? onlineMeetingUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int participantLimit;
  final int currentParticipants;
  final List<String> categoryIds;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerId,
    required this.type,
    required this.location,
    this.geoPoint,
    this.coverImageUrl,
    this.venueAddress,
    this.onlineMeetingUrl,
    required this.startDate,
    required this.endDate,
    required this.participantLimit,
    this.currentParticipants = 0,
    required this.categoryIds,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      organizerId: data['organizerId'] ?? '',
      type: EventType.values[data['type'] ?? 0],
      location: EventLocation.values[data['location'] ?? 0],
      geoPoint: data['geoPoint'] as GeoPoint?,
      coverImageUrl: data['coverImageUrl'],
      venueAddress: data['venueAddress'],
      onlineMeetingUrl: data['onlineMeetingUrl'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      participantLimit: data['participantLimit'] ?? 0,
      currentParticipants: data['currentParticipants'] ?? 0,
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? organizerId,
    EventType? type,
    EventLocation? location,
    GeoPoint? geoPoint,
    String? coverImageUrl,
    String? venueAddress,
    String? onlineMeetingUrl,
    DateTime? startDate,
    DateTime? endDate,
    int? participantLimit,
    int? currentParticipants,
    List<String>? categoryIds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizerId: organizerId ?? this.organizerId,
      type: type ?? this.type,
      location: location ?? this.location,
      geoPoint: geoPoint ?? this.geoPoint,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      venueAddress: venueAddress ?? this.venueAddress,
      onlineMeetingUrl: onlineMeetingUrl ?? this.onlineMeetingUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participantLimit: participantLimit ?? this.participantLimit,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      categoryIds: categoryIds ?? this.categoryIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Etkinliğin başlayıp başlamadığını kontrol eden getter
  bool get isStarting {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  // Etkinliğin bitip bitmediğini kontrol eden getter
  bool get isEnding {
    return DateTime.now().isAfter(endDate);
  }
}

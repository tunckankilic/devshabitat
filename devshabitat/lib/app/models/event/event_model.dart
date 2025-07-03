import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

enum EventType { meetup, workshop, hackathon, conference }

enum EventLocation { online, offline }

@JsonSerializable()
class EventModel {
  final String id;
  final String title;
  final String description;
  final String organizerId;
  final EventType type;
  final EventLocation location;
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
    return EventModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? organizerId,
    EventType? type,
    EventLocation? location,
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
}

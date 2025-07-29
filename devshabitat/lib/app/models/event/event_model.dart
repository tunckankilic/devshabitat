import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { inPerson, online }

class EventModel {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final String? onlineMeetingUrl;
  final String? venueAddress;
  final DateTime startDate;
  final DateTime endDate;
  final int participantLimit;
  final List<String> categories;
  final List<String> participants;
  final String? communityId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final GeoPoint? location;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.onlineMeetingUrl,
    this.venueAddress,
    required this.startDate,
    required this.endDate,
    required this.participantLimit,
    required this.categories,
    required this.participants,
    this.communityId,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.location,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: EventType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => EventType.online,
      ),
      onlineMeetingUrl: map['onlineMeetingUrl'] as String?,
      venueAddress: map['venueAddress'] as String?,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      participantLimit: map['participantLimit'] as int,
      categories: List<String>.from(map['categories'] as List),
      participants: List<String>.from(map['participants'] as List? ?? []),
      communityId: map['communityId'] as String?,
      createdBy: map['createdBy'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      location: map['location'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.toString(),
      'onlineMeetingUrl': onlineMeetingUrl,
      'venueAddress': venueAddress,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'participantLimit': participantLimit,
      'categories': categories,
      'participants': participants,
      'communityId': communityId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'location': location,
    };
  }

  bool get isStarting =>
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(startDate.add(const Duration(minutes: 15)));

  bool get isEnding =>
      DateTime.now().isAfter(endDate.subtract(const Duration(minutes: 15))) &&
      DateTime.now().isBefore(endDate);

  bool get isFull => participants.length >= participantLimit;

  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  bool get hasEnded => DateTime.now().isAfter(endDate);

  bool get hasStarted => DateTime.now().isAfter(startDate);

  bool isParticipant(String userId) => participants.contains(userId);
}

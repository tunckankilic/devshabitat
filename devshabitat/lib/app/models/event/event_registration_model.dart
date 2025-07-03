import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_registration_model.g.dart';

enum RegistrationStatus { pending, approved, rejected, cancelled }

@JsonSerializable()
class EventRegistrationModel {
  final String id;
  final String eventId;
  final String userId;
  final RegistrationStatus status;
  final DateTime registrationDate;
  final String? rejectionReason;
  final DateTime? approvalDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventRegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    this.status = RegistrationStatus.pending,
    required this.registrationDate,
    this.rejectionReason,
    this.approvalDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventRegistrationModel.fromJson(Map<String, dynamic> json) =>
      _$EventRegistrationModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventRegistrationModelToJson(this);

  factory EventRegistrationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventRegistrationModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  EventRegistrationModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    RegistrationStatus? status,
    DateTime? registrationDate,
    String? rejectionReason,
    DateTime? approvalDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventRegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      registrationDate: registrationDate ?? this.registrationDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvalDate: approvalDate ?? this.approvalDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_registration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventRegistrationModel _$EventRegistrationModelFromJson(
        Map<String, dynamic> json) =>
    EventRegistrationModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      status:
          $enumDecodeNullable(_$RegistrationStatusEnumMap, json['status']) ??
              RegistrationStatus.pending,
      registrationDate: DateTime.parse(json['registrationDate'] as String),
      rejectionReason: json['rejectionReason'] as String?,
      approvalDate: json['approvalDate'] == null
          ? null
          : DateTime.parse(json['approvalDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EventRegistrationModelToJson(
        EventRegistrationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'userId': instance.userId,
      'status': _$RegistrationStatusEnumMap[instance.status]!,
      'registrationDate': instance.registrationDate.toIso8601String(),
      'rejectionReason': instance.rejectionReason,
      'approvalDate': instance.approvalDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RegistrationStatusEnumMap = {
  RegistrationStatus.pending: 'pending',
  RegistrationStatus.approved: 'approved',
  RegistrationStatus.rejected: 'rejected',
  RegistrationStatus.cancelled: 'cancelled',
};

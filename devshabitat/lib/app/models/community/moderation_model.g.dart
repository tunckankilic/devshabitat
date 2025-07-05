// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModerationModel _$ModerationModelFromJson(Map<String, dynamic> json) =>
    ModerationModel(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      contentId: json['contentId'] as String,
      contentType: $enumDecode(_$ContentTypeEnumMap, json['contentType']),
      reporterId: json['reporterId'] as String,
      moderatorId: json['moderatorId'] as String?,
      action: $enumDecodeNullable(_$ModerationActionEnumMap, json['action']),
      status: $enumDecode(_$ModerationStatusEnumMap, json['status']),
      reason: $enumDecode(_$ModerationReasonEnumMap, json['reason']),
      customReason: json['customReason'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ModerationModelToJson(ModerationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'communityId': instance.communityId,
      'contentId': instance.contentId,
      'contentType': _$ContentTypeEnumMap[instance.contentType]!,
      'reporterId': instance.reporterId,
      'moderatorId': instance.moderatorId,
      'action': _$ModerationActionEnumMap[instance.action],
      'status': _$ModerationStatusEnumMap[instance.status]!,
      'reason': _$ModerationReasonEnumMap[instance.reason]!,
      'customReason': instance.customReason,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$ContentTypeEnumMap = {
  ContentType.post: 'post',
  ContentType.comment: 'comment',
  ContentType.event: 'event',
  ContentType.resource: 'resource',
  ContentType.profile: 'profile',
};

const _$ModerationActionEnumMap = {
  ModerationAction.warn: 'warn',
  ModerationAction.delete: 'delete',
  ModerationAction.ban: 'ban',
  ModerationAction.mute: 'mute',
  ModerationAction.approve: 'approve',
  ModerationAction.reject: 'reject',
};

const _$ModerationStatusEnumMap = {
  ModerationStatus.pending: 'pending',
  ModerationStatus.approved: 'approved',
  ModerationStatus.rejected: 'rejected',
  ModerationStatus.deleted: 'deleted',
};

const _$ModerationReasonEnumMap = {
  ModerationReason.spam: 'spam',
  ModerationReason.harassment: 'harassment',
  ModerationReason.inappropriateContent: 'inappropriateContent',
  ModerationReason.violence: 'violence',
  ModerationReason.other: 'other',
};

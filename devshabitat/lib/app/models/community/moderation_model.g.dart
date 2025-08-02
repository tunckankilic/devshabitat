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
      reporterId: json['reporterId'] as String,
      contentType: $enumDecode(_$ContentTypeEnumMap, json['contentType']),
      category: json['category'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      status:
          $enumDecodeNullable(_$ModerationStatusEnumMap, json['status']) ??
          ModerationStatus.pending,
      reason:
          $enumDecodeNullable(_$ModerationReasonEnumMap, json['reason']) ??
          ModerationReason.other,
      customReason: json['customReason'] as String?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$ModerationModelToJson(ModerationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'communityId': instance.communityId,
      'contentId': instance.contentId,
      'reporterId': instance.reporterId,
      'contentType': _$ContentTypeEnumMap[instance.contentType]!,
      'category': instance.category,
      'description': instance.description,
      'tags': instance.tags,
      'attachments': instance.attachments,
      'metadata': instance.metadata,
      'status': _$ModerationStatusEnumMap[instance.status]!,
      'reason': _$ModerationReasonEnumMap[instance.reason]!,
      'customReason': instance.customReason,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };

const _$ContentTypeEnumMap = {
  ContentType.post: 'post',
  ContentType.comment: 'comment',
  ContentType.message: 'message',
  ContentType.profile: 'profile',
  ContentType.community: 'community',
  ContentType.event: 'event',
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_violation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleViolationModel _$RuleViolationModelFromJson(Map<String, dynamic> json) =>
    RuleViolationModel(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      ruleId: json['ruleId'] as String,
      userId: json['userId'] as String,
      contentId: json['contentId'] as String?,
      contentType: json['contentType'] as String?,
      reporterId: json['reporterId'] as String,
      moderatorId: json['moderatorId'] as String?,
      status: $enumDecode(_$ViolationStatusEnumMap, json['status']),
      action: $enumDecodeNullable(_$ViolationActionEnumMap, json['action']),
      description: json['description'] as String,
      evidence: json['evidence'] as Map<String, dynamic>,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$RuleViolationModelToJson(RuleViolationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'communityId': instance.communityId,
      'ruleId': instance.ruleId,
      'userId': instance.userId,
      'contentId': instance.contentId,
      'contentType': instance.contentType,
      'reporterId': instance.reporterId,
      'moderatorId': instance.moderatorId,
      'status': _$ViolationStatusEnumMap[instance.status]!,
      'action': _$ViolationActionEnumMap[instance.action],
      'description': instance.description,
      'evidence': instance.evidence,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$ViolationStatusEnumMap = {
  ViolationStatus.pending: 'pending',
  ViolationStatus.confirmed: 'confirmed',
  ViolationStatus.rejected: 'rejected',
  ViolationStatus.resolved: 'resolved',
};

const _$ViolationActionEnumMap = {
  ViolationAction.warning: 'warning',
  ViolationAction.mute: 'mute',
  ViolationAction.ban: 'ban',
  ViolationAction.deleteContent: 'deleteContent',
  ViolationAction.other: 'other',
};

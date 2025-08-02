// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleModel _$RuleModelFromJson(Map<String, dynamic> json) => RuleModel(
  id: json['id'] as String,
  communityId: json['communityId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$RuleCategoryEnumMap, json['category']),
  severity: $enumDecode(_$RuleSeverityEnumMap, json['severity']),
  enforcement: $enumDecode(_$RuleEnforcementEnumMap, json['enforcement']),
  keywords: (json['keywords'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  autoModConfig: json['autoModConfig'] as Map<String, dynamic>? ?? const {},
  isEnabled: json['isEnabled'] as bool? ?? true,
  priority: (json['priority'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  createdBy: json['createdBy'] as String,
  lastModifiedBy: json['lastModifiedBy'] as String?,
);

Map<String, dynamic> _$RuleModelToJson(RuleModel instance) => <String, dynamic>{
  'id': instance.id,
  'communityId': instance.communityId,
  'title': instance.title,
  'description': instance.description,
  'category': _$RuleCategoryEnumMap[instance.category]!,
  'severity': _$RuleSeverityEnumMap[instance.severity]!,
  'enforcement': _$RuleEnforcementEnumMap[instance.enforcement]!,
  'keywords': instance.keywords,
  'autoModConfig': instance.autoModConfig,
  'isEnabled': instance.isEnabled,
  'priority': instance.priority,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'createdBy': instance.createdBy,
  'lastModifiedBy': instance.lastModifiedBy,
};

const _$RuleCategoryEnumMap = {
  RuleCategory.general: 'general',
  RuleCategory.content: 'content',
  RuleCategory.behavior: 'behavior',
  RuleCategory.moderation: 'moderation',
  RuleCategory.privacy: 'privacy',
  RuleCategory.other: 'other',
};

const _$RuleSeverityEnumMap = {
  RuleSeverity.low: 'low',
  RuleSeverity.medium: 'medium',
  RuleSeverity.high: 'high',
  RuleSeverity.critical: 'critical',
};

const _$RuleEnforcementEnumMap = {
  RuleEnforcement.manual: 'manual',
  RuleEnforcement.automatic: 'automatic',
  RuleEnforcement.hybrid: 'hybrid',
};

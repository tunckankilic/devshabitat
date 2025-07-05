// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceModel _$ResourceModelFromJson(Map<String, dynamic> json) =>
    ResourceModel(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      authorId: json['authorId'] as String,
      type: $enumDecode(_$ResourceTypeEnumMap, json['type']),
      category: $enumDecode(_$ResourceCategoryEnumMap, json['category']),
      difficulty: $enumDecode(_$ResourceDifficultyEnumMap, json['difficulty']),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      isApproved: json['isApproved'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ResourceModelToJson(ResourceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'communityId': instance.communityId,
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'authorId': instance.authorId,
      'type': _$ResourceTypeEnumMap[instance.type]!,
      'category': _$ResourceCategoryEnumMap[instance.category]!,
      'difficulty': _$ResourceDifficultyEnumMap[instance.difficulty]!,
      'tags': instance.tags,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
      'views': instance.views,
      'isApproved': instance.isApproved,
      'isPinned': instance.isPinned,
      'isFeatured': instance.isFeatured,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$ResourceTypeEnumMap = {
  ResourceType.article: 'article',
  ResourceType.video: 'video',
  ResourceType.tutorial: 'tutorial',
  ResourceType.code: 'code',
  ResourceType.book: 'book',
  ResourceType.tool: 'tool',
  ResourceType.other: 'other',
};

const _$ResourceCategoryEnumMap = {
  ResourceCategory.frontend: 'frontend',
  ResourceCategory.backend: 'backend',
  ResourceCategory.mobile: 'mobile',
  ResourceCategory.devops: 'devops',
  ResourceCategory.design: 'design',
  ResourceCategory.database: 'database',
  ResourceCategory.security: 'security',
  ResourceCategory.testing: 'testing',
  ResourceCategory.architecture: 'architecture',
  ResourceCategory.other: 'other',
};

const _$ResourceDifficultyEnumMap = {
  ResourceDifficulty.beginner: 'beginner',
  ResourceDifficulty.intermediate: 'intermediate',
  ResourceDifficulty.advanced: 'advanced',
  ResourceDifficulty.expert: 'expert',
};

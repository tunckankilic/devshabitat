// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityModel _$CommunityModelFromJson(Map<String, dynamic> json) =>
    CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      creatorId: json['creatorId'] as String,
      moderatorIds: (json['moderatorIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      memberIds:
          (json['memberIds'] as List<dynamic>).map((e) => e as String).toList(),
      pendingMemberIds: (json['pendingMemberIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      settings: json['settings'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      eventCount: (json['eventCount'] as num?)?.toInt() ?? 0,
      postCount: (json['postCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CommunityModelToJson(CommunityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'creatorId': instance.creatorId,
      'moderatorIds': instance.moderatorIds,
      'memberIds': instance.memberIds,
      'pendingMemberIds': instance.pendingMemberIds,
      'settings': instance.settings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'memberCount': instance.memberCount,
      'eventCount': instance.eventCount,
      'postCount': instance.postCount,
    };

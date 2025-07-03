// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunitySettingsModel _$CommunitySettingsModelFromJson(
        Map<String, dynamic> json) =>
    CommunitySettingsModel(
      communityId: json['communityId'] as String,
      isPublic: json['isPublic'] as bool? ?? true,
      requiresApproval: json['requiresApproval'] as bool? ?? false,
      allowMemberPosts: json['allowMemberPosts'] as bool? ?? true,
      allowMemberEvents: json['allowMemberEvents'] as bool? ?? true,
      allowMemberInvites: json['allowMemberInvites'] as bool? ?? true,
      bannedUserIds: (json['bannedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notificationSettings:
          json['notificationSettings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CommunitySettingsModelToJson(
        CommunitySettingsModel instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'isPublic': instance.isPublic,
      'requiresApproval': instance.requiresApproval,
      'allowMemberPosts': instance.allowMemberPosts,
      'allowMemberEvents': instance.allowMemberEvents,
      'allowMemberInvites': instance.allowMemberInvites,
      'bannedUserIds': instance.bannedUserIds,
      'notificationSettings': instance.notificationSettings,
    };

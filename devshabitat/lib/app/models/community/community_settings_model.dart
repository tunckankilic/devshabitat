import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'community_settings_model.g.dart';

@JsonSerializable()
class CommunitySettingsModel {
  final String communityId;
  final bool isPublic;
  final bool requiresApproval;
  final bool allowMemberPosts;
  final bool allowMemberEvents;
  final bool allowMemberInvites;
  final List<String> bannedUserIds;
  final Map<String, dynamic> notificationSettings;

  CommunitySettingsModel({
    required this.communityId,
    this.isPublic = true,
    this.requiresApproval = false,
    this.allowMemberPosts = true,
    this.allowMemberEvents = true,
    this.allowMemberInvites = true,
    this.bannedUserIds = const [],
    this.notificationSettings = const {},
  });

  factory CommunitySettingsModel.fromJson(Map<String, dynamic> json) =>
      _$CommunitySettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommunitySettingsModelToJson(this);

  factory CommunitySettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunitySettingsModel.fromJson({
      'communityId': doc.id,
      ...data,
    });
  }

  CommunitySettingsModel copyWith({
    String? communityId,
    bool? isPublic,
    bool? requiresApproval,
    bool? allowMemberPosts,
    bool? allowMemberEvents,
    bool? allowMemberInvites,
    List<String>? bannedUserIds,
    Map<String, dynamic>? notificationSettings,
  }) {
    return CommunitySettingsModel(
      communityId: communityId ?? this.communityId,
      isPublic: isPublic ?? this.isPublic,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      allowMemberPosts: allowMemberPosts ?? this.allowMemberPosts,
      allowMemberEvents: allowMemberEvents ?? this.allowMemberEvents,
      allowMemberInvites: allowMemberInvites ?? this.allowMemberInvites,
      bannedUserIds: bannedUserIds ?? this.bannedUserIds,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}

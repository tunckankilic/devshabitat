import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'community_model.g.dart';

enum CommunityType { technology, city, interest }

enum CommunityCategory { flutter, react, python, other }

@JsonSerializable()
class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String? coverImageUrl;
  final String creatorId;
  final List<String> moderatorIds;
  final List<String> memberIds;
  final List<String> pendingMemberIds;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  @JsonKey(defaultValue: 0)
  final int memberCount;

  @JsonKey(defaultValue: 0)
  final int eventCount;

  @JsonKey(defaultValue: 0)
  final int postCount;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    this.coverImageUrl,
    required this.creatorId,
    required this.moderatorIds,
    required this.memberIds,
    required this.pendingMemberIds,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
    this.memberCount = 0,
    this.eventCount = 0,
    this.postCount = 0,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityModelToJson(this);

  factory CommunityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityModel(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      coverImageUrl: data['coverImageUrl'] as String?,
      creatorId: data['creatorId'] as String,
      moderatorIds: List<String>.from(data['moderatorIds'] ?? []),
      memberIds: List<String>.from(data['memberIds'] ?? []),
      pendingMemberIds: List<String>.from(data['pendingMemberIds'] ?? []),
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      memberCount: data['memberCount'] as int? ?? 0,
      eventCount: data['eventCount'] as int? ?? 0,
      postCount: data['postCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'creatorId': creatorId,
      'moderatorIds': moderatorIds,
      'memberIds': memberIds,
      'pendingMemberIds': pendingMemberIds,
      'settings': settings,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'memberCount': memberCount,
      'eventCount': eventCount,
      'postCount': postCount,
    };
  }

  bool isModerator(String userId) {
    return creatorId == userId || moderatorIds.contains(userId);
  }

  bool isMember(String userId) {
    return memberIds.contains(userId);
  }

  bool hasPendingRequest(String userId) {
    return pendingMemberIds.contains(userId);
  }

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    String? creatorId,
    List<String>? moderatorIds,
    List<String>? memberIds,
    List<String>? pendingMemberIds,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? memberCount,
    int? eventCount,
    int? postCount,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      creatorId: creatorId ?? this.creatorId,
      moderatorIds: moderatorIds ?? this.moderatorIds,
      memberIds: memberIds ?? this.memberIds,
      pendingMemberIds: pendingMemberIds ?? this.pendingMemberIds,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
      eventCount: eventCount ?? this.eventCount,
      postCount: postCount ?? this.postCount,
    );
  }
}

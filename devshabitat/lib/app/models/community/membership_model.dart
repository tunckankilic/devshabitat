import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'membership_model.g.dart';

enum MembershipRole { member, moderator, admin }

enum MembershipStatus { pending, active, blocked }

@JsonSerializable()
class MembershipModel {
  final String id;
  final String communityId;
  final String userId;
  final MembershipRole role;
  final MembershipStatus status;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;

  MembershipModel({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.lastActiveAt,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipModelFromJson(json);

  Map<String, dynamic> toJson() => _$MembershipModelToJson(this);

  factory MembershipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MembershipModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  MembershipModel copyWith({
    String? id,
    String? communityId,
    String? userId,
    MembershipRole? role,
    MembershipStatus? status,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
  }) {
    return MembershipModel(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

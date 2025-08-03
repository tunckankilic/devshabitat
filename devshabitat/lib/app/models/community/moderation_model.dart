import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'moderation_model.g.dart';

enum ContentType { post, comment, message, profile, community, event }

enum ModerationAction { warn, delete, ban, mute, approve, reject }

enum ModerationStatus { pending, approved, rejected, deleted }

enum ModerationReason {
  spam,
  harassment,
  inappropriateContent,
  violence,
  other,
}

@JsonSerializable()
class ModerationModel {
  final String id;
  final String communityId;
  final String contentId;
  final String reporterId;
  final ContentType contentType;
  final String category;
  final String description;
  final List<String> tags;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final ModerationStatus status;
  final ModerationReason reason;
  final String? customReason;
  final String? note;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  ModerationModel({
    required this.id,
    required this.communityId,
    required this.contentId,
    required this.reporterId,
    required this.contentType,
    required this.category,
    required this.description,
    required this.tags,
    required this.attachments,
    required this.metadata,
    this.status = ModerationStatus.pending,
    this.reason = ModerationReason.other,
    this.customReason,
    this.note,
    DateTime? createdAt,
    this.resolvedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ModerationModel.fromJson(Map<String, dynamic> json) =>
      _$ModerationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationModelToJson(this);

  factory ModerationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModerationModel.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toFirestore() {
    return {
      'communityId': communityId,
      'contentId': contentId,
      'contentType': contentType.toString(),
      'reporterId': reporterId,
      'moderatorId': null,
      'action': null,
      'status': status.toString(),
      'reason': reason.toString(),
      'customReason': customReason,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'metadata': metadata,
    };
  }

  ModerationModel copyWith({
    String? id,
    String? communityId,
    String? contentId,
    ContentType? contentType,
    String? reporterId,
    String? category,
    String? description,
    List<String>? tags,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    ModerationStatus? status,
    ModerationReason? reason,
    String? customReason,
    String? note,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return ModerationModel(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      reporterId: reporterId ?? this.reporterId,
      category: category ?? this.category,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      customReason: customReason ?? this.customReason,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

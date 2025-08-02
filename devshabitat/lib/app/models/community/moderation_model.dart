import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'moderation_model.g.dart';

enum ContentType {
  post,
  comment,
  message,
  profile,
  community,
  event,
}

enum ModerationAction {
  warn,
  delete,
  ban,
  mute,
  approve,
  reject,
}

enum ModerationStatus {
  pending,
  approved,
  rejected,
  deleted,
}

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
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory ModerationModel.fromJson(Map<String, dynamic> json) {
    return ModerationModel(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      contentId: json['contentId'] as String,
      reporterId: json['reporterId'] as String,
      contentType: ContentType.values.firstWhere(
        (e) => e.toString() == json['contentType'],
      ),
      category: json['category'] as String,
      description: json['description'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      status: ModerationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      reason: ModerationReason.values.firstWhere(
        (e) => e.toString() == json['reason'],
      ),
      customReason: json['customReason'] as String?,
      note: json['note'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      resolvedAt: (json['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'contentId': contentId,
      'reporterId': reporterId,
      'contentType': contentType.toString(),
      'category': category,
      'description': description,
      'tags': tags,
      'attachments': attachments,
      'metadata': metadata,
      'status': status.toString(),
      'reason': reason.toString(),
      'customReason': customReason,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  factory ModerationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModerationModel.fromJson({
      'id': doc.id,
      ...data,
    });
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

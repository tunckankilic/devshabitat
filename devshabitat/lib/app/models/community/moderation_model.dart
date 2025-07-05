import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'moderation_model.g.dart';

enum ContentType {
  post,
  comment,
  event,
  resource,
  profile,
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
  final ContentType contentType;
  final String reporterId;
  final String? moderatorId;
  final ModerationAction? action;
  final ModerationStatus status;
  final ModerationReason reason;
  final String? customReason;
  final String? note;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final Map<String, dynamic> metadata;

  ModerationModel({
    required this.id,
    required this.communityId,
    required this.contentId,
    required this.contentType,
    required this.reporterId,
    this.moderatorId,
    this.action,
    required this.status,
    required this.reason,
    this.customReason,
    this.note,
    required this.createdAt,
    this.resolvedAt,
    this.metadata = const {},
  });

  factory ModerationModel.fromJson(Map<String, dynamic> json) =>
      _$ModerationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationModelToJson(this);

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
      'moderatorId': moderatorId,
      'action': action?.toString(),
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
    String? moderatorId,
    ModerationAction? action,
    ModerationStatus? status,
    ModerationReason? reason,
    String? customReason,
    String? note,
    DateTime? createdAt,
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ModerationModel(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      reporterId: reporterId ?? this.reporterId,
      moderatorId: moderatorId ?? this.moderatorId,
      action: action ?? this.action,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      customReason: customReason ?? this.customReason,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

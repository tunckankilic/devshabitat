import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule_violation_model.g.dart';

enum ViolationStatus {
  pending,
  confirmed,
  rejected,
  resolved,
}

enum ViolationAction {
  warning,
  mute,
  ban,
  deleteContent,
  other,
}

@JsonSerializable()
class RuleViolationModel {
  final String id;
  final String communityId;
  final String ruleId;
  final String userId;
  final String? contentId;
  final String? contentType;
  final String reporterId;
  final String? moderatorId;
  final ViolationStatus status;
  final ViolationAction? action;
  final String description;
  final Map<String, dynamic> evidence;
  final String? note;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final Map<String, dynamic> metadata;

  RuleViolationModel({
    required this.id,
    required this.communityId,
    required this.ruleId,
    required this.userId,
    this.contentId,
    this.contentType,
    required this.reporterId,
    this.moderatorId,
    required this.status,
    this.action,
    required this.description,
    required this.evidence,
    this.note,
    required this.createdAt,
    this.resolvedAt,
    this.metadata = const {},
  });

  factory RuleViolationModel.fromJson(Map<String, dynamic> json) =>
      _$RuleViolationModelFromJson(json);

  Map<String, dynamic> toJson() => _$RuleViolationModelToJson(this);

  factory RuleViolationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RuleViolationModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    return {
      'communityId': communityId,
      'ruleId': ruleId,
      'userId': userId,
      'contentId': contentId,
      'contentType': contentType,
      'reporterId': reporterId,
      'moderatorId': moderatorId,
      'status': status.toString(),
      'action': action?.toString(),
      'description': description,
      'evidence': evidence,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'metadata': metadata,
    };
  }

  RuleViolationModel copyWith({
    String? id,
    String? communityId,
    String? ruleId,
    String? userId,
    String? contentId,
    String? contentType,
    String? reporterId,
    String? moderatorId,
    ViolationStatus? status,
    ViolationAction? action,
    String? description,
    Map<String, dynamic>? evidence,
    String? note,
    DateTime? createdAt,
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  }) {
    return RuleViolationModel(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      ruleId: ruleId ?? this.ruleId,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      reporterId: reporterId ?? this.reporterId,
      moderatorId: moderatorId ?? this.moderatorId,
      status: status ?? this.status,
      action: action ?? this.action,
      description: description ?? this.description,
      evidence: evidence ?? this.evidence,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  String get readableStatus {
    switch (status) {
      case ViolationStatus.pending:
        return 'Beklemede';
      case ViolationStatus.confirmed:
        return 'Onaylandı';
      case ViolationStatus.rejected:
        return 'Reddedildi';
      case ViolationStatus.resolved:
        return 'Çözüldü';
    }
  }

  String get readableAction {
    if (action == null) return 'Belirlenmedi';

    switch (action!) {
      case ViolationAction.warning:
        return 'Uyarı';
      case ViolationAction.mute:
        return 'Susturma';
      case ViolationAction.ban:
        return 'Yasaklama';
      case ViolationAction.deleteContent:
        return 'İçerik Silme';
      case ViolationAction.other:
        return 'Diğer';
    }
  }
}

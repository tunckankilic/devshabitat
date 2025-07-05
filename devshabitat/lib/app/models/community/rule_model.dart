import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule_model.g.dart';

enum RuleCategory {
  general,
  content,
  behavior,
  moderation,
  privacy,
  other,
}

enum RuleSeverity {
  low,
  medium,
  high,
  critical,
}

enum RuleEnforcement {
  manual,
  automatic,
  hybrid,
}

@JsonSerializable()
class RuleModel {
  final String id;
  final String communityId;
  final String title;
  final String description;
  final RuleCategory category;
  final RuleSeverity severity;
  final RuleEnforcement enforcement;
  final List<String> keywords;
  final Map<String, dynamic> autoModConfig;
  final bool isEnabled;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? lastModifiedBy;

  RuleModel({
    required this.id,
    required this.communityId,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.enforcement,
    required this.keywords,
    this.autoModConfig = const {},
    this.isEnabled = true,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.lastModifiedBy,
  });

  factory RuleModel.fromJson(Map<String, dynamic> json) =>
      _$RuleModelFromJson(json);

  Map<String, dynamic> toJson() => _$RuleModelToJson(this);

  factory RuleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RuleModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    return {
      'communityId': communityId,
      'title': title,
      'description': description,
      'category': category.toString(),
      'severity': severity.toString(),
      'enforcement': enforcement.toString(),
      'keywords': keywords,
      'autoModConfig': autoModConfig,
      'isEnabled': isEnabled,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'lastModifiedBy': lastModifiedBy,
    };
  }

  RuleModel copyWith({
    String? id,
    String? communityId,
    String? title,
    String? description,
    RuleCategory? category,
    RuleSeverity? severity,
    RuleEnforcement? enforcement,
    List<String>? keywords,
    Map<String, dynamic>? autoModConfig,
    bool? isEnabled,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? lastModifiedBy,
  }) {
    return RuleModel(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      enforcement: enforcement ?? this.enforcement,
      keywords: keywords ?? this.keywords,
      autoModConfig: autoModConfig ?? this.autoModConfig,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    );
  }

  String get readableCategory {
    switch (category) {
      case RuleCategory.general:
        return 'Genel';
      case RuleCategory.content:
        return 'İçerik';
      case RuleCategory.behavior:
        return 'Davranış';
      case RuleCategory.moderation:
        return 'Moderasyon';
      case RuleCategory.privacy:
        return 'Gizlilik';
      case RuleCategory.other:
        return 'Diğer';
    }
  }

  String get readableSeverity {
    switch (severity) {
      case RuleSeverity.low:
        return 'Düşük';
      case RuleSeverity.medium:
        return 'Orta';
      case RuleSeverity.high:
        return 'Yüksek';
      case RuleSeverity.critical:
        return 'Kritik';
    }
  }

  String get readableEnforcement {
    switch (enforcement) {
      case RuleEnforcement.manual:
        return 'Manuel';
      case RuleEnforcement.automatic:
        return 'Otomatik';
      case RuleEnforcement.hybrid:
        return 'Karma';
    }
  }
}

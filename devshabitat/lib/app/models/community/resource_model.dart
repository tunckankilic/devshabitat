import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'resource_model.g.dart';

enum ResourceType {
  article,
  video,
  tutorial,
  code,
  book,
  tool,
  other,
}

enum ResourceCategory {
  frontend,
  backend,
  mobile,
  devops,
  design,
  database,
  security,
  testing,
  architecture,
  other,
}

enum ResourceDifficulty {
  beginner,
  intermediate,
  advanced,
  expert,
}

@JsonSerializable()
class ResourceModel {
  final String id;
  final String communityId;
  final String title;
  final String description;
  final String url;
  final String authorId;
  final ResourceType type;
  final ResourceCategory category;
  final ResourceDifficulty difficulty;
  final List<String> tags;
  final int upvotes;
  final int downvotes;
  final int views;
  final bool isApproved;
  final bool isPinned;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  ResourceModel({
    required this.id,
    required this.communityId,
    required this.title,
    required this.description,
    required this.url,
    required this.authorId,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.tags,
    this.upvotes = 0,
    this.downvotes = 0,
    this.views = 0,
    this.isApproved = false,
    this.isPinned = false,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) =>
      _$ResourceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceModelToJson(this);

  factory ResourceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResourceModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    return {
      'communityId': communityId,
      'title': title,
      'description': description,
      'url': url,
      'authorId': authorId,
      'type': type.toString(),
      'category': category.toString(),
      'difficulty': difficulty.toString(),
      'tags': tags,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'views': views,
      'isApproved': isApproved,
      'isPinned': isPinned,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  ResourceModel copyWith({
    String? id,
    String? communityId,
    String? title,
    String? description,
    String? url,
    String? authorId,
    ResourceType? type,
    ResourceCategory? category,
    ResourceDifficulty? difficulty,
    List<String>? tags,
    int? upvotes,
    int? downvotes,
    int? views,
    bool? isApproved,
    bool? isPinned,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ResourceModel(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      authorId: authorId ?? this.authorId,
      type: type ?? this.type,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      views: views ?? this.views,
      isApproved: isApproved ?? this.isApproved,
      isPinned: isPinned ?? this.isPinned,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  double get score {
    if (upvotes == 0 && downvotes == 0) return 0;
    return (upvotes - downvotes) / (upvotes + downvotes);
  }

  bool get isPopular => views > 100 && score > 0.7;

  bool get isTrending => views > 50 && score > 0.5;

  String get readableType {
    switch (type) {
      case ResourceType.article:
        return 'Makale';
      case ResourceType.video:
        return 'Video';
      case ResourceType.tutorial:
        return 'Eğitim';
      case ResourceType.code:
        return 'Kod';
      case ResourceType.book:
        return 'Kitap';
      case ResourceType.tool:
        return 'Araç';
      case ResourceType.other:
        return 'Diğer';
    }
  }

  String get readableCategory {
    switch (category) {
      case ResourceCategory.frontend:
        return 'Frontend';
      case ResourceCategory.backend:
        return 'Backend';
      case ResourceCategory.mobile:
        return 'Mobil';
      case ResourceCategory.devops:
        return 'DevOps';
      case ResourceCategory.design:
        return 'Tasarım';
      case ResourceCategory.database:
        return 'Veritabanı';
      case ResourceCategory.security:
        return 'Güvenlik';
      case ResourceCategory.testing:
        return 'Test';
      case ResourceCategory.architecture:
        return 'Mimari';
      case ResourceCategory.other:
        return 'Diğer';
    }
  }

  String get readableDifficulty {
    switch (difficulty) {
      case ResourceDifficulty.beginner:
        return 'Başlangıç';
      case ResourceDifficulty.intermediate:
        return 'Orta';
      case ResourceDifficulty.advanced:
        return 'İleri';
      case ResourceDifficulty.expert:
        return 'Uzman';
    }
  }
}

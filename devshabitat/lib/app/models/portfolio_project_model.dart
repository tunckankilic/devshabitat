import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioProjectModel {
  final String? id;
  final String? userId;
  final String title;
  final String description;
  final List<String> technologies;
  final String? repositoryUrl;
  final String? liveUrl;
  final List<String> images;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFeatured;
  final String status; // 'completed', 'in-progress', 'planned'
  final List<String> tags;
  final String? category;

  PortfolioProjectModel({
    this.id,
    this.userId,
    required this.title,
    required this.description,
    this.technologies = const [],
    this.repositoryUrl,
    this.liveUrl,
    this.images = const [],
    required this.createdAt,
    this.updatedAt,
    this.isFeatured = false,
    this.status = 'completed',
    this.tags = const [],
    this.category,
  });

  factory PortfolioProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PortfolioProjectModel(
      id: doc.id,
      userId: data['userId'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      technologies: List<String>.from(data['technologies'] ?? []),
      repositoryUrl: data['repositoryUrl'],
      liveUrl: data['liveUrl'],
      images: List<String>.from(data['images'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isFeatured: data['isFeatured'] ?? false,
      status: data['status'] ?? 'completed',
      tags: List<String>.from(data['tags'] ?? []),
      category: data['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      'title': title,
      'description': description,
      'technologies': technologies,
      'repositoryUrl': repositoryUrl,
      'liveUrl': liveUrl,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isFeatured': isFeatured,
      'status': status,
      'tags': tags,
      'category': category,
    };
  }

  PortfolioProjectModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? technologies,
    String? repositoryUrl,
    String? liveUrl,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFeatured,
    String? status,
    List<String>? tags,
    String? category,
  }) {
    return PortfolioProjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_category_model.g.dart';

@JsonSerializable()
class EventCategoryModel {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$EventCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventCategoryModelToJson(this);

  factory EventCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventCategoryModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  EventCategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

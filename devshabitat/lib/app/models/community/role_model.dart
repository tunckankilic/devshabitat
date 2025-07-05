import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'role_model.g.dart';

enum RolePermission {
  // Temel izinler
  viewContent,
  createContent,
  editOwnContent,
  deleteOwnContent,

  // Moderasyon izinleri
  moderateContent,
  banUsers,
  manageRoles,

  // Yönetim izinleri
  manageSettings,
  manageRules,
  manageResources,

  // Özel izinler
  createEvents,
  pinContent,
  assignRoles,
  viewAnalytics,

  // Yeni eklenen izinler
  manageMembers,
  deleteContent
}

@JsonSerializable()
class RoleModel {
  final String id;
  final String communityId;
  final String name;
  final String description;
  final int priority;
  final List<RolePermission> permissions;
  final Map<String, dynamic> customAttributes;
  final String? color;
  final String? icon;
  final bool isDefault;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoleModel({
    required this.id,
    required this.communityId,
    required this.name,
    required this.description,
    required this.priority,
    required this.permissions,
    this.customAttributes = const {},
    this.color,
    this.icon,
    this.isDefault = false,
    this.isSystem = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoleModelToJson(this);

  factory RoleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoleModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    return {
      'communityId': communityId,
      'name': name,
      'description': description,
      'priority': priority,
      'permissions': permissions.map((p) => p.toString()).toList(),
      'customAttributes': customAttributes,
      'color': color,
      'icon': icon,
      'isDefault': isDefault,
      'isSystem': isSystem,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool hasPermission(RolePermission permission) {
    return permissions.contains(permission);
  }

  bool hasAnyPermission(List<RolePermission> requiredPermissions) {
    return permissions.any((p) => requiredPermissions.contains(p));
  }

  bool hasAllPermissions(List<RolePermission> requiredPermissions) {
    return requiredPermissions.every((p) => permissions.contains(p));
  }

  RoleModel copyWith({
    String? id,
    String? communityId,
    String? name,
    String? description,
    int? priority,
    List<RolePermission>? permissions,
    Map<String, dynamic>? customAttributes,
    String? color,
    String? icon,
    bool? isDefault,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoleModel(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      name: name ?? this.name,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      permissions: permissions ?? this.permissions,
      customAttributes: customAttributes ?? this.customAttributes,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoleModel _$RoleModelFromJson(Map<String, dynamic> json) => RoleModel(
  id: json['id'] as String,
  communityId: json['communityId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  priority: (json['priority'] as num).toInt(),
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => $enumDecode(_$RolePermissionEnumMap, e))
      .toList(),
  customAttributes:
      json['customAttributes'] as Map<String, dynamic>? ?? const {},
  color: json['color'] as String?,
  icon: json['icon'] as String?,
  isDefault: json['isDefault'] as bool? ?? false,
  isSystem: json['isSystem'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RoleModelToJson(RoleModel instance) => <String, dynamic>{
  'id': instance.id,
  'communityId': instance.communityId,
  'name': instance.name,
  'description': instance.description,
  'priority': instance.priority,
  'permissions': instance.permissions
      .map((e) => _$RolePermissionEnumMap[e]!)
      .toList(),
  'customAttributes': instance.customAttributes,
  'color': instance.color,
  'icon': instance.icon,
  'isDefault': instance.isDefault,
  'isSystem': instance.isSystem,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$RolePermissionEnumMap = {
  RolePermission.viewContent: 'viewContent',
  RolePermission.createContent: 'createContent',
  RolePermission.editOwnContent: 'editOwnContent',
  RolePermission.deleteOwnContent: 'deleteOwnContent',
  RolePermission.moderateContent: 'moderateContent',
  RolePermission.banUsers: 'banUsers',
  RolePermission.manageRoles: 'manageRoles',
  RolePermission.manageSettings: 'manageSettings',
  RolePermission.manageRules: 'manageRules',
  RolePermission.manageResources: 'manageResources',
  RolePermission.createEvents: 'createEvents',
  RolePermission.pinContent: 'pinContent',
  RolePermission.assignRoles: 'assignRoles',
  RolePermission.viewAnalytics: 'viewAnalytics',
  RolePermission.manageMembers: 'manageMembers',
  RolePermission.deleteContent: 'deleteContent',
};

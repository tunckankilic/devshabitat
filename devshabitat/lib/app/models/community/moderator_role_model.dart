import 'package:cloud_firestore/cloud_firestore.dart';

enum ModeratorLevel {
  junior,
  senior,
  admin,
}

class ModeratorPermission {
  static const String deleteContent = 'delete_content';
  static const String banUser = 'ban_user';
  static const String manageRoles = 'manage_roles';
  static const String manageSettings = 'manage_settings';
  static const String viewAnalytics = 'view_analytics';
  static const String manageReports = 'manage_reports';
  static const String createAnnouncement = 'create_announcement';
  static const String pinContent = 'pin_content';
}

class ModeratorRoleModel {
  final String id;
  final String communityId;
  final String userId;
  final ModeratorLevel level;
  final List<String> permissions;
  final DateTime assignedAt;
  final String? assignedBy;
  final Map<String, dynamic> metadata;

  ModeratorRoleModel({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.level,
    required this.permissions,
    required this.assignedAt,
    this.assignedBy,
    this.metadata = const {},
  });

  factory ModeratorRoleModel.fromJson(Map<String, dynamic> json) {
    return ModeratorRoleModel(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      userId: json['userId'] as String,
      level: ModeratorLevel.values.firstWhere(
        (e) => e.toString() == 'ModeratorLevel.${json['level']}',
      ),
      permissions: List<String>.from(json['permissions'] ?? []),
      assignedAt: (json['assignedAt'] as Timestamp).toDate(),
      assignedBy: json['assignedBy'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'userId': userId,
      'level': level.toString().split('.').last,
      'permissions': permissions,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'assignedBy': assignedBy,
      'metadata': metadata,
    };
  }

  // Varsayılan izinleri al
  static List<String> getDefaultPermissions(ModeratorLevel level) {
    switch (level) {
      case ModeratorLevel.junior:
        return [
          ModeratorPermission.viewAnalytics,
          ModeratorPermission.manageReports,
          ModeratorPermission.pinContent,
        ];
      case ModeratorLevel.senior:
        return [
          ...getDefaultPermissions(ModeratorLevel.junior),
          ModeratorPermission.deleteContent,
          ModeratorPermission.banUser,
          ModeratorPermission.createAnnouncement,
        ];
      case ModeratorLevel.admin:
        return [
          ...getDefaultPermissions(ModeratorLevel.senior),
          ModeratorPermission.manageRoles,
          ModeratorPermission.manageSettings,
        ];
    }
  }

  // İzin kontrolü
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  // Birden fazla izin kontrolü
  bool hasPermissions(List<String> requiredPermissions) {
    return requiredPermissions.every((permission) => hasPermission(permission));
  }
}

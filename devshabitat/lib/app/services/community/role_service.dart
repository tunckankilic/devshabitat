import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../models/community/role_model.dart';

class RoleService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Varsayılan roller
  static const String ADMIN_ROLE = 'admin';
  static const String MODERATOR_ROLE = 'moderator';
  static const String MEMBER_ROLE = 'member';

  // Rol koleksiyonunu al
  CollectionReference<Map<String, dynamic>> _getRolesCollection(
      String communityId) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('roles');
  }

  // Üye rolleri koleksiyonunu al
  CollectionReference<Map<String, dynamic>> _getMemberRolesCollection(
      String communityId) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('member_roles');
  }

  // Yeni rol oluştur
  Future<RoleModel> createRole(RoleModel role) async {
    final doc = await _getRolesCollection(role.communityId).add(
      role.toFirestore(),
    );

    return role.copyWith(id: doc.id);
  }

  // Rolü güncelle
  Future<void> updateRole(RoleModel role) async {
    await _getRolesCollection(role.communityId)
        .doc(role.id)
        .update(role.toFirestore());
  }

  // Rolü sil
  Future<void> deleteRole(String communityId, String roleId) async {
    // Önce bu role sahip üyelerin rollerini varsayılan üye rolüne çevir
    final memberRoles = await _getMemberRolesCollection(communityId)
        .where('roleId', isEqualTo: roleId)
        .get();

    final batch = _firestore.batch();

    for (var doc in memberRoles.docs) {
      batch.update(doc.reference, {'roleId': MEMBER_ROLE});
    }

    // Rolü sil
    batch.delete(_getRolesCollection(communityId).doc(roleId));

    await batch.commit();
  }

  // Topluluğun tüm rollerini getir
  Future<List<RoleModel>> getCommunityRoles(String communityId) async {
    final snapshot = await _getRolesCollection(communityId)
        .orderBy('priority', descending: true)
        .get();

    return snapshot.docs.map((doc) => RoleModel.fromFirestore(doc)).toList();
  }

  // Üyenin rollerini getir
  Future<List<RoleModel>> getMemberRoles(
      String communityId, String userId) async {
    final snapshot = await _getMemberRolesCollection(communityId)
        .where('userId', isEqualTo: userId)
        .get();

    final roleIds =
        snapshot.docs.map((doc) => doc.data()['roleId'] as String).toList();

    if (roleIds.isEmpty) return [];

    final rolesSnapshot = await _getRolesCollection(communityId)
        .where(FieldPath.documentId, whereIn: roleIds)
        .get();

    return rolesSnapshot.docs
        .map((doc) => RoleModel.fromFirestore(doc))
        .toList();
  }

  // Üyeye rol ata
  Future<void> assignRole(
      String communityId, String userId, String roleId) async {
    await _getMemberRolesCollection(communityId).doc('$userId-$roleId').set({
      'userId': userId,
      'roleId': roleId,
      'assignedAt': FieldValue.serverTimestamp(),
    });
  }

  // Üyeden rol kaldır
  Future<void> removeRole(
      String communityId, String userId, String roleId) async {
    await _getMemberRolesCollection(communityId)
        .doc('$userId-$roleId')
        .delete();
  }

  // Üyenin belirli bir role sahip olup olmadığını kontrol et
  Future<bool> hasRole(String communityId, String userId, String roleId) async {
    final doc = await _getMemberRolesCollection(communityId)
        .doc('$userId-$roleId')
        .get();
    return doc.exists;
  }

  // Üyenin belirli bir izne sahip olup olmadığını kontrol et
  Future<bool> hasPermission(
      String communityId, String userId, RolePermission permission) async {
    final roles = await getMemberRoles(communityId, userId);
    return roles.any((role) => role.hasPermission(permission));
  }

  // Üyenin izinlerini getir
  Future<Set<RolePermission>> getMemberPermissions(
      String communityId, String userId) async {
    final roles = await getMemberRoles(communityId, userId);
    return roles.fold<Set<RolePermission>>(
      {},
      (permissions, role) => permissions..addAll(role.permissions),
    );
  }

  // Varsayılan topluluk rollerini oluştur
  Future<void> createDefaultCommunityRoles(String communityId) async {
    final now = DateTime.now();

    // Admin rolü
    final adminRole = RoleModel(
      id: ADMIN_ROLE,
      communityId: communityId,
      name: 'Admin',
      description: 'Topluluk yöneticisi',
      priority: 100,
      permissions: RolePermission.values.toList(),
      color: '#FF0000',
      icon: 'admin_icon',
      isDefault: false,
      isSystem: true,
      createdAt: now,
      updatedAt: now,
    );

    // Moderatör rolü
    final moderatorRole = RoleModel(
      id: MODERATOR_ROLE,
      communityId: communityId,
      name: 'Moderatör',
      description: 'Topluluk moderatörü',
      priority: 50,
      permissions: [
        RolePermission.viewContent,
        RolePermission.createContent,
        RolePermission.editOwnContent,
        RolePermission.deleteOwnContent,
        RolePermission.moderateContent,
        RolePermission.banUsers,
        RolePermission.createEvents,
        RolePermission.pinContent,
      ],
      color: '#00FF00',
      icon: 'moderator_icon',
      isDefault: false,
      isSystem: true,
      createdAt: now,
      updatedAt: now,
    );

    // Üye rolü
    final memberRole = RoleModel(
      id: MEMBER_ROLE,
      communityId: communityId,
      name: 'Üye',
      description: 'Topluluk üyesi',
      priority: 1,
      permissions: [
        RolePermission.viewContent,
        RolePermission.createContent,
        RolePermission.editOwnContent,
        RolePermission.deleteOwnContent,
      ],
      color: '#0000FF',
      icon: 'member_icon',
      isDefault: true,
      isSystem: true,
      createdAt: now,
      updatedAt: now,
    );

    final batch = _firestore.batch();

    // Rolleri oluştur
    batch.set(_getRolesCollection(communityId).doc(ADMIN_ROLE),
        adminRole.toFirestore());
    batch.set(_getRolesCollection(communityId).doc(MODERATOR_ROLE),
        moderatorRole.toFirestore());
    batch.set(_getRolesCollection(communityId).doc(MEMBER_ROLE),
        memberRole.toFirestore());

    await batch.commit();
  }

  // Rol hiyerarşisini kontrol et
  Future<bool> canManageRole(
      String communityId, String userId, String targetRoleId) async {
    final userRoles = await getMemberRoles(communityId, userId);
    final targetRole = await _getRolesCollection(communityId)
        .doc(targetRoleId)
        .get()
        .then((doc) => RoleModel.fromFirestore(doc));

    // En yüksek öncelikli kullanıcı rolünü bul
    final userMaxPriority = userRoles.fold(
        0, (max, role) => role.priority > max ? role.priority : max);

    // Kullanıcı hedef rolden daha yüksek önceliğe sahip olmalı
    return userMaxPriority > targetRole.priority;
  }
}

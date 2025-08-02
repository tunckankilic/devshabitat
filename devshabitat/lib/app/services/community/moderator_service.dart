import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../models/community/moderator_role_model.dart';

class ModeratorService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'communities';

  // Moderatör koleksiyonunu al
  CollectionReference<Map<String, dynamic>> _getModeratorCollection(
      String communityId) {
    return _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('moderators');
  }

  // Moderatör rolü ata
  Future<void> assignModeratorRole({
    required String communityId,
    required String userId,
    required ModeratorLevel level,
    String? assignedBy,
    List<String>? customPermissions,
  }) async {
    final permissions =
        customPermissions ?? ModeratorRoleModel.getDefaultPermissions(level);

    final moderator = ModeratorRoleModel(
      id: '',
      communityId: communityId,
      userId: userId,
      level: level,
      permissions: permissions,
      assignedAt: DateTime.now(),
      assignedBy: assignedBy,
      metadata: {
        'lastUpdated': FieldValue.serverTimestamp(),
      },
    );

    await _getModeratorCollection(communityId).add(moderator.toJson());

    // Aksiyon logu oluştur
    await _createModeratorActionLog(
      communityId: communityId,
      actionType: 'role_assigned',
      targetUserId: userId,
      performedBy: assignedBy,
      metadata: {
        'level': level.toString(),
        'permissions': permissions,
      },
    );
  }

  // Moderatör rolünü güncelle
  Future<void> updateModeratorRole({
    required String communityId,
    required String userId,
    ModeratorLevel? newLevel,
    List<String>? newPermissions,
    String? updatedBy,
  }) async {
    final moderatorDoc = await _getModeratorCollection(communityId)
        .where('userId', isEqualTo: userId)
        .get();

    if (moderatorDoc.docs.isEmpty) {
      throw Exception('Moderatör bulunamadı');
    }

    final currentRole = ModeratorRoleModel.fromJson({
      ...moderatorDoc.docs.first.data(),
      'id': moderatorDoc.docs.first.id,
    });

    final updatedPermissions = newPermissions ??
        (newLevel != null
            ? ModeratorRoleModel.getDefaultPermissions(newLevel)
            : currentRole.permissions);

    await moderatorDoc.docs.first.reference.update({
      if (newLevel != null) 'level': newLevel.toString().split('.').last,
      'permissions': updatedPermissions,
      'metadata': {
        ...currentRole.metadata,
        'lastUpdated': FieldValue.serverTimestamp(),
        'updatedBy': updatedBy,
      },
    });

    // Aksiyon logu oluştur
    await _createModeratorActionLog(
      communityId: communityId,
      actionType: 'role_updated',
      targetUserId: userId,
      performedBy: updatedBy,
      metadata: {
        if (newLevel != null) 'newLevel': newLevel.toString(),
        'newPermissions': updatedPermissions,
      },
    );
  }

  // Moderatör rolünü kaldır
  Future<void> removeModeratorRole({
    required String communityId,
    required String userId,
    String? removedBy,
  }) async {
    final moderatorDoc = await _getModeratorCollection(communityId)
        .where('userId', isEqualTo: userId)
        .get();

    if (moderatorDoc.docs.isEmpty) {
      throw Exception('Moderatör bulunamadı');
    }

    await moderatorDoc.docs.first.reference.delete();

    // Aksiyon logu oluştur
    await _createModeratorActionLog(
      communityId: communityId,
      actionType: 'role_removed',
      targetUserId: userId,
      performedBy: removedBy,
    );
  }

  // Moderatör bilgilerini getir
  Future<ModeratorRoleModel?> getModeratorRole({
    required String communityId,
    required String userId,
  }) async {
    final moderatorDoc = await _getModeratorCollection(communityId)
        .where('userId', isEqualTo: userId)
        .get();

    if (moderatorDoc.docs.isEmpty) {
      return null;
    }

    return ModeratorRoleModel.fromJson({
      ...moderatorDoc.docs.first.data(),
      'id': moderatorDoc.docs.first.id,
    });
  }

  // Topluluğun tüm moderatörlerini getir
  Future<List<ModeratorRoleModel>> getCommunityModerators(
      String communityId) async {
    final moderatorDocs = await _getModeratorCollection(communityId).get();

    return moderatorDocs.docs.map((doc) {
      return ModeratorRoleModel.fromJson({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
  }

  // İzin kontrolü
  Future<bool> hasPermission({
    required String communityId,
    required String userId,
    required String permission,
  }) async {
    final moderator = await getModeratorRole(
      communityId: communityId,
      userId: userId,
    );

    return moderator?.hasPermission(permission) ?? false;
  }

  // Birden fazla izin kontrolü
  Future<bool> hasPermissions({
    required String communityId,
    required String userId,
    required List<String> permissions,
  }) async {
    final moderator = await getModeratorRole(
      communityId: communityId,
      userId: userId,
    );

    return moderator?.hasPermissions(permissions) ?? false;
  }

  // Moderatör aksiyon logu oluştur
  Future<void> _createModeratorActionLog({
    required String communityId,
    required String actionType,
    required String targetUserId,
    String? performedBy,
    Map<String, dynamic> metadata = const {},
  }) async {
    await _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('moderator_logs')
        .add({
      'actionType': actionType,
      'targetUserId': targetUserId,
      'performedBy': performedBy,
      'timestamp': FieldValue.serverTimestamp(),
      'metadata': metadata,
    });
  }

  // Moderatör aksiyon loglarını getir
  Future<List<Map<String, dynamic>>> getModeratorActionLogs({
    required String communityId,
    String? userId,
    String? actionType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    var query = _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('moderator_logs')
        .orderBy('timestamp', descending: true);

    if (userId != null) {
      query = query.where('targetUserId', isEqualTo: userId);
    }

    if (actionType != null) {
      query = query.where('actionType', isEqualTo: actionType);
    }

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: endDate);
    }

    query = query.limit(limit);

    final logs = await query.get();
    return logs.docs.map((doc) => doc.data()).toList();
  }
}

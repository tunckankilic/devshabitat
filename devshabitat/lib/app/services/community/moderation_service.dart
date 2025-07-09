import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/community/membership_model.dart';
import 'package:devshabitat/app/services/community/membership_service.dart';
import 'package:get/get.dart';
import '../../models/community/moderation_model.dart';
import '../../models/community/role_model.dart';
import '../../services/community/role_service.dart';

class ModerationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'communities';
  final MembershipService _membershipService = MembershipService();
  final RoleService _roleService = Get.find<RoleService>();

  // Check if user has moderation rights
  Future<bool> canModerate({
    required String communityId,
    required String userId,
  }) async {
    final membership = await _membershipService.getMemberStatus(
      communityId: communityId,
      userId: userId,
    );

    return membership?.role == MembershipRole.admin ||
        membership?.role == MembershipRole.moderator;
  }

  // Moderasyon koleksiyonunu al
  CollectionReference<Map<String, dynamic>> _getModerationCollection(
      String communityId) {
    return _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('moderation');
  }

  // İçerik raporla
  Future<void> reportContent({
    required String communityId,
    required String contentId,
    required String reporterId,
    required ContentType contentType,
    required ModerationReason reason,
    String? customReason,
    String? note,
    Map<String, dynamic> metadata = const {},
  }) async {
    final moderation = ModerationModel(
      id: '',
      communityId: communityId,
      contentId: contentId,
      contentType: contentType,
      reporterId: reporterId,
      status: ModerationStatus.pending,
      reason: reason,
      customReason: customReason,
      note: note,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    await _getModerationCollection(communityId).add(moderation.toFirestore());
  }

  // Moderasyon işlemi uygula
  Future<void> moderateContent({
    required String communityId,
    required String moderationId,
    required String moderatorId,
    required ModerationAction action,
    String? note,
  }) async {
    // Moderatör yetkisini kontrol et
    final hasPermission = await _roleService.hasPermission(
      communityId,
      moderatorId,
      RolePermission.moderateContent,
    );

    if (!hasPermission) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    final doc =
        await _getModerationCollection(communityId).doc(moderationId).get();
    if (!doc.exists) {
      throw Exception('Moderasyon kaydı bulunamadı');
    }

    final moderation = ModerationModel.fromFirestore(doc);
    final updatedModeration = moderation.copyWith(
      moderatorId: moderatorId,
      action: action,
      status: _getStatusFromAction(action),
      resolvedAt: DateTime.now(),
      note: note,
    );

    await _getModerationCollection(communityId)
        .doc(moderationId)
        .update(updatedModeration.toFirestore());

    // Moderasyon aksiyonunu uygula
    await _applyModerationAction(updatedModeration);
  }

  // Moderasyon durumunu güncelle
  Future<void> updateModerationStatus({
    required String communityId,
    required String moderationId,
    required ModerationStatus status,
    String? note,
  }) async {
    await _getModerationCollection(communityId).doc(moderationId).update({
      'status': status.toString(),
      if (note != null) 'note': note,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Bekleyen moderasyon işlemlerini getir
  Future<List<ModerationModel>> getPendingModerations(
      String communityId) async {
    final snapshot = await _getModerationCollection(communityId)
        .where('status', isEqualTo: ModerationStatus.pending.toString())
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ModerationModel.fromFirestore(doc))
        .toList();
  }

  // Tamamlanan moderasyon işlemlerini getir
  Future<List<ModerationModel>> getResolvedModerations(
      String communityId) async {
    final snapshot = await _getModerationCollection(communityId)
        .where('status', whereIn: [
          ModerationStatus.approved.toString(),
          ModerationStatus.rejected.toString(),
          ModerationStatus.deleted.toString(),
        ])
        .orderBy('resolvedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ModerationModel.fromFirestore(doc))
        .toList();
  }

  // Kullanıcının moderasyon geçmişini getir
  Future<List<ModerationModel>> getUserModerationHistory(
    String communityId,
    String userId,
  ) async {
    final snapshot = await _getModerationCollection(communityId)
        .where('reporterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ModerationModel.fromFirestore(doc))
        .toList();
  }

  // İçeriğin moderasyon durumunu kontrol et
  Future<bool> isContentModerated(
    String communityId,
    String contentId,
  ) async {
    final snapshot = await _getModerationCollection(communityId)
        .where('contentId', isEqualTo: contentId)
        .where('status', isEqualTo: ModerationStatus.approved.toString())
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Moderasyon aksiyonundan durumu belirle
  ModerationStatus _getStatusFromAction(ModerationAction action) {
    switch (action) {
      case ModerationAction.approve:
        return ModerationStatus.approved;
      case ModerationAction.reject:
        return ModerationStatus.rejected;
      case ModerationAction.delete:
        return ModerationStatus.deleted;
      default:
        return ModerationStatus.pending;
    }
  }

  // Moderasyon aksiyonunu uygula
  Future<void> _applyModerationAction(ModerationModel moderation) async {
    if (moderation.action == null) return;

    final contentRef = _getContentReference(moderation);
    if (contentRef == null) return;

    switch (moderation.action!) {
      case ModerationAction.delete:
        await contentRef.delete();
        break;

      case ModerationAction.ban:
        await _banUser(moderation.communityId, moderation.reporterId);
        break;

      case ModerationAction.mute:
        await _muteUser(moderation.communityId, moderation.reporterId);
        break;

      case ModerationAction.warn:
        await _warnUser(moderation.communityId, moderation.reporterId);
        break;

      default:
        break;
    }
  }

  // İçerik referansını al
  DocumentReference? _getContentReference(ModerationModel moderation) {
    final communityRef =
        _firestore.collection('communities').doc(moderation.communityId);

    switch (moderation.contentType) {
      case ContentType.post:
        return communityRef.collection('posts').doc(moderation.contentId);
      case ContentType.comment:
        return communityRef.collection('comments').doc(moderation.contentId);
      case ContentType.event:
        return communityRef.collection('events').doc(moderation.contentId);
      case ContentType.resource:
        return communityRef.collection('resources').doc(moderation.contentId);
      case ContentType.profile:
        return _firestore.collection('users').doc(moderation.contentId);
    }
  }

  // Kullanıcıyı yasakla
  Future<void> _banUser(String communityId, String userId) async {
    await _firestore.collection('communities').doc(communityId).update({
      'bannedUsers': FieldValue.arrayUnion([userId]),
    });
  }

  // Kullanıcıyı sustur
  Future<void> _muteUser(String communityId, String userId) async {
    final muteEndTime = DateTime.now().add(const Duration(days: 7));
    await _firestore
        .collection('communities')
        .doc(communityId)
        .collection('muted_users')
        .doc(userId)
        .set({
      'userId': userId,
      'mutedUntil': Timestamp.fromDate(muteEndTime),
      'mutedAt': FieldValue.serverTimestamp(),
    });
  }

  // Kullanıcıyı uyar
  Future<void> _warnUser(String communityId, String userId) async {
    await _firestore
        .collection('communities')
        .doc(communityId)
        .collection('warnings')
        .add({
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // Otomatik moderasyon kurallarını kontrol et
  Future<bool> checkAutoModeration(
    String communityId,
    String contentId,
    ContentType contentType,
    Map<String, dynamic> content,
  ) async {
    // İçerik metnini al
    final contentText = content['text'] ?? content['description'] ?? '';
    // Otomatik moderasyon kurallarını uygula
    return await applyAutoModerationRules(contentText);
  }

  Future<bool> applyAutoModerationRules(String content) async {
    // Yasaklı kelimeler kontrolü
    final bannedWords = await _getBannedWords();
    if (_containsBannedWords(content, bannedWords)) {
      return false;
    }

    // Spam kontrolü
    if (_isSpam(content)) {
      return false;
    }

    // Link kontrolü
    if (_hasUnsafeLinks(content)) {
      return false;
    }

    return true;
  }

  Future<List<String>> _getBannedWords() async {
    final snapshot =
        await _firestore.collection('moderation').doc('banned_words').get();
    return List<String>.from(snapshot.data()?['words'] ?? []);
  }

  bool _containsBannedWords(String content, List<String> bannedWords) {
    return bannedWords
        .any((word) => content.toLowerCase().contains(word.toLowerCase()));
  }

  bool _isSpam(String content) {
    // Basit spam kontrolü
    final repeatedChars = RegExp(r'(.)\1{4,}');
    if (repeatedChars.hasMatch(content)) return true;

    final allCaps = content.toUpperCase() == content && content.length > 20;
    if (allCaps) return true;

    return false;
  }

  bool _hasUnsafeLinks(String content) {
    final urlPattern = RegExp(
        r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?');
    urlPattern.allMatches(content);

    // URL güvenlik kontrolü yapılabilir
    return false; // Şimdilik tüm linklere izin ver
  }
}

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
      category: reason.toString(),
      description: customReason ?? 'Rapor açıklaması yok',
      tags: [],
      attachments: [],
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
      metadata: {
        ...moderation.metadata,
        'moderatorId': moderatorId,
        'action': action.toString(),
        'status': _getStatusFromAction(action).toString(),
        'resolvedAt': DateTime.now(),
        'note': note,
      },
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
    final actionStr = moderation.metadata['action'] as String?;
    if (actionStr == null) return;

    final action = ModerationAction.values.firstWhere(
      (e) => e.toString() == actionStr,
      orElse: () => ModerationAction.warn,
    );

    final contentRef = _getContentReference(moderation);
    if (contentRef == null) return;

    switch (action) {
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
      case ContentType.message:
        return communityRef.collection('messages').doc(moderation.contentId);
      case ContentType.profile:
        return _firestore.collection('users').doc(moderation.contentId);
      case ContentType.community:
        return _firestore.collection('communities').doc(moderation.contentId);
      case ContentType.event:
        return communityRef.collection('events').doc(moderation.contentId);
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

  // Rapor kategorileri
  static const List<String> reportCategories = [
    'spam',
    'nefret_soylemi',
    'taciz',
    'yanlis_bilgi',
    'uygunsuz_icerik',
    'telif_hakki',
    'diger',
  ];

  // Gelişmiş içerik raporlama
  Future<void> reportContentAdvanced({
    required String communityId,
    required String contentId,
    required String reporterId,
    required ContentType contentType,
    required String category,
    required String description,
    List<String> tags = const [],
    List<String>? attachments,
    Map<String, dynamic> metadata = const {},
  }) async {
    // Kategori kontrolü
    if (!reportCategories.contains(category)) {
      throw Exception('Geçersiz rapor kategorisi');
    }

    final moderation = ModerationModel(
      id: '',
      communityId: communityId,
      contentId: contentId,
      reporterId: reporterId,
      contentType: contentType,
      category: category,
      description: description,
      tags: tags,
      attachments: attachments ?? [],
      metadata: {
        ...metadata,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'reviewedBy': null,
        'reviewedAt': null,
        'resolution': null,
      },
    );

    await _getModerationCollection(communityId).add(moderation.toJson());

    // Raporlama geçmişini güncelle
    await _updateReportHistory(communityId, contentId, moderation);
  }

  // Raporlama geçmişini getir
  Future<List<ModerationModel>> getReportHistory({
    required String communityId,
    String? contentId,
    String? reporterId,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    var query = _getModerationCollection(communityId)
        .orderBy('metadata.reportedAt', descending: true);

    if (contentId != null) {
      query = query.where('contentId', isEqualTo: contentId);
    }

    if (reporterId != null) {
      query = query.where('reporterId', isEqualTo: reporterId);
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (startDate != null) {
      query =
          query.where('metadata.reportedAt', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('metadata.reportedAt', isLessThanOrEqualTo: endDate);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ModerationModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  // Raporlama istatistiklerini getir
  Future<Map<String, dynamic>> getReportStats(String communityId) async {
    final stats = <String, dynamic>{
      'totalReports': 0,
      'categoryStats': <String, int>{},
      'resolutionStats': <String, int>{},
      'timeStats': <String, int>{
        'lastDay': 0,
        'lastWeek': 0,
        'lastMonth': 0,
      },
    };

    final now = DateTime.now();
    final lastDay = now.subtract(const Duration(days: 1));
    final lastWeek = now.subtract(const Duration(days: 7));
    final lastMonth = now.subtract(const Duration(days: 30));

    final reports = await _getModerationCollection(communityId).get();

    for (var doc in reports.docs) {
      final data = doc.data();
      final reportedAt = (data['metadata']['reportedAt'] as Timestamp).toDate();

      // Toplam rapor sayısı
      stats['totalReports'] = (stats['totalReports'] as int) + 1;

      // Kategori istatistikleri
      final category = data['category'] as String;
      (stats['categoryStats'] as Map<String, int>)[category] =
          ((stats['categoryStats'] as Map<String, int>)[category] ?? 0) + 1;

      // Çözüm istatistikleri
      final resolution = data['metadata']['resolution'] as String?;
      if (resolution != null) {
        (stats['resolutionStats'] as Map<String, int>)[resolution] =
            ((stats['resolutionStats'] as Map<String, int>)[resolution] ?? 0) +
                1;
      }

      // Zaman istatistikleri
      if (reportedAt.isAfter(lastDay)) {
        (stats['timeStats'] as Map<String, int>)['lastDay'] =
            ((stats['timeStats'] as Map<String, int>)['lastDay'] ?? 0) + 1;
      }
      if (reportedAt.isAfter(lastWeek)) {
        (stats['timeStats'] as Map<String, int>)['lastWeek'] =
            ((stats['timeStats'] as Map<String, int>)['lastWeek'] ?? 0) + 1;
      }
      if (reportedAt.isAfter(lastMonth)) {
        (stats['timeStats'] as Map<String, int>)['lastMonth'] =
            ((stats['timeStats'] as Map<String, int>)['lastMonth'] ?? 0) + 1;
      }
    }

    return stats;
  }

  // Raporlama geçmişini güncelle
  Future<void> _updateReportHistory(
    String communityId,
    String contentId,
    ModerationModel moderation,
  ) async {
    final historyRef = _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('content')
        .doc(contentId)
        .collection('reportHistory');

    await historyRef.add({
      'reportId': moderation.id,
      'reportedAt': FieldValue.serverTimestamp(),
      'category': moderation.category,
      'description': moderation.description,
      'reporterId': moderation.reporterId,
      'status': 'pending',
    });
  }
}

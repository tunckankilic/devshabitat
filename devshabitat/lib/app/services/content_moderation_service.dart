import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../core/services/error_handler_service.dart';
import '../repositories/auth_repository.dart';

enum ModerationAction { approve, reject, flag, remove, warn, suspend }

enum ContentType { post, comment, message, profile, image }

class ContentModerationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Otomatik moderasyon kuralları
  final List<String> _bannedWords = [
    'spam',
    'fake',
    'scam',
    // Daha fazla kelime eklenebilir
  ];

  final List<String> _suspiciousPatterns = [
    r'https?://[^\s]+\.tk',
    r'https?://[^\s]+\.ml',
    r'contact\s+me\s+at',
    // Daha fazla pattern eklenebilir
  ];

  // İçerik moderasyon kontrolü
  Future<Map<String, dynamic>> moderateContent(
    String content,
    ContentType type,
    String authorId,
  ) async {
    try {
      final moderationResult = {
        'isApproved': true,
        'confidence': 1.0,
        'flags': <String>[],
        'action': ModerationAction.approve,
        'reason': '',
      };

      // Yasaklı kelime kontrolü
      final lowerContent = content.toLowerCase();
      for (final word in _bannedWords) {
        if (lowerContent.contains(word)) {
          moderationResult['isApproved'] = false;
          (moderationResult['flags'] as List<String>).add('banned_word');
          moderationResult['action'] = ModerationAction.flag;
          moderationResult['reason'] = 'Yasaklı kelime tespit edildi: $word';
          moderationResult['confidence'] = 0.9;
          break;
        }
      }

      // Şüpheli pattern kontrolü
      for (final pattern in _suspiciousPatterns) {
        final regex = RegExp(pattern, caseSensitive: false);
        if (regex.hasMatch(content)) {
          moderationResult['isApproved'] = false;
          (moderationResult['flags'] as List<String>).add('suspicious_pattern');
          moderationResult['action'] = ModerationAction.flag;
          moderationResult['reason'] = 'Şüpheli içerik paterni tespit edildi';
          moderationResult['confidence'] = 0.8;
          break;
        }
      }

      // Spam kontrolü
      if (_isSpamContent(content)) {
        moderationResult['isApproved'] = false;
        (moderationResult['flags'] as List<String>).add('spam');
        moderationResult['action'] = ModerationAction.reject;
        moderationResult['reason'] = 'Spam içerik tespit edildi';
        moderationResult['confidence'] = 0.85;
      }

      // Kullanıcı geçmişi kontrolü
      final userHistory = await _getUserModerationHistory(authorId);
      if (userHistory['violations'] > 5) {
        moderationResult['confidence'] =
            (moderationResult['confidence'] as double) * 0.7; // Güven azalt
        (moderationResult['flags'] as List<String>).add('frequent_violator');
      }

      // Moderasyon kaydını kaydet
      await _logModerationAction(content, type, authorId, moderationResult);

      return moderationResult;
    } catch (e) {
      _logger.e('İçerik moderasyon hatası: $e');
      _errorHandler.handleError('Moderasyon hatası: $e', 'MODERATION_ERROR');

      // Güvenli tarafta kal - onaysız bırak
      return {
        'isApproved': false,
        'confidence': 0.0,
        'flags': ['error'],
        'action': ModerationAction.flag,
        'reason': 'Moderasyon hatası',
      };
    }
  }

  // Spam tespit algoritması
  bool _isSpamContent(String content) {
    // Çok fazla büyük harf
    final upperCaseRatio =
        content.split('').where((c) => c == c.toUpperCase()).length /
        content.length;
    if (upperCaseRatio > 0.7) return true;

    // Çok fazla tekrar eden karakter
    if (RegExp(r'(.)\1{5,}').hasMatch(content)) return true;

    // Çok fazla link
    final linkCount = RegExp(r'https?://').allMatches(content).length;
    if (linkCount > 3) return true;

    // Çok kısa ama linkli içerik
    if (content.length < 50 && linkCount > 0) return true;

    return false;
  }

  // Kullanıcı moderasyon geçmişi
  Future<Map<String, dynamic>> _getUserModerationHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('moderation_logs')
          .where('authorId', isEqualTo: userId)
          .where(
            'action',
            whereIn: [
              ModerationAction.reject.name,
              ModerationAction.flag.name,
              ModerationAction.warn.name,
            ],
          )
          .get();

      return {
        'violations': snapshot.docs.length,
        'lastViolation': snapshot.docs.isNotEmpty
            ? (snapshot.docs.first.data()['timestamp'] as Timestamp).toDate()
            : null,
      };
    } catch (e) {
      _logger.e('Kullanıcı geçmişi alınamadı: $e');
      return {'violations': 0, 'lastViolation': null};
    }
  }

  // Moderasyon aksiyonu kaydetme
  Future<void> _logModerationAction(
    String content,
    ContentType type,
    String authorId,
    Map<String, dynamic> result,
  ) async {
    try {
      await _firestore.collection('moderation_logs').add({
        'content': content.length > 500
            ? '${content.substring(0, 500)}...'
            : content,
        'contentType': type.name,
        'authorId': authorId,
        'action': (result['action'] as ModerationAction).name,
        'isApproved': result['isApproved'],
        'confidence': result['confidence'],
        'flags': result['flags'],
        'reason': result['reason'],
        'timestamp': FieldValue.serverTimestamp(),
        'moderatorId': 'system', // Otomatik moderasyon
      });
    } catch (e) {
      _logger.e('Moderasyon log kaydetme hatası: $e');
    }
  }

  // Manuel moderasyon aksiyonu
  Future<bool> takeManualAction(
    String contentId,
    ContentType type,
    ModerationAction action,
    String reason,
  ) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) throw Exception('Moderator oturum açmamış');

      // İçeriği güncelle
      await _firestore.collection('${type.name}s').doc(contentId).update({
        'moderationStatus': action.name,
        'moderationReason': reason,
        'moderatedAt': FieldValue.serverTimestamp(),
        'moderatedBy': currentUser.uid,
      });

      // Manuel moderasyon kaydı
      await _firestore.collection('moderation_logs').add({
        'contentId': contentId,
        'contentType': type.name,
        'action': action.name,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'moderatorId': currentUser.uid,
        'isManual': true,
      });

      // İlgili kullanıcıyı bilgilendir
      if (action == ModerationAction.reject ||
          action == ModerationAction.remove) {
        await _notifyUser(contentId, type, action, reason);
      }

      return true;
    } catch (e) {
      _logger.e('Manuel moderasyon hatası: $e');
      _errorHandler.handleError(
        'Moderasyon işlemi başarısız: $e',
        'MANUAL_MODERATION_ERROR',
      );
      return false;
    }
  }

  // Kullanıcıyı bilgilendirme
  Future<void> _notifyUser(
    String contentId,
    ContentType type,
    ModerationAction action,
    String reason,
  ) async {
    try {
      // Bu kısım NotificationService ile entegre edilebilir
      _logger.i('Kullanıcı bilgilendirildi: $contentId, $action, $reason');
    } catch (e) {
      _logger.e('Kullanıcı bilgilendirme hatası: $e');
    }
  }

  // Moderasyon istatistikleri
  Future<Map<String, dynamic>> getModerationStats(
    DateTime from,
    DateTime to,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('moderation_logs')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(to))
          .get();

      final stats = <String, int>{};
      int totalAutoModerated = 0;
      int totalManualModerated = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final action = data['action'] as String;
        final isManual = data['isManual'] ?? false;

        stats[action] = (stats[action] ?? 0) + 1;

        if (isManual) {
          totalManualModerated++;
        } else {
          totalAutoModerated++;
        }
      }

      return {
        'actionStats': stats,
        'totalAutoModerated': totalAutoModerated,
        'totalManualModerated': totalManualModerated,
        'totalProcessed': snapshot.docs.length,
        'period': {'from': from, 'to': to},
      };
    } catch (e) {
      _logger.e('Moderasyon istatistik hatası: $e');
      return {};
    }
  }

  // Bekleyen moderasyon işlemleri
  Future<List<Map<String, dynamic>>> getPendingModerations() async {
    try {
      final snapshot = await _firestore
          .collection('moderation_logs')
          .where('action', isEqualTo: ModerationAction.flag.name)
          .where('isManual', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      _logger.e('Bekleyen moderasyon getirme hatası: $e');
      return [];
    }
  }
}

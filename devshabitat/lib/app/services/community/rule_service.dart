import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../models/community/rule_model.dart';
import '../../models/community/rule_violation_model.dart';
import '../../models/community/role_model.dart';
import '../../services/community/role_service.dart';

class RuleService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RoleService _roleService = Get.find<RoleService>();

  // Kural koleksiyonunu al
  CollectionReference<Map<String, dynamic>> _getRulesCollection(
    String communityId,
  ) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('rules');
  }

  // İhlal koleksiyonunu al
  CollectionReference<Map<String, dynamic>> _getViolationsCollection(
    String communityId,
  ) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('violations');
  }

  // Yeni kural oluştur
  Future<RuleModel> createRule(RuleModel rule) async {
    final doc = await _getRulesCollection(
      rule.communityId,
    ).add(rule.toFirestore());

    return rule.copyWith(id: doc.id);
  }

  // Kuralı güncelle
  Future<void> updateRule(RuleModel rule) async {
    await _getRulesCollection(
      rule.communityId,
    ).doc(rule.id).update(rule.toFirestore());
  }

  // Kuralı sil
  Future<void> deleteRule(String communityId, String ruleId) async {
    await _getRulesCollection(communityId).doc(ruleId).delete();
  }

  // Tüm kuralları getir
  Future<List<RuleModel>> getRules(
    String communityId, {
    RuleCategory? category,
    bool onlyEnabled = true,
    String? sortBy,
    bool descending = true,
  }) async {
    Query<Map<String, dynamic>> query = _getRulesCollection(communityId);

    if (onlyEnabled) {
      query = query.where('isEnabled', isEqualTo: true);
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category.toString());
    }

    if (sortBy != null) {
      query = query.orderBy(sortBy, descending: descending);
    } else {
      query = query.orderBy('priority', descending: true);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => RuleModel.fromFirestore(doc)).toList();
  }

  // Kural ihlali bildir
  Future<RuleViolationModel> reportViolation(
    RuleViolationModel violation,
  ) async {
    final doc = await _getViolationsCollection(
      violation.communityId,
    ).add(violation.toFirestore());

    return violation.copyWith(id: doc.id);
  }

  // İhlal durumunu güncelle
  Future<void> updateViolationStatus({
    required String communityId,
    required String violationId,
    required ViolationStatus status,
    required String moderatorId,
    ViolationAction? action,
    String? note,
  }) async {
    await _getViolationsCollection(communityId).doc(violationId).update({
      'status': status.toString(),
      'action': action?.toString(),
      'moderatorId': moderatorId,
      'note': note,
      'resolvedAt': status == ViolationStatus.resolved
          ? FieldValue.serverTimestamp()
          : null,
    });
  }

  // İhlalleri getir
  Future<List<RuleViolationModel>> getViolations(
    String communityId, {
    ViolationStatus? status,
    String? userId,
    String? ruleId,
    String? sortBy,
    bool descending = true,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _getViolationsCollection(communityId);

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString());
    }

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    if (ruleId != null) {
      query = query.where('ruleId', isEqualTo: ruleId);
    }

    if (sortBy != null) {
      query = query.orderBy(sortBy, descending: descending);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => RuleViolationModel.fromFirestore(doc))
        .toList();
  }

  // Kullanıcının ihlallerini getir
  Future<List<RuleViolationModel>> getUserViolations(
    String communityId,
    String userId,
  ) async {
    final snapshot = await _getViolationsCollection(communityId)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => RuleViolationModel.fromFirestore(doc))
        .toList();
  }

  // Kural yönetimi yetkisini kontrol et
  Future<bool> canManageRules(String communityId, String userId) async {
    return await _roleService.hasPermission(
      communityId,
      userId,
      RolePermission.manageRules,
    );
  }

  // İhlal yönetimi yetkisini kontrol et
  Future<bool> canManageViolations(String communityId, String userId) async {
    return await _roleService.hasPermission(
      communityId,
      userId,
      RolePermission.moderateContent,
    );
  }

  // Otomatik kural kontrolü
  Future<List<RuleModel>> checkAutoModRules(
    String communityId,
    String content,
    String contentType,
  ) async {
    final rules = await getRules(communityId, onlyEnabled: true);

    return rules.where((rule) {
      if (rule.enforcement != RuleEnforcement.automatic &&
          rule.enforcement != RuleEnforcement.hybrid) {
        return false;
      }

      // Anahtar kelime kontrolü
      final hasKeyword = rule.keywords.any(
        (keyword) => content.toLowerCase().contains(keyword.toLowerCase()),
      );

      if (!hasKeyword) return false;

      // Özel kural konfigürasyonu kontrolü
      if (rule.autoModConfig.isNotEmpty) {
        final config = rule.autoModConfig;

        // Minimum uzunluk kontrolü
        if (config['minLength'] != null &&
            content.length < config['minLength']) {
          return true;
        }

        // Maksimum uzunluk kontrolü
        if (config['maxLength'] != null &&
            content.length > config['maxLength']) {
          return true;
        }

        // Regex kontrolü
        if (config['regex'] != null) {
          final regex = RegExp(config['regex']);
          if (regex.hasMatch(content)) {
            return true;
          }
        }

        // İçerik türü kontrolü
        if (config['contentTypes'] != null &&
            config['contentTypes'].contains(contentType)) {
          return true;
        }
      }

      return hasKeyword;
    }).toList();
  }

  // Gelişmiş içerik filtreleme yapılandırması
  static const Map<String, dynamic> defaultAdvancedConfig = {
    'regexPatterns': <String>[],
    'spamDetection': {
      'enabled': true,
      'threshold': 0.7,
      'maxRepeatedChars': 5,
      'maxUrls': 3,
      'minContentLength': 10,
    },
    'languageSettings': {
      'allowedLanguages': ['tr', 'en'],
      'defaultLanguage': 'tr',
      'profanityCheck': true,
    },
  };

  // Gelişmiş içerik kontrolü
  Future<bool> checkContentAdvanced(
    String communityId,
    String content,
    String contentType, {
    String? language,
  }) async {
    try {
      final rules = await getRules(communityId, onlyEnabled: true);

      for (final rule in rules) {
        if (rule.enforcement != RuleEnforcement.automatic &&
            rule.enforcement != RuleEnforcement.hybrid) {
          continue;
        }

        // Regex kontrolleri
        if (rule.autoModConfig['regexPatterns'] != null) {
          for (String pattern in rule.autoModConfig['regexPatterns']) {
            try {
              final regex = RegExp(
                pattern,
                caseSensitive: false,
                unicode: true,
              );
              if (regex.hasMatch(content)) {
                return true;
              }
            } catch (e) {
              print('Regex hatası: $pattern - $e');
            }
          }
        }

        // Spam kontrolü
        if (rule.autoModConfig['spamDetection']?['enabled'] == true) {
          if (await _isSpamContent(
            content,
            rule.autoModConfig['spamDetection'],
          )) {
            return true;
          }
        }

        // Dil kontrolü
        if (rule.autoModConfig['languageSettings'] != null) {
          final settings = rule.autoModConfig['languageSettings'];
          if (!settings['allowedLanguages'].contains(language)) {
            return true;
          }

          if (settings['profanityCheck'] == true) {
            if (await _containsProfanity(
              content,
              language ?? settings['defaultLanguage'],
            )) {
              return true;
            }
          }
        }
      }

      return false;
    } catch (e) {
      print('Gelişmiş içerik kontrolü hatası: $e');
      return false;
    }
  }

  Future<bool> _isSpamContent(
    String content,
    Map<String, dynamic> config,
  ) async {
    // Tekrarlanan karakter kontrolü
    final repeatedChars = RegExp(
      r'(.)\1{' + (config['maxRepeatedChars'] - 1).toString() + ',}',
    );
    if (repeatedChars.hasMatch(content)) {
      return true;
    }

    // URL sayısı kontrolü
    final urlCount = RegExp(r'https?://\S+').allMatches(content).length;
    if (urlCount > config['maxUrls']) {
      return true;
    }

    // İçerik uzunluğu kontrolü
    if (content.length < config['minContentLength']) {
      return true;
    }

    // Spam skoru hesaplama
    double spamScore = 0.0;

    // Büyük harf oranı
    final upperCaseRatio =
        content.replaceAll(RegExp(r'[^A-Z]'), '').length / content.length;
    if (upperCaseRatio > 0.7) spamScore += 0.3;

    // Tekrarlanan kelimeler
    final words = content.toLowerCase().split(RegExp(r'\s+'));
    final wordFreq = <String, int>{};
    for (var word in words) {
      wordFreq[word] = (wordFreq[word] ?? 0) + 1;
    }
    if (wordFreq.values.any((freq) => freq > 3)) spamScore += 0.4;

    return spamScore >= config['threshold'];
  }

  Future<bool> _containsProfanity(String content, String language) async {
    // Dile özgü yasaklı kelime listelerini yükle
    final bannedWords = await _loadBannedWords(language);

    final normalizedContent = content.toLowerCase();
    return bannedWords.any(
      (word) => normalizedContent.contains(word.toLowerCase()),
    );
  }

  Future<List<String>> _loadBannedWords(String language) async {
    try {
      final doc = await _firestore
          .collection('moderation')
          .doc('banned_words')
          .collection(language)
          .doc('words')
          .get();

      if (doc.exists && doc.data()?['words'] != null) {
        return List<String>.from(doc.data()!['words']);
      }

      return [];
    } catch (e) {
      print('Yasaklı kelimeler yüklenirken hata: $e');
      return [];
    }
  }

  // İhlal istatistiklerini getir
  Future<Map<String, dynamic>> getViolationStats(String communityId) async {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final lastMonth = now.subtract(const Duration(days: 30));

    final snapshot = await _getViolationsCollection(
      communityId,
    ).where('createdAt', isGreaterThan: Timestamp.fromDate(lastMonth)).get();

    final violations = snapshot.docs
        .map((doc) => RuleViolationModel.fromFirestore(doc))
        .toList();

    int totalViolations = violations.length;
    int weeklyViolations = violations
        .where((v) => v.createdAt.isAfter(lastWeek))
        .length;
    int resolvedViolations = violations
        .where((v) => v.status == ViolationStatus.resolved)
        .length;
    int pendingViolations = violations
        .where((v) => v.status == ViolationStatus.pending)
        .length;

    Map<String, int> violationsByRule = {};
    Map<String, int> violationsByUser = {};
    Map<ViolationAction, int> actionsTaken = {};

    for (var violation in violations) {
      // Kural bazlı istatistikler
      violationsByRule[violation.ruleId] =
          (violationsByRule[violation.ruleId] ?? 0) + 1;

      // Kullanıcı bazlı istatistikler
      violationsByUser[violation.userId] =
          (violationsByUser[violation.userId] ?? 0) + 1;

      // Aksiyon bazlı istatistikler
      if (violation.action != null) {
        actionsTaken[violation.action!] =
            (actionsTaken[violation.action!] ?? 0) + 1;
      }
    }

    return {
      'totalViolations': totalViolations,
      'weeklyViolations': weeklyViolations,
      'resolvedViolations': resolvedViolations,
      'pendingViolations': pendingViolations,
      'violationsByRule': violationsByRule,
      'violationsByUser': violationsByUser,
      'actionsTaken': actionsTaken,
      'resolutionRate': totalViolations > 0
          ? (resolvedViolations / totalViolations * 100).toStringAsFixed(1)
          : '0',
    };
  }
}

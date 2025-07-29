import 'package:get/get.dart';
import '../../models/community/moderation_model.dart';
import '../../models/community/role_model.dart';
import '../../models/community/rule_model.dart';
import '../../models/community/rule_violation_model.dart';
import '../../services/community/moderation_service.dart';
import '../../services/community/role_service.dart';
import '../../services/community/rule_service.dart';

class ModerationController extends GetxController {
  final ModerationService _moderationService = Get.find<ModerationService>();
  final RoleService _roleService = Get.find<RoleService>();
  final RuleService _ruleService = Get.find<RuleService>();

  final pendingModerations = <ModerationModel>[].obs;
  final resolvedModerations = <ModerationModel>[].obs;
  final selectedModeration = Rxn<ModerationModel>();
  final isLoading = false.obs;
  final error = ''.obs;

  late final String communityId;
  late final String userId;

  @override
  void onInit() {
    super.onInit();
    communityId = Get.arguments['communityId'] as String;
    userId = Get.arguments['userId'] as String;
    loadModerations();
  }

  // Moderasyon kayıtlarını yükle
  Future<void> loadModerations() async {
    try {
      isLoading.value = true;
      error.value = '';

      await Future.wait([
        loadPendingModerations(),
        loadResolvedModerations(),
      ]);
    } catch (e) {
      error.value = 'Moderasyon kayıtları yüklenirken bir hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Bekleyen moderasyon kayıtlarını yükle
  Future<void> loadPendingModerations() async {
    try {
      final moderations =
          await _moderationService.getPendingModerations(communityId);
      pendingModerations.assignAll(moderations);
    } catch (e) {
      error.value = 'Bekleyen moderasyonlar yüklenirken bir hata oluştu: $e';
    }
  }

  // Tamamlanan moderasyon kayıtlarını yükle
  Future<void> loadResolvedModerations() async {
    try {
      final moderations =
          await _moderationService.getResolvedModerations(communityId);
      resolvedModerations.assignAll(moderations);
    } catch (e) {
      error.value = 'Tamamlanan moderasyonlar yüklenirken bir hata oluştu: $e';
    }
  }

  // İçerik raporla
  Future<void> reportContent({
    required String contentId,
    required ContentType contentType,
    required ModerationReason reason,
    String? customReason,
    String? note,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _moderationService.reportContent(
        communityId: communityId,
        contentId: contentId,
        reporterId: userId,
        contentType: contentType,
        reason: reason,
        customReason: customReason,
        note: note,
        metadata: metadata,
      );

      Get.back();
      Get.snackbar(
        'Başarılı',
        'İçerik başarıyla raporlandı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'İçerik raporlanırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'İçerik raporlanırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Moderasyon işlemi uygula
  Future<void> moderateContent({
    required String moderationId,
    required ModerationAction action,
    String? note,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _moderationService.moderateContent(
        communityId: communityId,
        moderationId: moderationId,
        moderatorId: userId,
        action: action,
        note: note,
      );

      await loadModerations();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Moderasyon işlemi başarıyla uygulandı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Moderasyon işlemi uygulanırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Moderasyon işlemi uygulanırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Moderasyon durumunu güncelle
  Future<void> updateModerationStatus({
    required String moderationId,
    required ModerationStatus status,
    String? note,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _moderationService.updateModerationStatus(
        communityId: communityId,
        moderationId: moderationId,
        status: status,
        note: note,
      );

      await loadModerations();

      Get.snackbar(
        'Başarılı',
        'Moderasyon durumu başarıyla güncellendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Moderasyon durumu güncellenirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Moderasyon durumu güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Kullanıcının moderasyon geçmişini getir
  Future<List<ModerationModel>> getUserModerationHistory(String userId) async {
    try {
      return await _moderationService.getUserModerationHistory(
        communityId,
        userId,
      );
    } catch (e) {
      error.value = 'Moderasyon geçmişi yüklenirken bir hata oluştu: $e';
      return [];
    }
  }

  // İçeriğin moderasyon durumunu kontrol et
  Future<bool> isContentModerated(String contentId) async {
    try {
      return await _moderationService.isContentModerated(
        communityId,
        contentId,
      );
    } catch (e) {
      error.value = 'Moderasyon durumu kontrol edilirken bir hata oluştu: $e';
      return false;
    }
  }

  // Otomatik moderasyon kontrolü
  Future<bool> checkAutoModeration({
    required String contentId,
    required ContentType contentType,
    required Map<String, dynamic> content,
  }) async {
    try {
      return await _moderationService.checkAutoModeration(
        communityId,
        contentId,
        contentType,
        content,
      );
    } catch (e) {
      error.value =
          'Otomatik moderasyon kontrolü yapılırken bir hata oluştu: $e';
      return false;
    }
  }

  // Moderasyon yetkisini kontrol et
  Future<bool> canModerate() async {
    try {
      return await _roleService.hasPermission(
        communityId,
        userId,
        RolePermission.moderateContent,
      );
    } catch (e) {
      error.value = 'Yetki kontrolü yapılırken bir hata oluştu: $e';
      return false;
    }
  }

  // Moderasyon nedenini metne çevir
  String getModerationReasonText(ModerationReason reason) {
    switch (reason) {
      case ModerationReason.spam:
        return 'Spam';
      case ModerationReason.harassment:
        return 'Taciz';
      case ModerationReason.inappropriateContent:
        return 'Uygunsuz İçerik';
      case ModerationReason.violence:
        return 'Kural İhlali';
      case ModerationReason.other:
        return 'Diğer';
    }
  }

  // Moderasyon durumunu metne çevir
  String getModerationStatusText(ModerationStatus status) {
    switch (status) {
      case ModerationStatus.pending:
        return 'Beklemede';
      case ModerationStatus.approved:
        return 'Onaylandı';
      case ModerationStatus.rejected:
        return 'Reddedildi';
      case ModerationStatus.deleted:
        return 'Silindi';
    }
  }

  // Moderasyon aksiyonunu metne çevir
  String getModerationActionText(ModerationAction action) {
    switch (action) {
      case ModerationAction.warn:
        return 'Uyarı';
      case ModerationAction.delete:
        return 'Silme';
      case ModerationAction.ban:
        return 'Yasaklama';
      case ModerationAction.mute:
        return 'Susturma';
      case ModerationAction.approve:
        return 'Onaylama';
      case ModerationAction.reject:
        return 'Reddetme';
    }
  }

  // İçerik için kural ihlali kontrolü
  Future<List<RuleViolationModel>> checkRuleViolations({
    required String contentId,
    required String contentType,
    required String userId,
    required Map<String, dynamic> content,
  }) async {
    try {
      final violations = <RuleViolationModel>[];

      // Topluluk kurallarını al
      final rules = await _ruleService.getRules(communityId, onlyEnabled: true);

      for (final rule in rules) {
        if (rule.enforcement == RuleEnforcement.automatic ||
            rule.enforcement == RuleEnforcement.hybrid) {
          // İçerik kontrolü
          if (_checkContentAgainstRule(content, rule)) {
            final violation = RuleViolationModel(
              id: '',
              communityId: communityId,
              ruleId: rule.id,
              userId: userId,
              contentId: contentId,
              contentType: contentType,
              reporterId: 'system',
              status: ViolationStatus.pending,
              description: 'Otomatik kural ihlali tespit edildi: ${rule.title}',
              evidence: {
                'rule': rule.toJson(),
                'content': content,
                'detectedAt': DateTime.now().toIso8601String(),
              },
              createdAt: DateTime.now(),
            );

            violations.add(violation);
          }
        }
      }

      return violations;
    } catch (e) {
      error.value = 'Kural ihlali kontrolü yapılırken bir hata oluştu: $e';
      return [];
    }
  }

  // İçeriği kurala göre kontrol et
  bool _checkContentAgainstRule(Map<String, dynamic> content, RuleModel rule) {
    try {
      // Anahtar kelime kontrolü
      if (rule.keywords.isNotEmpty) {
        final contentText = content['text']?.toString().toLowerCase() ?? '';
        final hasKeyword = rule.keywords
            .any((keyword) => contentText.contains(keyword.toLowerCase()));

        if (hasKeyword) {
          return true;
        }
      }

      // Otomatik moderasyon konfigürasyonu kontrolü
      if (rule.autoModConfig.isNotEmpty) {
        // Spam kontrolü
        if (rule.autoModConfig['checkSpam'] == true) {
          if (_isSpamContent(content)) {
            return true;
          }
        }

        // Uygunsuz içerik kontrolü
        if (rule.autoModConfig['checkInappropriate'] == true) {
          if (_isInappropriateContent(content)) {
            return true;
          }
        }

        // Çoklu gönderim kontrolü
        if (rule.autoModConfig['checkDuplicate'] == true) {
          if (_isDuplicateContent(content)) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      error.value = 'İçerik kontrolü yapılırken bir hata oluştu: $e';
      return false;
    }
  }

  // Spam içerik kontrolü
  bool _isSpamContent(Map<String, dynamic> content) {
    final text = content['text']?.toString() ?? '';

    // Basit spam kontrolü
    final spamIndicators = [
      'buy now',
      'click here',
      'free money',
      'make money fast',
      'earn money',
      'work from home',
      'get rich quick',
    ];

    final lowerText = text.toLowerCase();
    final spamCount = spamIndicators
        .where((indicator) => lowerText.contains(indicator))
        .length;

    return spamCount >= 2;
  }

  // Uygunsuz içerik kontrolü
  bool _isInappropriateContent(Map<String, dynamic> content) {
    final text = content['text']?.toString() ?? '';

    // Basit uygunsuz içerik kontrolü
    final inappropriateWords = [
      'küfür',
      'hakaret',
      'taciz',
      'şiddet',
    ];

    final lowerText = text.toLowerCase();
    return inappropriateWords.any((word) => lowerText.contains(word));
  }

  // Çoklu gönderim kontrolü
  bool _isDuplicateContent(Map<String, dynamic> content) {
    // Bu metod daha gelişmiş bir implementasyon gerektirir
    // Şimdilik basit bir kontrol yapıyoruz
    return false;
  }

  // Kural ihlali bildir
  Future<void> reportRuleViolation(RuleViolationModel violation) async {
    try {
      await _ruleService.reportViolation(violation);

      Get.snackbar(
        'Başarılı',
        'Kural ihlali bildirildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Kural ihlali bildirilirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Kural ihlali bildirilirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Kullanıcının ihlal geçmişini getir
  Future<List<RuleViolationModel>> getUserViolationHistory(
      String userId) async {
    try {
      return await _ruleService.getUserViolations(communityId, userId);
    } catch (e) {
      error.value = 'Kullanıcı ihlal geçmişi yüklenirken bir hata oluştu: $e';
      return [];
    }
  }

  // İhlal istatistiklerini getir
  Future<Map<String, dynamic>> getViolationStatistics() async {
    try {
      return await _ruleService.getViolationStats(communityId);
    } catch (e) {
      error.value = 'İhlal istatistikleri yüklenirken bir hata oluştu: $e';
      return {};
    }
  }
}

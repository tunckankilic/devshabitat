import 'package:get/get.dart';
import '../../models/community/rule_model.dart';
import '../../models/community/rule_violation_model.dart';
import '../../services/community/rule_service.dart';

class RuleController extends GetxController {
  final RuleService _ruleService = Get.find<RuleService>();

  final rules = <RuleModel>[].obs;
  final violations = <RuleViolationModel>[].obs;
  final selectedRule = Rxn<RuleModel>();
  final selectedViolation = Rxn<RuleViolationModel>();
  final selectedCategory = Rx<RuleCategory?>(null);
  final isLoading = false.obs;
  final error = ''.obs;

  late final String communityId;
  late final String userId;

  @override
  void onInit() {
    super.onInit();
    communityId = Get.arguments['communityId'] as String;
    userId = Get.arguments['userId'] as String;
    loadRules();
    loadViolations();
  }

  // Kuralları yükle
  Future<void> loadRules() async {
    try {
      isLoading.value = true;
      error.value = '';

      final communityRules = await _ruleService.getRules(
        communityId,
        category: selectedCategory.value,
      );
      rules.assignAll(communityRules);
    } catch (e) {
      error.value = 'Kurallar yüklenirken bir hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // İhlalleri yükle
  Future<void> loadViolations() async {
    try {
      isLoading.value = true;
      error.value = '';

      final ruleViolations = await _ruleService.getViolations(communityId);
      violations.assignAll(ruleViolations);
    } catch (e) {
      error.value = 'İhlaller yüklenirken bir hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Yeni kural oluştur
  Future<void> createRule(RuleModel rule) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _ruleService.createRule(rule);
      await loadRules();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Kural başarıyla oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Kural oluşturulurken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Kural oluşturulurken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Kuralı güncelle
  Future<void> updateRule(RuleModel rule) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _ruleService.updateRule(rule);
      await loadRules();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Kural başarıyla güncellendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Kural güncellenirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Kural güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Kuralı sil
  Future<void> deleteRule(String ruleId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _ruleService.deleteRule(communityId, ruleId);
      await loadRules();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Kural başarıyla silindi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Kural silinirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Kural silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // İhlal bildir
  Future<void> reportViolation(RuleViolationModel violation) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _ruleService.reportViolation(violation);
      await loadViolations();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'İhlal başarıyla bildirildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'İhlal bildirilirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'İhlal bildirilirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // İhlal durumunu güncelle
  Future<void> updateViolationStatus({
    required String violationId,
    required ViolationStatus status,
    ViolationAction? action,
    String? note,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _ruleService.updateViolationStatus(
        communityId: communityId,
        violationId: violationId,
        status: status,
        moderatorId: userId,
        action: action,
        note: note,
      );

      await loadViolations();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'İhlal durumu güncellendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'İhlal durumu güncellenirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'İhlal durumu güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Kullanıcının ihlallerini getir
  Future<List<RuleViolationModel>> getUserViolations(String userId) async {
    try {
      return await _ruleService.getUserViolations(communityId, userId);
    } catch (e) {
      error.value = 'Kullanıcı ihlalleri yüklenirken bir hata oluştu: $e';
      return [];
    }
  }

  // Kural yönetimi yetkisini kontrol et
  Future<bool> canManageRules() async {
    try {
      return await _ruleService.canManageRules(communityId, userId);
    } catch (e) {
      error.value = 'Yetki kontrolü yapılırken bir hata oluştu: $e';
      return false;
    }
  }

  // İhlal yönetimi yetkisini kontrol et
  Future<bool> canManageViolations() async {
    try {
      return await _ruleService.canManageViolations(communityId, userId);
    } catch (e) {
      error.value = 'Yetki kontrolü yapılırken bir hata oluştu: $e';
      return false;
    }
  }

  // İçeriği otomatik kontrol et
  Future<List<RuleModel>> checkContent(
    String content,
    String contentType,
  ) async {
    try {
      return await _ruleService.checkAutoModRules(
        communityId,
        content,
        contentType,
      );
    } catch (e) {
      error.value = 'İçerik kontrolü yapılırken bir hata oluştu: $e';
      return [];
    }
  }

  // İhlal istatistiklerini getir
  Future<Map<String, dynamic>> getViolationStats() async {
    try {
      return await _ruleService.getViolationStats(communityId);
    } catch (e) {
      error.value = 'İstatistikler yüklenirken bir hata oluştu: $e';
      return {};
    }
  }

  // Kural kategorisini metne çevir
  String getRuleCategoryText(RuleCategory category) {
    switch (category) {
      case RuleCategory.general:
        return 'Genel';
      case RuleCategory.content:
        return 'İçerik';
      case RuleCategory.behavior:
        return 'Davranış';
      case RuleCategory.moderation:
        return 'Moderasyon';
      case RuleCategory.privacy:
        return 'Gizlilik';
      case RuleCategory.other:
        return 'Diğer';
    }
  }

  // Kural şiddetini metne çevir
  String getRuleSeverityText(RuleSeverity severity) {
    switch (severity) {
      case RuleSeverity.low:
        return 'Düşük';
      case RuleSeverity.medium:
        return 'Orta';
      case RuleSeverity.high:
        return 'Yüksek';
      case RuleSeverity.critical:
        return 'Kritik';
    }
  }

  // Kural uygulama yöntemini metne çevir
  String getRuleEnforcementText(RuleEnforcement enforcement) {
    switch (enforcement) {
      case RuleEnforcement.manual:
        return 'Manuel';
      case RuleEnforcement.automatic:
        return 'Otomatik';
      case RuleEnforcement.hybrid:
        return 'Karma';
    }
  }

  // İhlal durumunu metne çevir
  String getViolationStatusText(ViolationStatus status) {
    switch (status) {
      case ViolationStatus.pending:
        return 'Beklemede';
      case ViolationStatus.confirmed:
        return 'Onaylandı';
      case ViolationStatus.rejected:
        return 'Reddedildi';
      case ViolationStatus.resolved:
        return 'Çözüldü';
    }
  }

  // İhlal aksiyonunu metne çevir
  String getViolationActionText(ViolationAction action) {
    switch (action) {
      case ViolationAction.warning:
        return 'Uyarı';
      case ViolationAction.mute:
        return 'Susturma';
      case ViolationAction.ban:
        return 'Yasaklama';
      case ViolationAction.deleteContent:
        return 'İçerik Silme';
      case ViolationAction.other:
        return 'Diğer';
    }
  }
}

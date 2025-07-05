import 'package:get/get.dart';
import '../../models/community/moderation_model.dart';
import '../../models/community/role_model.dart';
import '../../services/community/moderation_service.dart';
import '../../services/community/role_service.dart';

class ModerationController extends GetxController {
  final ModerationService _moderationService = Get.find<ModerationService>();
  final RoleService _roleService = Get.find<RoleService>();

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
}

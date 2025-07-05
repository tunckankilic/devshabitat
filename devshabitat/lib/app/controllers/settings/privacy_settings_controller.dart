import 'package:get/get.dart';
import '../../models/privacy_settings_model.dart';
import '../../services/user_service.dart';

class PrivacySettingsController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final settings = PrivacySettings().obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final userSettings = await _userService.getPrivacySettings();
      settings.value = userSettings;
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Gizlilik ayarları yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateSettings({
    bool? isProfilePublic,
    bool? showLocation,
    bool? allowConnectionRequests,
    bool? showTechnologies,
    bool? showBio,
    bool? allowMentorshipRequests,
  }) async {
    try {
      final updatedSettings = settings.value.copyWith(
        isProfilePublic: isProfilePublic,
        showLocation: showLocation,
        allowConnectionRequests: allowConnectionRequests,
        showTechnologies: showTechnologies,
        showBio: showBio,
        allowMentorshipRequests: allowMentorshipRequests,
      );

      await _userService.updatePrivacySettings(updatedSettings);
      settings.value = updatedSettings;

      Get.snackbar(
        'Başarılı',
        'Gizlilik ayarları güncellendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Gizlilik ayarları güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final currentBlocked = List<String>.from(settings.value.blockedUsers);
      if (!currentBlocked.contains(userId)) {
        currentBlocked.add(userId);
        final updatedSettings = settings.value.copyWith(
          blockedUsers: currentBlocked,
        );
        await _userService.updatePrivacySettings(updatedSettings);
        settings.value = updatedSettings;
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Kullanıcı engellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      final currentBlocked = List<String>.from(settings.value.blockedUsers);
      if (currentBlocked.contains(userId)) {
        currentBlocked.remove(userId);
        final updatedSettings = settings.value.copyWith(
          blockedUsers: currentBlocked,
        );
        await _userService.updatePrivacySettings(updatedSettings);
        settings.value = updatedSettings;
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Kullanıcı engeli kaldırılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

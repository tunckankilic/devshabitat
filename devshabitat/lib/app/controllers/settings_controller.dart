import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_controller.dart';

class SettingsController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final isDarkMode = false.obs;
  final isNotificationsEnabled = true.obs;
  final selectedLanguage = 'Türkçe'.obs;
  final isSoundEnabled = true.obs;
  final isLoading = false.obs;

  final List<String> availableLanguages = ['Türkçe', 'English'];

  // SharedPreferences keys
  static const String _darkModeKey = 'dark_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _languageKey = 'selected_language';
  static const String _soundKey = 'sound_enabled';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(_darkModeKey) ?? false;
    isNotificationsEnabled.value = prefs.getBool(_notificationsKey) ?? true;
    selectedLanguage.value = prefs.getString(_languageKey) ?? 'Türkçe';
    isSoundEnabled.value = prefs.getBool(_soundKey) ?? true;

    // Apply loaded theme
    if (isDarkMode.value) {
      Get.changeTheme(ThemeData.dark());
    }

    // Apply loaded language
    _applyLanguage(selectedLanguage.value);
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDarkMode.value);
  }

  Future<void> toggleNotifications() async {
    isNotificationsEnabled.value = !isNotificationsEnabled.value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, isNotificationsEnabled.value);

    // Show feedback
    Get.snackbar(
      'Bildirimler',
      isNotificationsEnabled.value
          ? 'Bildirimler açıldı'
          : 'Bildirimler kapatıldı',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> toggleSound() async {
    isSoundEnabled.value = !isSoundEnabled.value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, isSoundEnabled.value);

    // Show feedback
    Get.snackbar(
      'Ses',
      isSoundEnabled.value ? 'Ses efektleri açıldı' : 'Ses efektleri kapatıldı',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> changeLanguage(String language) async {
    selectedLanguage.value = language;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);

    _applyLanguage(language);

    Get.snackbar(
      'Dil',
      'Dil değiştirildi: $language',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _applyLanguage(String language) {
    switch (language) {
      case 'English':
        Get.updateLocale(const Locale('en', 'US'));
        break;
      case 'Türkçe':
      default:
        Get.updateLocale(const Locale('tr', 'TR'));
        break;
    }
  }

  Future<void> signOut() async {
    // Confirmation dialog
    final shouldSignOut = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
            'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) return;

    try {
      isLoading.value = true;

      // Clear local settings if needed
      await _clearLocalData();

      // Sign out through AuthController
      await _authController.signOut();

      // Show success message
      Get.snackbar(
        'Başarılı',
        'Başarıyla çıkış yapıldı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigation handled automatically by AuthController
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Çıkış yapılırken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _clearLocalData() async {
    // Reset settings to defaults if needed
    // This is optional - settings might persist across logins
    try {
      // You can implement cache clearing here if needed
      // Example: SharedPreferences clearing, database cleanup, etc.
    } catch (e) {
      // Silent fail for non-critical cleanup
      debugPrint('Error clearing local data: $e');
    }
  }

  Future<void> showDeleteAccountDialog() async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz?'),
            SizedBox(height: 8),
            Text(
              'Bu işlem geri alınamaz ve tüm verileriniz silinecektir.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      isLoading.value = true;
      await _authController.deleteAccount();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Hesap silinirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

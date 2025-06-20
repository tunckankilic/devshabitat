import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final isDarkMode = false.obs;
  final isNotificationsEnabled = true.obs;
  final selectedLanguage = 'Türkçe'.obs;
  final isSoundEnabled = true.obs;

  final List<String> availableLanguages = ['Türkçe', 'English'];

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
  }

  void toggleNotifications() {
    isNotificationsEnabled.value = !isNotificationsEnabled.value;
  }

  void toggleSound() {
    isSoundEnabled.value = !isSoundEnabled.value;
  }

  void changeLanguage(String language) {
    selectedLanguage.value = language;
    // Burada dil değişikliği implementasyonu yapılacak
  }

  void signOut() {
    // Auth controller üzerinden çıkış işlemi yapılacak
    Get.offAllNamed('/login');
  }
}

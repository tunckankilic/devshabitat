import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_strings.dart';

class AppController extends GetxController {
  final ErrorHandlerService _errorHandler;

  AppController({
    required ErrorHandlerService errorHandler,
  }) : _errorHandler = errorHandler;

  // State değişkenleri
  final RxBool _isDarkMode = false.obs;
  final RxBool _isOnline = true.obs;
  final RxBool _isLoading = false.obs;

  // Getters
  bool get isDarkMode => _isDarkMode.value;
  bool get isOnline => _isOnline.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _initTheme();
  }

  // Bağlantı durumunu izle
  Future<void> _initConnectivity() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        debugPrint(
            '⚠️ No internet connection detected - app will work in offline mode');
        // Sadece log yazıp devam ediyoruz, hata fırlatmıyoruz
        return;
      }

      // Bağlantı varsa dinlemeye başla
      Connectivity().onConnectivityChanged.distinct().listen((result) {
        if (result == ConnectivityResult.none) {
          debugPrint('⚠️ Connection lost - switching to offline mode');
        } else {
          debugPrint('✅ Connection restored');
        }
      }, onError: (error) {
        debugPrint('⚠️ Error monitoring connectivity: $error');
      });
    } catch (e) {
      debugPrint('⚠️ Error initializing connectivity monitoring: $e');
    }
  }

  // Tema durumunu başlat
  void _initTheme() {
    _isDarkMode.value = Get.isDarkMode;
  }

  // Tema değiştir
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Yükleme durumunu değiştir
  void setLoading(bool value) {
    _isLoading.value = value;
  }

  // Hata yönetimi
  void handleError(dynamic error) {
    _errorHandler.handleError(error, ErrorHandlerService.SERVER_ERROR);
  }

  // Uygulama durumunu sıfırla
  void resetAppState() {
    _isLoading.value = false;
    _isDarkMode.value = false;
    _isOnline.value = true;
    Get.changeThemeMode(ThemeMode.light); // Tema modunu da varsayılana döndür
  }
}

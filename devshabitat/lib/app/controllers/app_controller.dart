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
  void _initConnectivity() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _isOnline.value = results.first != ConnectivityResult.none;
      if (!_isOnline.value) {
        _errorHandler.handleError(AppStrings.errorNetwork);
      }
    });
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
    _errorHandler.handleError(error);
  }

  // Uygulama durumunu sıfırla
  void resetAppState() {
    _isLoading.value = false;
    // Diğer state sıfırlama işlemleri
  }
}

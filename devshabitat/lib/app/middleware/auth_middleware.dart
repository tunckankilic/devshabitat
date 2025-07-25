import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_state_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      // AuthController mevcut mu kontrol et
      if (!Get.isRegistered<AuthController>()) {
        return null; // Henüz yüklenmediyse bekleme
      }

      final authController = Get.find<AuthController>();

      if (authController.authState == AuthState.unauthenticated) {
        return RouteSettings(name: AppRoutes.login);
      }

      return null;
    } catch (e) {
      // Hata olursa login'e yönlendir
      return RouteSettings(name: AppRoutes.login);
    }
  }
}

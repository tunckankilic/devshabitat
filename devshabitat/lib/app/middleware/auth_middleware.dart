import 'package:devshabitat/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/enhanced_auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<EnhancedAuthController>();

    if (authController.authState == AuthState.unauthenticated) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    return null;
  }
}

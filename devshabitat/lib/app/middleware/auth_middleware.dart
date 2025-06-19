import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    if (authController.authState == AuthState.unauthenticated) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    return null;
  }
}

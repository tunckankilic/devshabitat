import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'responsive_auth_wrapper.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return ResponsiveAuthWrapper(
      authController: authController,
      isLogin: false,
    );
  }
}

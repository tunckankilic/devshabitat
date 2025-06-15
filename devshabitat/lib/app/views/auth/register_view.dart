import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enhanced_auth_controller.dart';
import 'responsive_auth_wrapper.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<EnhancedAuthController>();
    return ResponsiveAuthWrapper(
      authController: authController,
      isLogin: false,
    );
  }
}

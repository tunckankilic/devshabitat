import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/form_validation_controller.dart';
import '../../../controllers/github_validation_controller.dart';
import '../widgets/glass_register_card.dart';

class SmallPhoneRegister extends StatelessWidget {
  final authController = Get.find<AuthController>();
  final formController = Get.find<FormValidationController>();
  final githubController = Get.find<GitHubValidationController>();

  SmallPhoneRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GlassRegisterCard(
            onRegister: () {
              if (formController.isFormValid) {
                authController.createUserWithEmailAndPassword();
              }
            },
            onGitHubValidation: (username) {
              githubController.validateGitHubUsername(username);
            },
          ),
        ),
      ),
    );
  }
}

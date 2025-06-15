import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/form_validation_controller.dart';
import '../../../controllers/github_validation_controller.dart';
import '../widgets/glass_register_card.dart';

class TabletRegister extends StatelessWidget {
  final authController = Get.find<AuthController>();
  final formController = Get.find<FormValidationController>();
  final githubController = Get.find<GitHubValidationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Text(
                  'DevsHabitat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 480.w),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

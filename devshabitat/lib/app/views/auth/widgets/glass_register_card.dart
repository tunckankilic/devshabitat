import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/form_validation_controller.dart';
import '../../../controllers/github_validation_controller.dart';

class GlassRegisterCard extends StatelessWidget {
  final VoidCallback onRegister;
  final Function(String) onGitHubValidation;

  const GlassRegisterCard({
    super.key,
    required this.onRegister,
    required this.onGitHubValidation,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final formController = Get.find<FormValidationController>();
    final githubController = Get.find<GitHubValidationController>();

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kayıt Ol',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          TextField(
            controller: authController.emailController,
            onChanged: formController.validateEmail,
            decoration: InputDecoration(
              labelText: 'E-posta',
              errorText: formController.emailError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: authController.passwordController,
            onChanged: formController.validatePassword,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Şifre',
              errorText: formController.passwordError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: authController.confirmPasswordController,
            onChanged: formController.validateConfirmPassword,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Şifre Tekrarı',
              errorText: formController.confirmPasswordError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: authController.usernameController,
            onChanged: formController.validateUsername,
            decoration: InputDecoration(
              labelText: 'Kullanıcı Adı',
              errorText: formController.usernameError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: authController.githubUsernameController,
            onChanged: onGitHubValidation,
            decoration: InputDecoration(
              labelText: 'GitHub Kullanıcı Adı',
              errorText: githubController.error.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Obx(() => ElevatedButton(
                onPressed: formController.isFormValid ? onRegister : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Kayıt Ol',
                  style: TextStyle(fontSize: 16.sp),
                ),
              )),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Zaten hesabın var mı? Giriş yap',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}

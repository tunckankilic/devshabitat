import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/form_validation_controller.dart';
import '../../../controllers/github_validation_controller.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../services/responsive_performance_service.dart';

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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Container(
      padding: EdgeInsets.all(
        responsive.responsiveValue(
          mobile: 24.w,
          tablet: 32.w,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(
            mobile: 16.r,
            tablet: 20.r,
          ),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: responsive.responsiveValue(
            mobile: 1.5,
            tablet: 2.0,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kayıt Ol',
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'glass_register_title',
                mobileSize: 24.sp,
                tabletSize: 28.sp,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: responsive.responsiveValue(
              mobile: 24.h,
              tablet: 32.h,
            ),
          ),
          TextField(
            controller: authController.emailController,
            onChanged: formController.validateEmail,
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'glass_register_text',
                mobileSize: 16.sp,
                tabletSize: 18.sp,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'E-posta',
              labelStyle: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'glass_register_label',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
              errorText: formController.emailError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  responsive.responsiveValue(
                    mobile: 8.r,
                    tablet: 12.r,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: responsive.responsiveValue(
                  mobile: 16.w,
                  tablet: 20.w,
                ),
                vertical: responsive.responsiveValue(
                  mobile: 12.h,
                  tablet: 16.h,
                ),
              ),
            ),
          ),
          SizedBox(
            height: responsive.responsiveValue(
              mobile: 16.h,
              tablet: 20.h,
            ),
          ),
          TextField(
            controller: authController.passwordController,
            onChanged: formController.validatePassword,
            obscureText: true,
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'glass_register_text',
                mobileSize: 16.sp,
                tabletSize: 18.sp,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Şifre',
              labelStyle: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'glass_register_label',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
              errorText: formController.passwordError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  responsive.responsiveValue(
                    mobile: 8.r,
                    tablet: 12.r,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: responsive.responsiveValue(
                  mobile: 16.w,
                  tablet: 20.w,
                ),
                vertical: responsive.responsiveValue(
                  mobile: 12.h,
                  tablet: 16.h,
                ),
              ),
            ),
          ),
          SizedBox(
            height: responsive.responsiveValue(
              mobile: 16.h,
              tablet: 20.h,
            ),
          ),
          TextField(
            controller: authController.confirmPasswordController,
            onChanged: formController.validateConfirmPassword,
            obscureText: true,
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'glass_register_text',
                mobileSize: 16.sp,
                tabletSize: 18.sp,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Şifre Tekrarı',
              labelStyle: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'glass_register_label',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
              errorText: formController.confirmPasswordError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  responsive.responsiveValue(
                    mobile: 8.r,
                    tablet: 12.r,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: responsive.responsiveValue(
                  mobile: 16.w,
                  tablet: 20.w,
                ),
                vertical: responsive.responsiveValue(
                  mobile: 12.h,
                  tablet: 16.h,
                ),
              ),
            ),
          ),
          SizedBox(
            height: responsive.responsiveValue(
              mobile: 16.h,
              tablet: 20.h,
            ),
          ),
          TextField(
            controller: authController.usernameController,
            onChanged: formController.validateUsername,
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'glass_register_text',
                mobileSize: 16.sp,
                tabletSize: 18.sp,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Kullanıcı Adı',
              labelStyle: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'glass_register_label',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
              errorText: formController.usernameError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  responsive.responsiveValue(
                    mobile: 8.r,
                    tablet: 12.r,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: responsive.responsiveValue(
                  mobile: 16.w,
                  tablet: 20.w,
                ),
                vertical: responsive.responsiveValue(
                  mobile: 12.h,
                  tablet: 16.h,
                ),
              ),
            ),
          ),
          SizedBox(
            height: responsive.responsiveValue(
              mobile: 16.h,
              tablet: 20.h,
            ),
          ),
          TextField(
            controller: authController.githubUsernameController,
            onChanged: onGitHubValidation,
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'glass_register_text',
                mobileSize: 16.sp,
                tabletSize: 18.sp,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'GitHub Kullanıcı Adı',
              labelStyle: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'glass_register_label',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
              errorText: githubController.error.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  responsive.responsiveValue(
                    mobile: 8.r,
                    tablet: 12.r,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: responsive.responsiveValue(
                  mobile: 16.w,
                  tablet: 20.w,
                ),
                vertical: responsive.responsiveValue(
                  mobile: 12.h,
                  tablet: 16.h,
                ),
              ),
            ),
          ),
          SizedBox(
            height: responsive.responsiveValue(
              mobile: 24.h,
              tablet: 32.h,
            ),
          ),
          Obx(() => ElevatedButton(
                onPressed: formController.isFormValid ? onRegister : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: responsive.responsiveValue(
                      mobile: 16.h,
                      tablet: 20.h,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      responsive.responsiveValue(
                        mobile: 8.r,
                        tablet: 12.r,
                      ),
                    ),
                  ),
                ),
                child: Text(
                  'Kayıt Ol',
                  style: TextStyle(
                    fontSize: performanceService.getOptimizedTextSize(
                      cacheKey: 'glass_register_button',
                      mobileSize: 16.sp,
                      tabletSize: 18.sp,
                    ),
                  ),
                ),
              )),
          SizedBox(
            height: responsive.responsiveValue(
              mobile: 16.h,
              tablet: 20.h,
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Zaten hesabın var mı? Giriş yap',
              style: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'glass_register_link',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/responsive_form_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/adaptive_loading_indicator.dart';

class SmallPhoneLogin extends StatelessWidget {
  const SmallPhoneLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32.h),
                Image.asset(
                  'assets/images/logo.png',
                  height: 80.h,
                ),
                SizedBox(height: 32.h),
                Text(
                  'Hoş Geldiniz',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'DevHabitat\'a giriş yapın',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                ResponsiveFormField(
                  label: 'Email',
                  hint: 'ornek@email.com',
                  controller: authController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email adresi gerekli';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Geçerli bir email adresi girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                ResponsiveFormField(
                  label: 'Şifre',
                  hint: '••••••••',
                  controller: authController.passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre gerekli';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalı';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed('/forgot-password');
                    },
                    child: const Text('Şifremi Unuttum'),
                  ),
                ),
                SizedBox(height: 24.h),
                Obx(() {
                  final isLoading = authController.isLoading;
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              authController.signInWithEmailAndPassword();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: isLoading
                        ? const AdaptiveLoadingIndicator(color: Colors.white)
                        : const Text('Giriş Yap'),
                  );
                }),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const Text('veya'),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 24.h),
                SocialLoginButton(
                  text: 'Google ile Giriş Yap',
                  iconPath: 'assets/icons/google.png',
                  onPressed: authController.signInWithGoogle,
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                ),
                SizedBox(height: 12.h),
                SocialLoginButton(
                  text: 'Facebook ile Giriş Yap',
                  iconPath: 'assets/icons/facebook.png',
                  backgroundColor: const Color(0xFF1877F2),
                  textColor: Colors.white,
                  onPressed: authController.signInWithFacebook,
                ),
                SizedBox(height: 12.h),
                SocialLoginButton(
                  text: 'GitHub ile Giriş Yap',
                  iconPath: 'assets/icons/github.png',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  onPressed: authController.signInWithGithub,
                ),
                SizedBox(height: 12.h),
                SocialLoginButton(
                  text: 'Apple ile Giriş Yap',
                  iconPath: 'assets/icons/apple.png',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  onPressed: authController.signInWithApple,
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Hesabınız yok mu?'),
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/signup');
                      },
                      child: const Text('Kayıt Ol'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

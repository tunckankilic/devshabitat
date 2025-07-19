import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/auth_controller.dart';
import '../../../constants/app_assets.dart';
import '../../base/base_view.dart';
import '../widgets/responsive_form_field.dart';
import '../widgets/social_login_button.dart';

class LargePhoneLogin extends BaseView<AuthController> {
  const LargePhoneLogin({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32.h),
                Center(
                  child: Image.asset(
                    AppAssets.logo,
                    width: 120.w,
                    height: 120.w,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'Hoş Geldiniz!',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'DevHabitat\'a giriş yapın',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32.h),
                ResponsiveFormField(
                  label: 'E-posta',
                  hint: 'E-posta adresinizi girin',
                  controller: controller.emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta adresi gerekli';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.h),
                ResponsiveFormField(
                  label: 'Şifre',
                  hint: 'Şifrenizi girin',
                  controller: controller.passwordController,
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
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed('/forgot-password');
                    },
                    child: Text(
                      'Şifremi Unuttum',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.emailController.text.isNotEmpty &&
                          controller.passwordController.text.isNotEmpty) {
                        controller.signInWithEmailAndPassword();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'veya',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                SizedBox(height: 24.h),
                SocialLoginButton(
                  text: 'Google ile Giriş Yap',
                  iconPath: 'assets/icons/google.png',
                  onPressed: controller.signInWithGoogle,
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                ),
                SizedBox(height: 12.h),
                /*
                SocialLoginButton(
                  text: 'Facebook ile Giriş Yap',
                  iconPath: 'assets/icons/facebook.png',
                  onPressed: controller.signInWithFacebook,
                  backgroundColor: const Color(0xFF1877F2),
                  textColor: Colors.white,
                ),
                */
                SizedBox(height: 12.h),
                SocialLoginButton(
                  text: 'Apple ile Giriş Yap',
                  iconPath: 'assets/icons/apple.png',
                  onPressed: controller.signInWithApple,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hesabınız yok mu?',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/signup');
                      },
                      child: Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
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

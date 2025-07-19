import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/auth_controller.dart';
import '../../../constants/app_assets.dart';
import '../../base/base_view.dart';
import '../widgets/responsive_form_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/adaptive_loading_indicator.dart';

class TabletLogin extends BaseView<AuthController> {
  const TabletLogin({super.key});

  @override
  Widget buildView(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sol taraf - Görsel ve tanıtım
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.logo,
                        height: 120.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 40.h),
                      Text(
                        'DevHabitat\'a Hoş Geldiniz',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 48.w),
                        child: Text(
                          'Yazılım geliştiriciler için özel bir platform. Projelerinizi paylaşın, işbirliği yapın ve birlikte büyüyün.',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Sağ taraf - Giriş formu
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(48.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 480.w),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Giriş Yap',
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 40.h),
                        ResponsiveFormField(
                          label: 'Email',
                          hint: 'ornek@email.com',
                          controller: controller.emailController,
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
                        SizedBox(height: 24.h),
                        ResponsiveFormField(
                          label: 'Şifre',
                          hint: '••••••••',
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
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Obx(() {
                          final isLoading = controller.isLoading;
                          return ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      controller.signInWithEmailAndPassword();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: isLoading
                                ? const AdaptiveLoadingIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Giriş Yap',
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                          );
                        }),
                        SizedBox(height: 32.h),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Text(
                                'veya',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        Row(
                          children: [
                            Expanded(
                              child: SocialLoginButton(
                                text: 'Google',
                                iconPath: 'assets/icons/google.png',
                                onPressed: controller.signInWithGoogle,
                                backgroundColor: Colors.white,
                                textColor: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            /*
                            Expanded(
                              child: SocialLoginButton(
                                text: 'Facebook',
                                iconPath: 'assets/icons/facebook.png',
                                backgroundColor: const Color(0xFF1877F2),
                                textColor: Colors.white,
                                onPressed: controller.signInWithFacebook,
                              ),
                            ),
                            */
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: SocialLoginButton(
                                text: 'GitHub',
                                iconPath: 'assets/icons/github.png',
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                onPressed: controller.signInWithGithub,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: SocialLoginButton(
                                text: 'Apple',
                                iconPath: 'assets/icons/apple.png',
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                onPressed: controller.signInWithApple,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hesabınız yok mu?',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed('/signup');
                              },
                              child: Text(
                                'Kayıt Ol',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

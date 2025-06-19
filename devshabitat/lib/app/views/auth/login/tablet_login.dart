import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/responsive_form_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/adaptive_loading_indicator.dart';

class TabletLogin extends StatelessWidget {
  const TabletLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
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
                        'assets/images/logo.png',
                        height: 120,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'DevHabitat\'a Hoş Geldiniz',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Yazılım geliştiriciler için özel bir platform. Projelerinizi paylaşın, işbirliği yapın ve birlikte büyüyün.',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
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
                padding: const EdgeInsets.all(48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
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
                        const SizedBox(height: 40),
                        ResponsiveFormField(
                          label: 'Email',
                          hint: 'ornek@email.com',
                          controller: emailController,
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
                        const SizedBox(height: 24),
                        ResponsiveFormField(
                          label: 'Şifre',
                          hint: '••••••••',
                          controller: passwordController,
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
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed('/forgot-password');
                            },
                            child: const Text('Şifremi Unuttum'),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Obx(() {
                          final isLoading = authController.isLoading;
                          return ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      authController
                                          .signInWithEmailAndPassword();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const AdaptiveLoadingIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Giriş Yap',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          );
                        }),
                        const SizedBox(height: 32),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'veya',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: SocialLoginButton(
                                text: 'Google',
                                iconPath: 'assets/icons/google.png',
                                onPressed: authController.signInWithGoogle,
                                backgroundColor: Colors.white,
                                textColor: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SocialLoginButton(
                                text: 'Facebook',
                                iconPath: 'assets/icons/facebook.png',
                                backgroundColor: const Color(0xFF1877F2),
                                textColor: Colors.white,
                                onPressed: authController.signInWithFacebook,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SocialLoginButton(
                                text: 'GitHub',
                                iconPath: 'assets/icons/github.png',
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                onPressed: authController.signInWithGithub,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SocialLoginButton(
                                text: 'Apple',
                                iconPath: 'assets/icons/apple.png',
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                onPressed: authController.signInWithApple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Hesabınız yok mu?',
                              style: TextStyle(fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed('/signup');
                              },
                              child: const Text(
                                'Kayıt Ol',
                                style: TextStyle(fontSize: 16),
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

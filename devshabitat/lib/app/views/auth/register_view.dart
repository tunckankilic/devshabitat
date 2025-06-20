import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/registration_controller.dart';
import '../../controllers/github_validation_controller.dart';
import 'widgets/responsive_form_field.dart';
import 'widgets/adaptive_loading_indicator.dart';

class RegisterView extends StatelessWidget {
  final RegistrationController _controller = Get.find<RegistrationController>();
  final GitHubValidationController _githubController =
      Get.find<GitHubValidationController>();

  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32.h),
              // Logo ve başlık
              Image.asset(
                'assets/images/logo.png',
                height: 80.h,
              ),
              SizedBox(height: 32.h),
              Text(
                'Kayıt Ol',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Obx(() {
                final socialData = _controller.socialAuthData;
                return Text(
                  socialData != null
                      ? '${socialData['provider'].toString().capitalizeFirst} hesabınızla kayıt olun'
                      : 'DevHabitat\'a hoş geldiniz',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                );
              }),
              SizedBox(height: 32.h),
              // Kayıt formu
              Form(
                child: Column(
                  children: [
                    // Ad ve Soyad
                    Row(
                      children: [
                        Expanded(
                          child: ResponsiveFormField(
                            label: 'Ad',
                            controller: _controller.firstNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ad gerekli';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ResponsiveFormField(
                            label: 'Soyad',
                            controller: _controller.lastNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Soyad gerekli';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Email
                    Obx(() => ResponsiveFormField(
                          label: 'Email',
                          controller: _controller.emailController,
                          enabled: _controller.socialAuthData == null,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email gerekli';
                            }
                            if (!GetUtils.isEmail(value)) {
                              return 'Geçerli bir email adresi girin';
                            }
                            return null;
                          },
                        )),
                    SizedBox(height: 16.h),
                    // Kullanıcı adı
                    ResponsiveFormField(
                      label: 'Kullanıcı Adı',
                      controller: _controller.usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kullanıcı adı gerekli';
                        }
                        if (value.length < 3) {
                          return 'Kullanıcı adı en az 3 karakter olmalı';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    // GitHub kullanıcı adı
                    Obx(() {
                      final socialData = _controller.socialAuthData;
                      return ResponsiveFormField(
                        label: 'GitHub Kullanıcı Adı',
                        controller: _controller.githubUsernameController,
                        enabled: socialData == null ||
                            socialData['provider'] != 'github',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null; // GitHub kullanıcı adı opsiyonel
                          }
                          return _githubController.error.value;
                        },
                        onFieldSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _githubController.validateGitHubUsername(value);
                          }
                        },
                      );
                    }),
                    SizedBox(height: 16.h),
                    // Şifre
                    ResponsiveFormField(
                      label: 'Şifre',
                      controller: _controller.passwordController,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre gerekli';
                        }
                        if (value.length < 8) {
                          return 'Şifre en az 8 karakter olmalı';
                        }
                        if (!value.contains(RegExp(r'[A-Z]'))) {
                          return 'Şifre en az bir büyük harf içermeli';
                        }
                        if (!value.contains(RegExp(r'[a-z]'))) {
                          return 'Şifre en az bir küçük harf içermeli';
                        }
                        if (!value.contains(RegExp(r'[0-9]'))) {
                          return 'Şifre en az bir rakam içermeli';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    // Şifre tekrarı
                    ResponsiveFormField(
                      label: 'Şifre Tekrarı',
                      controller: _controller.confirmPasswordController,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre tekrarı gerekli';
                        }
                        if (value != _controller.passwordController.text) {
                          return 'Şifreler eşleşmiyor';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    // Kayıt ol butonu
                    Obx(() => ElevatedButton(
                          onPressed: _controller.isLoading
                              ? null
                              : () {
                                  if (_controller.canProceed) {
                                    _controller.nextStep();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: _controller.isLoading
                              ? const AdaptiveLoadingIndicator()
                              : const Text('Kayıt Ol'),
                        )),
                    SizedBox(height: 16.h),
                    // Giriş yap linki
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Zaten hesabın var mı? Giriş yap',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

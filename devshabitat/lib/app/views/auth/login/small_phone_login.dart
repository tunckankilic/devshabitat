import 'package:devshabitat/app/constants/app_assets.dart';
import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/core/config/security_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';

class SmallPhoneLogin extends GetView<AuthController> {
  final _responsiveController = Get.find<ResponsiveController>();

  SmallPhoneLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        padding: _responsiveController.responsivePadding(all: 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
              theme.colorScheme.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -size.width * 0.4,
              right: -size.width * 0.4,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.3,
              left: -size.width * 0.3,
              child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 20),
                  SvgPicture.asset(
                    AppAssets.logo,
                    height: _responsiveController.responsiveValue(
                      mobile: 100.0,
                      tablet: 140.0,
                    ),
                  ),
                  SizedBox(
                    height: _responsiveController.responsiveValue(
                      mobile: 24.0,
                      tablet: 32.0,
                    ),
                  ),

                  Text(
                    AppStrings.welcome,
                    style: TextStyle(
                      fontSize: _responsiveController.responsiveValue(
                        mobile: 24.0,
                        tablet: 32.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(
                    height: _responsiveController.responsiveValue(
                      mobile: 8.0,
                      tablet: 12.0,
                    ),
                  ),
                  Text(
                    AppStrings.loginDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _responsiveController.responsiveValue(
                        mobile: 14.0,
                        tablet: 16.0,
                      ),
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(
                    height: _responsiveController.responsiveValue(
                      mobile: 24.0,
                      tablet: 32.0,
                    ),
                  ),
                  Form(
                    child: Column(
                      children: [
                        Hero(
                          tag: 'email_field',
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'E-posta adresi gerekli';
                                }
                                if (value.length >
                                    SecurityConfig.MAX_EMAIL_LENGTH) {
                                  return 'E-posta adresi çok uzun';
                                }
                                if (!SecurityConfig.isEmailValid(value)) {
                                  return 'Geçerli bir e-posta adresi girin';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                labelText: AppStrings.email,
                                hintText: 'ornek@email.com',
                                helperText: 'Kayıtlı e-posta adresinizi girin',
                                helperStyle: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                  fontSize: _responsiveController
                                      .responsiveValue(
                                        mobile: 12.0,
                                        tablet: 14.0,
                                      ),
                                ),
                                labelStyle: TextStyle(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.8,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                  fontSize: _responsiveController
                                      .responsiveValue(
                                        mobile: 14.0,
                                        tablet: 16.0,
                                      ),
                                ),
                                prefixIcon: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 12),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.email_rounded,
                                    color: theme.colorScheme.primary,
                                    size: _responsiveController.responsiveValue(
                                      mobile: 20.0,
                                      tablet: 24.0,
                                    ),
                                  ),
                                ),
                                contentPadding: _responsiveController
                                    .responsivePadding(
                                      horizontal: 16.0,
                                      vertical: 20.0,
                                    ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
                              style: TextStyle(
                                fontSize: _responsiveController.responsiveValue(
                                  mobile: 16.0,
                                  tablet: 18.0,
                                ),
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: _responsiveController.responsiveValue(
                            mobile: 16.0,
                            tablet: 24.0,
                          ),
                        ),
                        Hero(
                          tag: 'password_field',
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Obx(
                              () => TextFormField(
                                controller: controller.passwordController,
                                obscureText: !controller.isPasswordVisible,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Şifre gerekli';
                                  }
                                  if (value.length <
                                      SecurityConfig.MIN_PASSWORD_LENGTH) {
                                    return 'Şifre en az ${SecurityConfig.MIN_PASSWORD_LENGTH} karakter olmalı';
                                  }
                                  if (value.length >
                                      SecurityConfig.MAX_PASSWORD_LENGTH) {
                                    return 'Şifre en fazla ${SecurityConfig.MAX_PASSWORD_LENGTH} karakter olmalı';
                                  }
                                  if (!SecurityConfig.isPasswordValid(value)) {
                                    return 'Şifre en az bir harf ve bir rakam içermeli';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  labelText: AppStrings.password,
                                  hintText: '••••••••',
                                  helperText: 'En az 8 karakter',
                                  helperStyle: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                    fontSize: _responsiveController
                                        .responsiveValue(
                                          mobile: 12.0,
                                          tablet: 14.0,
                                        ),
                                  ),
                                  labelStyle: TextStyle(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                    fontSize: _responsiveController
                                        .responsiveValue(
                                          mobile: 14.0,
                                          tablet: 16.0,
                                        ),
                                  ),
                                  prefixIcon: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.lock_rounded,
                                      color: theme.colorScheme.primary,
                                      size: _responsiveController
                                          .responsiveValue(
                                            mobile: 20.0,
                                            tablet: 24.0,
                                          ),
                                    ),
                                  ),
                                  suffixIcon: Container(
                                    margin: EdgeInsets.only(right: 12),
                                    child: IconButton(
                                      icon: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: Icon(
                                          controller.isPasswordVisible
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          key: ValueKey(
                                            controller.isPasswordVisible,
                                          ),
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      onPressed:
                                          controller.togglePasswordVisibility,
                                    ),
                                  ),
                                  contentPadding: _responsiveController
                                      .responsivePadding(
                                        horizontal: 16.0,
                                        vertical: 20.0,
                                      ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                style: TextStyle(
                                  fontSize: _responsiveController
                                      .responsiveValue(
                                        mobile: 16.0,
                                        tablet: 18.0,
                                      ),
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: _responsiveController.responsiveValue(
                            mobile: 8.0,
                            tablet: 12.0,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                Get.toNamed(AppRoutes.forgotPassword),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                            ),
                            child: Text(
                              AppStrings.forgotPassword,
                              style: TextStyle(
                                fontSize: _responsiveController.responsiveValue(
                                  mobile: 12.0,
                                  tablet: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: _responsiveController.responsiveValue(
                            mobile: 24.0,
                            tablet: 32.0,
                          ),
                        ),
                        Obx(
                          () => Hero(
                            tag: 'login_button',
                            child: Container(
                              width: double.infinity,
                              height: _responsiveController.responsiveValue(
                                mobile: 56.0,
                                tablet: 64.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    Color.lerp(
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                      0.6,
                                    )!,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: controller.isLoading
                                      ? null
                                      : () => controller
                                            .signInWithEmailAndPassword(
                                              controller.emailController.text,
                                              controller
                                                  .passwordController
                                                  .text,
                                            ),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    padding: _responsiveController
                                        .responsivePadding(
                                          vertical: 16.0,
                                          horizontal: 32.0,
                                        ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (controller.isLoading)
                                          SizedBox(
                                            width: _responsiveController
                                                .responsiveValue(
                                                  mobile: 24.0,
                                                  tablet: 32.0,
                                                ),
                                            height: _responsiveController
                                                .responsiveValue(
                                                  mobile: 24.0,
                                                  tablet: 32.0,
                                                ),
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    theme.colorScheme.onPrimary,
                                                  ),
                                              strokeWidth: 3,
                                            ),
                                          )
                                        else ...[
                                          Text(
                                            AppStrings.login,
                                            style: TextStyle(
                                              fontSize: _responsiveController
                                                  .responsiveValue(
                                                    mobile: 16.0,
                                                    tablet: 18.0,
                                                  ),
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: theme.colorScheme.onPrimary,
                                            size: _responsiveController
                                                .responsiveValue(
                                                  mobile: 20.0,
                                                  tablet: 24.0,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: _responsiveController.responsiveValue(
                      mobile: 24.0,
                      tablet: 32.0,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.2,
                          ),
                        ),
                      ),
                      Padding(
                        padding: _responsiveController.responsivePadding(
                          horizontal: 16.0,
                        ),
                        child: Text(
                          'veya',
                          style: TextStyle(
                            fontSize: _responsiveController.responsiveValue(
                              mobile: 12.0,
                              tablet: 14.0,
                            ),
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.7,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: _responsiveController.responsiveValue(
                      mobile: 24.0,
                      tablet: 32.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.noAccount,
                        style: TextStyle(
                          fontSize: _responsiveController.responsiveValue(
                            mobile: 12.0,
                            tablet: 14.0,
                          ),
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.register),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                        child: Text(
                          AppStrings.register,
                          style: TextStyle(
                            fontSize: _responsiveController.responsiveValue(
                              mobile: 12.0,
                              tablet: 14.0,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

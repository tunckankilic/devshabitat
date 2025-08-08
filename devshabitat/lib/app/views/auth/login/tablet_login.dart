import 'package:devshabitat/app/constants/app_assets.dart';
import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';
import '../widgets/social_auth_buttons.dart';

class TabletLogin extends GetView<AuthController> {
  final _responsiveController = Get.find<ResponsiveController>();

  TabletLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.background, theme.colorScheme.surface],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Sol taraf - Görsel ve tanıtım
              Expanded(
                flex: 1,
                child: Container(
                  padding: _responsiveController.responsivePadding(all: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.logo,
                        height: _responsiveController.responsiveValue(
                          mobile: 160.0,
                          tablet: 200.0,
                        ),
                      ),
                      SizedBox(
                        height: _responsiveController.responsiveValue(
                          mobile: 40.0,
                          tablet: 56.0,
                        ),
                      ),
                      Text(
                        AppStrings.welcome,
                        style: TextStyle(
                          fontSize: _responsiveController.responsiveValue(
                            mobile: 32.0,
                            tablet: 40.0,
                          ),
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: _responsiveController.responsiveValue(
                          mobile: 16.0,
                          tablet: 24.0,
                        ),
                      ),
                      Padding(
                        padding: _responsiveController.responsivePadding(
                          horizontal: 48.0,
                        ),
                        child: Text(
                          AppStrings.welcomeDescription,
                          style: TextStyle(
                            fontSize: _responsiveController.responsiveValue(
                              mobile: 18.0,
                              tablet: 22.0,
                            ),
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.7,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Sağ taraf - Giriş formu
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      bottomLeft: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(-10, 0),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: _responsiveController.responsivePadding(all: 48.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: _responsiveController.responsiveValue(
                          mobile: 480.0,
                          tablet: 600.0,
                        ),
                      ),
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppStrings.login,
                              style: TextStyle(
                                fontSize: _responsiveController.responsiveValue(
                                  mobile: 32.0,
                                  tablet: 40.0,
                                ),
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onBackground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: _responsiveController.responsiveValue(
                                mobile: 40.0,
                                tablet: 56.0,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadowColor.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: controller.emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: AppStrings.email,
                                  labelStyle: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: theme.colorScheme.primary,
                                    size: _responsiveController.responsiveValue(
                                      mobile: 24.0,
                                      tablet: 32.0,
                                    ),
                                  ),
                                  contentPadding: _responsiveController
                                      .responsivePadding(
                                        horizontal: 16.0,
                                        vertical: 16.0,
                                      ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
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
                                ),
                              ),
                            ),
                            SizedBox(
                              height: _responsiveController.responsiveValue(
                                mobile: 24.0,
                                tablet: 32.0,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadowColor.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Obx(
                                () => TextFormField(
                                  controller: controller.passwordController,
                                  obscureText: !controller.isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: AppStrings.password,
                                    labelStyle: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: theme.colorScheme.primary,
                                      size: _responsiveController
                                          .responsiveValue(
                                            mobile: 24.0,
                                            tablet: 32.0,
                                          ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: theme.colorScheme.primary,
                                      ),
                                      onPressed:
                                          controller.togglePasswordVisibility,
                                    ),
                                    contentPadding: _responsiveController
                                        .responsivePadding(
                                          horizontal: 16.0,
                                          vertical: 16.0,
                                        ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
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
                                    fontSize: _responsiveController
                                        .responsiveValue(
                                          mobile: 14.0,
                                          tablet: 16.0,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: _responsiveController.responsiveValue(
                                mobile: 32.0,
                                tablet: 40.0,
                              ),
                            ),
                            Obx(() {
                              return ElevatedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () =>
                                          controller.signInWithEmailAndPassword(
                                            controller.emailController.text,
                                            controller.passwordController.text,
                                          ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  padding: _responsiveController
                                      .responsivePadding(
                                        vertical: 20.0,
                                        horizontal: 32.0,
                                      ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: controller.isLoading
                                      ? SizedBox(
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
                                          ),
                                        )
                                      : Text(
                                          AppStrings.login,
                                          style: TextStyle(
                                            fontSize: _responsiveController
                                                .responsiveValue(
                                                  mobile: 16.0,
                                                  tablet: 18.0,
                                                ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              );
                            }),
                            SizedBox(
                              height: _responsiveController.responsiveValue(
                                mobile: 32.0,
                                tablet: 40.0,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.2),
                                  ),
                                ),
                                Padding(
                                  padding: _responsiveController
                                      .responsivePadding(horizontal: 24.0),
                                  child: Text(
                                    AppStrings.or,
                                    style: TextStyle(
                                      fontSize: _responsiveController
                                          .responsiveValue(
                                            mobile: 16.0,
                                            tablet: 18.0,
                                          ),
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: _responsiveController.responsiveValue(
                                mobile: 32.0,
                                tablet: 40.0,
                              ),
                            ),
                            // Sosyal/GitHub CTA
                            SocialAuthButtons(
                              isLogin: true,
                              onGithubCTA: () async {
                                final token = await controller
                                    .signInWithGithub();
                                if (token != null) {
                                  Get.offAllNamed(AppRoutes.home);
                                } else {
                                  Get.toNamed(AppRoutes.register);
                                }
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppStrings.noAccount,
                                  style: TextStyle(
                                    fontSize: _responsiveController
                                        .responsiveValue(
                                          mobile: 16.0,
                                          tablet: 18.0,
                                        ),
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.7),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.register),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                  ),
                                  child: Text(
                                    AppStrings.register,
                                    style: TextStyle(
                                      fontSize: _responsiveController
                                          .responsiveValue(
                                            mobile: 16.0,
                                            tablet: 18.0,
                                          ),
                                      fontWeight: FontWeight.bold,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

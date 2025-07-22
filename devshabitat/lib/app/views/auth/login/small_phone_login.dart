import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../widgets/social_login_button.dart';

class SmallPhoneLogin extends GetView<AuthController> {
  final _responsiveController = Get.find<ResponsiveController>();

  SmallPhoneLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: _responsiveController.responsivePadding(all: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: _responsiveController.responsiveValue(
                mobile: 120.0,
                tablet: 160.0,
              ),
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: _responsiveController.responsiveValue(
                mobile: 32.0,
                tablet: 48.0,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: SocialLoginButton(
                text: AppStrings.continueWithGoogle,
                imagePath: 'assets/icons/google.png',
                onPressed: () => controller.signInWithGoogle(),
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                isOutlined: true,
              ),
            ),
            SizedBox(
              height: _responsiveController.responsiveValue(
                mobile: 12.0,
                tablet: 16.0,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: SocialLoginButton(
                text: AppStrings.continueWithApple,
                imagePath: 'assets/icons/apple-logo.png',
                onPressed: () => controller.signInWithApple(),
                backgroundColor: Colors.black,
                textColor: Colors.white,
                isAppleButton: true,
              ),
            ),
            SizedBox(
              height: _responsiveController.responsiveValue(
                mobile: 12.0,
                tablet: 16.0,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: SocialLoginButton(
                text: AppStrings.continueWithGithub,
                imagePath: 'assets/icons/github.png',
                onPressed: () => controller.signInWithGithub(),
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

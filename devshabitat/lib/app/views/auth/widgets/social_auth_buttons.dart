import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_assets.dart';
import '../../../controllers/responsive_controller.dart';
import 'dart:io' show Platform;
import 'social_login_button.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onGithubSignIn;
  // final VoidCallback onFacebookSignIn;
  final VoidCallback onAppleSignIn;

  const SocialAuthButtons({
    super.key,
    required this.onGoogleSignIn,
    required this.onGithubSignIn,
    // required this.onFacebookSignIn,
    required this.onAppleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: Platform.isIOS ? _buildIOSButtons() : _buildAndroidButtons(),
    );
  }

  List<Widget> _buildIOSButtons() {
    final responsive = Get.find<ResponsiveController>();

    return [
      // iOS'ta Apple Sign In en üstte
      SocialLoginButton(
        text: 'Apple ile Giriş Yap',
        iconPath: AppAssets.appleLogo,
        onPressed: onAppleSignIn,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      ),
      SizedBox(
        height: responsive.responsiveValue(
          mobile: 16.h,
          tablet: 20.h,
        ),
      ),
      SocialLoginButton(
        text: 'GitHub ile Giriş Yap',
        iconPath: AppAssets.githubLogo,
        onPressed: onGithubSignIn,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      ),
      SizedBox(
        height: responsive.responsiveValue(
          mobile: 16.h,
          tablet: 20.h,
        ),
      ),
      /*
      SocialLoginButton(
        text: 'Facebook ile Giriş Yap',
        iconPath: AppAssets.facebookLogo,
        onPressed: onFacebookSignIn,
        backgroundColor: const Color(0xFF1877F2),
        textColor: Colors.white,
      ),
      */
    ];
  }

  List<Widget> _buildAndroidButtons() {
    final responsive = Get.find<ResponsiveController>();

    return [
      // Android'de Google Sign In en üstte
      SocialLoginButton(
        text: 'Google ile Giriş Yap',
        iconPath: AppAssets.googleLogo,
        onPressed: onGoogleSignIn,
        backgroundColor: Colors.white,
        textColor: Colors.black87,
      ),
      SizedBox(
        height: responsive.responsiveValue(
          mobile: 16.h,
          tablet: 20.h,
        ),
      ),
      SocialLoginButton(
        text: 'GitHub ile Giriş Yap',
        iconPath: AppAssets.githubLogo,
        onPressed: onGithubSignIn,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      ),
      SizedBox(
        height: responsive.responsiveValue(
          mobile: 16.h,
          tablet: 20.h,
        ),
      ),
      /*
      SocialLoginButton(
        text: 'Facebook ile Giriş Yap',
        iconPath: AppAssets.facebookLogo,
        onPressed: onFacebookSignIn,
        backgroundColor: const Color(0xFF1877F2),
        textColor: Colors.white,
      ),
      */
    ];
  }
}

import 'package:devshabitat/app/constants/app_assets.dart';
import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';

class SocialAuthButtons extends StatelessWidget {
  final bool isLogin;
  final Function? onGoogleAuth;
  final Function? onAppleAuth;
  final Function? onFacebookAuth;

  const SocialAuthButtons({
    super.key,
    required this.isLogin,
    this.onGoogleAuth,
    this.onAppleAuth,
    this.onFacebookAuth,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Column(
      children: [
        SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
        Text(
          AppStrings.or,
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),

        // Google Button
        if (onGoogleAuth != null)
          _buildSocialButton(
            responsive,
            context,
            'With Google ${isLogin ? AppStrings.login : AppStrings.register}',
            AppAssets.googleIcon,
            onGoogleAuth!,
          ),

        SizedBox(height: responsive.responsiveValue(mobile: 12, tablet: 16)),

        // Apple Button
        if (onAppleAuth != null)
          _buildSocialButton(
            responsive,
            context,
            'With Apple ${isLogin ? AppStrings.login : AppStrings.register}',
            AppAssets.appleIcon,
            onAppleAuth!,
          ),
      ],
    );
  }

  Widget _buildSocialButton(
    ResponsiveController responsive,
    BuildContext context,
    String text,
    String iconPath,
    Function onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: responsive.responsiveValue(mobile: 48, tablet: 56),
      child: OutlinedButton(
        onPressed: () => onPressed(),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.responsiveValue(mobile: 16, tablet: 24),
            vertical: responsive.responsiveValue(mobile: 12, tablet: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              responsive.responsiveValue(mobile: 8, tablet: 12),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: responsive.responsiveValue(mobile: 20, tablet: 24),
              height: responsive.responsiveValue(mobile: 20, tablet: 24),
            ),
            SizedBox(width: responsive.responsiveValue(mobile: 12, tablet: 16)),
            Text(
              text,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

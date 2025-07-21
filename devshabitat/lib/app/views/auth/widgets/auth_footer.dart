import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';

class AuthFooter extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onToggleAuth;

  const AuthFooter({
    super.key,
    required this.isLogin,
    required this.onToggleAuth,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Column(
      children: [
        SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
        if (isLogin)
          TextButton(
            onPressed: () {
              // Şifremi unuttum işlevi
            },
            child: Text(
              AppStrings.forgotPassword,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLogin ? AppStrings.noAccount : AppStrings.alreadyHaveAccount,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                color: Colors.grey[600],
              ),
            ),
            TextButton(
              onPressed: onToggleAuth,
              child: Text(
                isLogin ? AppStrings.register : AppStrings.login,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
        Text(
          '© 2024 DevHabitat. All rights reserved.',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

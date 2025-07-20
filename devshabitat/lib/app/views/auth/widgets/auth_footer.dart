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
              'Şifremi Unuttum',
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
              isLogin ? 'Hesabınız yok mu?' : 'Zaten hesabınız var mı?',
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                color: Colors.grey[600],
              ),
            ),
            TextButton(
              onPressed: onToggleAuth,
              child: Text(
                isLogin ? 'Kayıt Ol' : 'Giriş Yap',
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
          '© 2024 DevHabitat. Tüm hakları saklıdır.',
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

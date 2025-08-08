import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';

class SocialAuthButtons extends StatelessWidget {
  final bool isLogin;
  final Function? onGoogleAuth;
  final Function? onAppleAuth;
  final Function? onFacebookAuth;
  final VoidCallback? onGithubCTA; // GitHub zorunluluğu için yönlendirme CTA

  const SocialAuthButtons({
    super.key,
    required this.isLogin,
    this.onGoogleAuth,
    this.onAppleAuth,
    this.onFacebookAuth,
    this.onGithubCTA,
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

        // GitHub zorunluluğu için yönlendirme CTA (opsiyonel göster)
        if (onGithubCTA != null) ...[
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
          Text(
            isLogin
                ? 'Hesabınız yoksa GitHub ile kayıt olabilirsiniz'
                : 'GitHub zorunlu, hesabınız yoksa önce GitHub’da hesap oluşturun',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onGithubCTA,
              child: Text(
                isLogin
                    ? 'GitHub ile devam et (kayıt veya giriş)'
                    : 'GitHub hesabı oluştur / bağla',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../constants/app_assets.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onGithubSignIn;
  final VoidCallback onFacebookSignIn;
  final VoidCallback onAppleSignIn;

  const SocialAuthButtons({
    super.key,
    required this.onGoogleSignIn,
    required this.onGithubSignIn,
    required this.onFacebookSignIn,
    required this.onAppleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSocialButton(
          onPressed: onGoogleSignIn,
          icon: AppAssets.googleLogo,
          label: 'Google ile Giriş Yap',
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          onPressed: onGithubSignIn,
          icon: AppAssets.githubLogo,
          label: 'GitHub ile Giriş Yap',
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          onPressed: onFacebookSignIn,
          icon: AppAssets.facebookLogo,
          label: 'Facebook ile Giriş Yap',
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          onPressed: onAppleSignIn,
          icon: AppAssets.appleLogo,
          label: 'Apple ile Giriş Yap',
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required String icon,
    required String label,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(
        icon,
        height: 24,
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}

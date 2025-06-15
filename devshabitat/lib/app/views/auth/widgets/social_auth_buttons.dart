import 'package:flutter/material.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onGithubSignIn;
  final VoidCallback onFacebookSignIn;
  final VoidCallback onAppleSignIn;

  const SocialAuthButtons({
    Key? key,
    required this.onGoogleSignIn,
    required this.onGithubSignIn,
    required this.onFacebookSignIn,
    required this.onAppleSignIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSocialButton(
          onPressed: onGoogleSignIn,
          icon: 'assets/images/google_logo.png',
          label: 'Google ile Giriş Yap',
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          onPressed: onGithubSignIn,
          icon: 'assets/images/github_logo.png',
          label: 'GitHub ile Giriş Yap',
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          onPressed: onFacebookSignIn,
          icon: 'assets/images/facebook_logo.png',
          label: 'Facebook ile Giriş Yap',
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          onPressed: onAppleSignIn,
          icon: 'assets/images/apple_logo.png',
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

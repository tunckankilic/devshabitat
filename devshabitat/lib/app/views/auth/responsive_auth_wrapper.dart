import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enhanced_auth_controller.dart';
import 'widgets/auth_form.dart';
import 'widgets/auth_header.dart';
import 'widgets/social_auth_buttons.dart';
import 'widgets/auth_footer.dart';

class ResponsiveAuthWrapper extends StatelessWidget {
  final EnhancedAuthController authController;
  final bool isLogin;

  const ResponsiveAuthWrapper({
    Key? key,
    required this.authController,
    this.isLogin = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1200) {
                    return _buildLargeLayout(context);
                  } else if (constraints.maxWidth > 800) {
                    return _buildMediumLayout(context);
                  } else {
                    return _buildSmallLayout(context);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildLeftColumn(context),
        ),
        const SizedBox(width: 48),
        Expanded(
          flex: 1,
          child: _buildRightColumn(context),
        ),
      ],
    );
  }

  Widget _buildMediumLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildLeftColumn(context),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 3,
          child: _buildRightColumn(context),
        ),
      ],
    );
  }

  Widget _buildSmallLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLeftColumn(context),
        const SizedBox(height: 32),
        _buildRightColumn(context),
      ],
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(isLogin: isLogin),
        const SizedBox(height: 24),
        SocialAuthButtons(
          onGoogleSignIn: () => authController.signInWithGoogle(),
          onGithubSignIn: () => authController.signInWithGithub(),
          onFacebookSignIn: () => authController.signInWithFacebook(),
          onAppleSignIn: () => authController.signInWithApple(),
        ),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthForm(
              isLogin: isLogin,
              onSubmit: (email, password) {
                if (isLogin) {
                  authController.signInWithEmailAndPassword(email, password);
                } else {
                  authController.signUpWithEmailAndPassword(email, password);
                }
              },
            ),
            const SizedBox(height: 24),
            AuthFooter(isLogin: isLogin),
          ],
        ),
      ),
    );
  }
}

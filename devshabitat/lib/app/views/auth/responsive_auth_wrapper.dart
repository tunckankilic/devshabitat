import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/responsive_controller.dart';
import 'widgets/auth_form.dart';
import 'widgets/auth_header.dart';
import 'widgets/social_auth_buttons.dart';
import 'widgets/auth_footer.dart';

class ResponsiveAuthWrapper extends StatelessWidget {
  final AuthController authController;
  final bool isLogin;

  const ResponsiveAuthWrapper({
    super.key,
    required this.authController,
    this.isLogin = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: responsive.responsivePadding(
                left: 24,
                right: 24,
                top: 24,
                bottom: 24,
              ),
              child: Obx(() => _buildResponsiveLayout(responsive)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(ResponsiveController responsive) {
    if (responsive.isTablet) {
      return _buildTabletLayout(responsive);
    } else {
      return _buildMobileLayout(responsive);
    }
  }

  Widget _buildTabletLayout(ResponsiveController responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: _buildLeftColumn(responsive),
        ),
        SizedBox(width: responsive.responsiveValue(mobile: 32.w, tablet: 48.w)),
        Expanded(
          flex: 1,
          child: _buildRightColumn(responsive),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ResponsiveController responsive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLeftColumn(responsive),
        SizedBox(height: 32.h),
        _buildRightColumn(responsive),
      ],
    );
  }

  Widget _buildLeftColumn(ResponsiveController responsive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(isLogin: isLogin),
        SizedBox(
            height: responsive.responsiveValue(mobile: 24.h, tablet: 32.h)),
        SocialAuthButtons(
          onGoogleSignIn: () => authController.signInWithGoogle(),
          onGithubSignIn: () => authController.signInWithGithub(),
          onAppleSignIn: () => authController.signInWithApple(),
        ),
      ],
    );
  }

  Widget _buildRightColumn(ResponsiveController responsive) {
    return Card(
      elevation: responsive.responsiveValue(mobile: 2, tablet: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: responsive.responsivePadding(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthForm(
              isLogin: isLogin,
              onSubmit: (email, password) {
                if (isLogin) {
                  authController.signInWithEmailAndPassword();
                } else {
                  authController.createUserWithEmailAndPassword();
                }
              },
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 24.h, tablet: 32.h)),
            AuthFooter(isLogin: isLogin),
          ],
        ),
      ),
    );
  }
}

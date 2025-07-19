import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';
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
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: performanceService.getOptimizedPadding(
                cacheKey: 'auth_wrapper_padding',
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
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: responsive.responsiveValue(
          mobile: 600.w,
          tablet: 1000.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: responsive.responsiveValue(
              mobile: 1,
              tablet: 2,
            ),
            child: _buildLeftColumn(responsive),
          ),
          SizedBox(
            width: responsive.responsiveValue(
              mobile: 32.w,
              tablet: 48.w,
            ),
          ),
          Expanded(
            flex: responsive.responsiveValue(
              mobile: 1,
              tablet: 3,
            ),
            child: _buildRightColumn(responsive),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(ResponsiveController responsive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLeftColumn(responsive),
        SizedBox(
          height: responsive.responsiveValue(
            mobile: 32.h,
            tablet: 40.h,
          ),
        ),
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
          height: responsive.responsiveValue(
            mobile: 24.h,
            tablet: 32.h,
          ),
        ),
        SocialAuthButtons(
          onGoogleSignIn: () => authController.signInWithGoogle(),
          onGithubSignIn: () => authController.signInWithGithub(),
          onAppleSignIn: () => authController.signInWithApple(),
        ),
      ],
    );
  }

  Widget _buildRightColumn(ResponsiveController responsive) {
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Card(
      elevation: responsive.responsiveValue(
        mobile: 2,
        tablet: 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(
            mobile: 16.r,
            tablet: 20.r,
          ),
        ),
      ),
      child: Padding(
        padding: performanceService.getOptimizedPadding(
          cacheKey: 'auth_form_card_padding',
          left: 24,
          right: 24,
          top: 24,
          bottom: 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: responsive.responsiveValue(
              mobile: double.infinity,
              tablet: 400.w,
            ),
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
                height: responsive.responsiveValue(
                  mobile: 24.h,
                  tablet: 32.h,
                ),
              ),
              AuthFooter(isLogin: isLogin),
            ],
          ),
        ),
      ),
    );
  }
}

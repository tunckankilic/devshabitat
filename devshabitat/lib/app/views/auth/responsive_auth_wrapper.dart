import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/responsive_controller.dart';
import 'widgets/auth_form.dart';
import 'widgets/auth_header.dart';
import 'widgets/social_auth_buttons.dart';
import 'widgets/auth_footer.dart';

class ResponsiveAuthWrapper extends StatelessWidget {
  final AuthController authController;
  final bool isLogin;
  final _responsiveController = Get.find<ResponsiveController>();

  ResponsiveAuthWrapper({
    super.key,
    required this.authController,
    this.isLogin = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: _responsiveController.responsivePadding(all: 24.0),
              child: Obx(() => _buildResponsiveLayout()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout() {
    if (_responsiveController.isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildTabletLayout() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: _responsiveController.responsiveValue(
          mobile: 600.0,
          tablet: 1000.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: _responsiveController.responsiveValue(
              mobile: 1,
              tablet: 2,
            ),
            child: _buildLeftColumn(),
          ),
          SizedBox(
              width: _responsiveController.responsiveValue(
            mobile: 32.0,
            tablet: 48.0,
          )),
          Expanded(
            flex: _responsiveController.responsiveValue(
              mobile: 1,
              tablet: 3,
            ),
            child: _buildRightColumn(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLeftColumn(),
        SizedBox(
            height: _responsiveController.responsiveValue(
          mobile: 32.0,
          tablet: 40.0,
        )),
        _buildRightColumn(),
      ],
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(
          title: isLogin ? 'Hoş Geldiniz' : 'Kayıt Ol',
          subtitle: isLogin
              ? 'Devam etmek için giriş yapın'
              : 'Yeni bir hesap oluşturun',
          logoPath: 'assets/images/logo.svg',
        ),
        SizedBox(
            height: _responsiveController.responsiveValue(
          mobile: 24.0,
          tablet: 32.0,
        )),
        SocialAuthButtons(
          isLogin: isLogin,
          onGoogleAuth: () => authController.signInWithGoogle(),
          onAppleAuth: () => authController.signInWithApple(),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Card(
      elevation: _responsiveController.responsiveValue(
        mobile: 2.0,
        tablet: 4.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 20.0,
          ),
        ),
      ),
      child: Padding(
        padding: _responsiveController.responsivePadding(all: 24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _responsiveController.responsiveValue(
              mobile: double.infinity,
              tablet: 400.0,
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
                    authController.signInWithEmailAndPassword(email, password);
                  } else {
                    authController.createUserWithEmailAndPassword();
                  }
                },
              ),
              SizedBox(
                  height: _responsiveController.responsiveValue(
                mobile: 24.0,
                tablet: 32.0,
              )),
              AuthFooter(
                isLogin: isLogin,
                onToggleAuth: () =>
                    Get.toNamed(isLogin ? '/register' : '/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/form_validation_controller.dart';
import '../../../controllers/github_validation_controller.dart';
import '../../../controllers/responsive_controller.dart';

class GlassRegisterCard extends StatelessWidget {
  final VoidCallback onRegister;
  final Function(String) onGitHubValidation;
  final _responsiveController = Get.find<ResponsiveController>();

  GlassRegisterCard({
    Key? key,
    required this.onRegister,
    required this.onGitHubValidation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final formController = Get.find<FormValidationController>();
    final githubController = Get.find<GitHubValidationController>();

    return Container(
      padding: _responsiveController.responsivePadding(all: 24.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 20.0,
          ),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: _responsiveController.responsiveValue(
            mobile: 1.5,
            tablet: 2.0,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kayıt Ol',
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 24.0,
                tablet: 28.0,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 24.0,
            tablet: 32.0,
          )),
          TextField(
            controller: authController.emailController,
            onChanged: formController.validateEmail,
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'E-posta',
              labelStyle: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                  mobile: 14.0,
                  tablet: 16.0,
                ),
              ),
              errorText: formController.emailError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 20.0,
          )),
          TextField(
            controller: authController.passwordController,
            onChanged: formController.validatePassword,
            obscureText: true,
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Şifre',
              labelStyle: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                  mobile: 14.0,
                  tablet: 16.0,
                ),
              ),
              errorText: formController.passwordError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 20.0,
          )),
          TextField(
            controller: authController.confirmPasswordController,
            onChanged: formController.validateConfirmPassword,
            obscureText: true,
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Şifre Tekrarı',
              labelStyle: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                  mobile: 14.0,
                  tablet: 16.0,
                ),
              ),
              errorText: formController.confirmPasswordError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 20.0,
          )),
          TextField(
            controller: authController.usernameController,
            onChanged: formController.validateUsername,
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Kullanıcı Adı',
              labelStyle: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                  mobile: 14.0,
                  tablet: 16.0,
                ),
              ),
              errorText: formController.usernameError.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 20.0,
          )),
          TextField(
            controller: authController.githubUsernameController,
            onChanged: onGitHubValidation,
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'GitHub Kullanıcı Adı',
              labelStyle: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                  mobile: 14.0,
                  tablet: 16.0,
                ),
              ),
              errorText: githubController.error.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 24.0,
            tablet: 32.0,
          )),
          Obx(() => ElevatedButton(
                onPressed: formController.isFormValid ? onRegister : null,
                style: ElevatedButton.styleFrom(
                  padding: _responsiveController.responsivePadding(
                    vertical: 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      _responsiveController.responsiveValue(
                        mobile: 8.0,
                        tablet: 12.0,
                      ),
                    ),
                  ),
                ),
                child: Text(
                  'Kayıt Ol',
                  style: TextStyle(
                    fontSize: _responsiveController.responsiveValue(
                      mobile: 16.0,
                      tablet: 18.0,
                    ),
                  ),
                ),
              )),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 20.0,
          )),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Zaten hesabın var mı? Giriş yap',
              style: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                  mobile: 14.0,
                  tablet: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

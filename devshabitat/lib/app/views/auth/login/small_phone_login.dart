import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';
import '../widgets/social_login_button.dart';

class SmallPhoneLogin extends GetView<AuthController> {
  final _responsiveController = Get.find<ResponsiveController>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  SmallPhoneLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: _responsiveController.responsivePadding(all: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: _responsiveController.responsiveValue(
                  mobile: 120.0,
                  tablet: 160.0,
                ),
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: _responsiveController.responsiveValue(
                  mobile: 32.0,
                  tablet: 48.0,
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppStrings.email,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen email adresinizi girin';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Geçerli bir email adresi girin';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: _responsiveController.responsiveValue(
                  mobile: 16.0,
                  tablet: 24.0,
                ),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppStrings.password,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: Obx(() => IconButton(
                        icon: Icon(
                          controller.isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => controller.togglePasswordVisibility(),
                      )),
                ),
                obscureText: !controller.isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi girin';
                  }
                  if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: _responsiveController.responsiveValue(
                  mobile: 8.0,
                  tablet: 12.0,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                  child: Text(AppStrings.forgotPassword),
                ),
              ),
              SizedBox(
                height: _responsiveController.responsiveValue(
                  mobile: 16.0,
                  tablet: 24.0,
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: _responsiveController.responsiveValue(
                  mobile: 48.0,
                  tablet: 56.0,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.signInWithEmailAndPassword(
                        _emailController.text,
                        _passwordController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    AppStrings.login,
                    style: TextStyle(
                      fontSize: _responsiveController.responsiveValue(
                        mobile: 16.0,
                        tablet: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                ),
              ),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('veya'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(
                height: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                ),
              ),
              SocialLoginButton(
                text: AppStrings.continueWithGoogle,
                imagePath: 'assets/icons/baseline_google_black_48dp.png',
                onPressed: () => controller.signInWithGoogle(),
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                isOutlined: true,
              ),
              SizedBox(
                height: _responsiveController.responsiveValue(
                  mobile: 12.0,
                  tablet: 16.0,
                ),
              ),
              SocialLoginButton(
                text: AppStrings.continueWithApple,
                imagePath: 'assets/icons/apple-logo.png',
                onPressed: () => controller.signInWithApple(),
                backgroundColor: Colors.black,
                textColor: Colors.white,
                isAppleButton: true,
              ),
              SizedBox(
                height: _responsiveController.responsiveValue(
                  mobile: 12.0,
                  tablet: 16.0,
                ),
              ),
              SocialLoginButton(
                text: AppStrings.continueWithGithub,
                imagePath: 'assets/icons/github-mark.png',
                onPressed: () => controller.signInWithGithub(),
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              ),
              SizedBox(
                height: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hesabınız yok mu?'),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    child: Text('Kayıt Ol'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
  }
}

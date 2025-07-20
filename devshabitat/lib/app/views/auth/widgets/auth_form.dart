import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../services/responsive_performance_service.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final Function(String email, String password) onSubmit;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onSubmit,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'auth_form_email',
                mobileSize: 16,
                tabletSize: 18,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'E-posta',
              hintText: 'ornek@email.com',
              prefixIcon: Icon(
                Icons.email_outlined,
                size: responsive.responsiveValue(mobile: 20, tablet: 24),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'E-posta gerekli';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Geçerli bir e-posta girin';
              }
              return null;
            },
          ),

          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'auth_form_password',
                mobileSize: 16,
                tabletSize: 18,
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Şifre',
              prefixIcon: Icon(
                Icons.lock_outlined,
                size: responsive.responsiveValue(mobile: 20, tablet: 24),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  size: responsive.responsiveValue(mobile: 20, tablet: 24),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Şifre gerekli';
              }
              if (value.length < 6) {
                return 'Şifre en az 6 karakter olmalı';
              }
              return null;
            },
          ),

          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: responsive.responsiveValue(mobile: 48, tablet: 56),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit(
                    _emailController.text.trim(),
                    _passwordController.text,
                  );
                }
              },
              child: Text(
                widget.isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                style: TextStyle(
                  fontSize: performanceService.getOptimizedTextSize(
                    cacheKey: 'auth_form_button',
                    mobileSize: 16,
                    tabletSize: 18,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

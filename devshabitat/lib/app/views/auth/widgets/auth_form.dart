import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'E-posta',
              prefixIcon: Icon(
                Icons.email,
                size: responsive.responsiveValue(
                  mobile: 20.w,
                  tablet: 24.w,
                ),
              ),
              labelStyle: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'auth_form_label_email',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: responsive.responsiveValue(
                  mobile: 16.w,
                  tablet: 20.w,
                ),
                vertical: responsive.responsiveValue(
                  mobile: 12.h,
                  tablet: 16.h,
                ),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'auth_form_text_email',
                mobileSize: 16.sp,
                tabletSize: 18.sp,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'E-posta adresi gerekli';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Geçerli bir e-posta adresi girin';
              }
              return null;
            },
          ),
          SizedBox(
            height: responsive.responsiveValue(
              mobile: 16.h,
              tablet: 20.h,
            ),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Şifre',
              prefixIcon: Icon(
                Icons.lock,
                size: responsive.responsiveValue(
                  mobile: 20.w,
                  tablet: 24.w,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  size: responsive.responsiveValue(
                    mobile: 20.w,
                    tablet: 24.w,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              labelStyle: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'auth_form_label_password',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: responsive.responsiveValue(
                  mobile: 16.w,
                  tablet: 20.w,
                ),
                vertical: responsive.responsiveValue(
                  mobile: 12.h,
                  tablet: 16.h,
                ),
              ),
            ),
            obscureText: !_isPasswordVisible,
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'auth_form_text_password',
                mobileSize: 16.sp,
                tabletSize: 18.sp,
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
          SizedBox(
            height: responsive.responsiveValue(
              mobile: 24.h,
              tablet: 32.h,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                  _emailController.text,
                  _passwordController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: responsive.responsiveValue(
                  mobile: 12.h,
                  tablet: 16.h,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  responsive.responsiveValue(
                    mobile: 8.r,
                    tablet: 12.r,
                  ),
                ),
              ),
            ),
            child: Text(
              widget.isLogin ? 'Giriş Yap' : 'Kayıt Ol',
              style: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'auth_form_button_text',
                  mobileSize: 16.sp,
                  tabletSize: 18.sp,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

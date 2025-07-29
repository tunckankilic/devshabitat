import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_strings.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../services/responsive_performance_service.dart';
import '../../../controllers/enhanced_form_validation_controller.dart';
import '../../../widgets/enhanced_form_field.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final Function(String email, String password) onSubmit;
  final bool isLoading;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onSubmit,
    this.isLoading = false,
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
    final validationController = Get.find<EnhancedFormValidationController>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field with EnhancedFormField
          EnhancedFormField(
            fieldType: FieldType.email,
            controller: _emailController,
            label: AppStrings.email,
            hint: AppStrings.emailHint,
            prefixIcon: Icons.email_outlined,
            iconSize: responsive.responsiveValue(mobile: 20, tablet: 24),
            onChanged: (value) {
              validationController.validateEmail(value);
            },
          ),

          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),

          // Password Field with EnhancedFormField
          EnhancedFormField(
            fieldType: FieldType.password,
            controller: _passwordController,
            label: AppStrings.password,
            prefixIcon: Icons.lock_outlined,
            iconSize: responsive.responsiveValue(mobile: 20, tablet: 24),
            obscureText: !_isPasswordVisible,
            suffixIcon:
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            onTap: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            onChanged: (value) {
              validationController.validatePassword(value);
            },
          ),

          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // Submit Button
          Obx(() => SizedBox(
                width: double.infinity,
                height: responsive.responsiveValue(mobile: 48, tablet: 56),
                child: ElevatedButton(
                  onPressed:
                      (validationController.isFormValid && !widget.isLoading)
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                widget.onSubmit(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                );
                              }
                            }
                          : null,
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.isLogin
                              ? AppStrings.login
                              : AppStrings.register,
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
              )),
        ],
      ),
    );
  }
}

import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/registration_controller.dart';
import '../../../../controllers/responsive_controller.dart';

class BasicInfoStep extends GetView<RegistrationController> {
  final _responsiveController = Get.find<ResponsiveController>();

  BasicInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.basicInfoFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: AppStrings.email,
              hintText: AppStrings.emailHint,
              prefixIcon: Icon(
                Icons.email,
                size: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                ),
              ),
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
            ),
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.emailRequired;
              }
              if (!GetUtils.isEmail(value)) {
                return AppStrings.emailInvalid;
              }
              return null;
            },
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 24.0,
          )),
          TextFormField(
            controller: controller.displayNameController,
            decoration: InputDecoration(
              labelText: AppStrings.displayName,
              hintText: AppStrings.displayNameHint,
              prefixIcon: Icon(
                Icons.person,
                size: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                ),
              ),
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
            ),
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.displayNameRequired;
              }
              if (value.length < 3) {
                return AppStrings.displayNameInvalid;
              }
              return null;
            },
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 24.0,
          )),
          TextFormField(
            controller: controller.passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppStrings.password,
              hintText: AppStrings.passwordHint,
              prefixIcon: Icon(
                Icons.lock,
                size: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                ),
              ),
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
            ),
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.passwordRequired;
              }
              if (value.length < 8) {
                return AppStrings.passwordInvalid;
              }
              if (!value.contains(RegExp(r'[A-Z]'))) {
                return AppStrings.passwordInvalid;
              }
              if (!value.contains(RegExp(r'[a-z]'))) {
                return AppStrings.passwordInvalid;
              }
              if (!value.contains(RegExp(r'[0-9]'))) {
                return AppStrings.passwordInvalid;
              }
              return null;
            },
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 24.0,
          )),
          TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppStrings.confirmPassword,
              hintText: AppStrings.confirmPasswordHint,
              prefixIcon: Icon(
                Icons.lock_outline,
                size: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                ),
              ),
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
            ),
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.confirmPasswordRequired;
              }
              if (value != controller.passwordController.text) {
                return AppStrings.confirmPasswordInvalid;
              }
              return null;
            },
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 24.0,
            tablet: 32.0,
          )),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: _responsiveController.responsiveValue(
                  mobile: 16.0,
                  tablet: 20.0,
                ),
                color: Colors.grey,
              ),
              SizedBox(
                  width: _responsiveController.responsiveValue(
                mobile: 8.0,
                tablet: 12.0,
              )),
              Expanded(
                child: Text(
                  AppStrings.passwordDescription,
                  style: TextStyle(
                    fontSize: _responsiveController.responsiveValue(
                      mobile: 12.0,
                      tablet: 14.0,
                    ),
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ValidationMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  final double iconSize;
  final double fontSize;

  const ValidationMessage({
    super.key,
    required this.icon,
    required this.message,
    required this.color,
    required this.iconSize,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveController = Get.find<ResponsiveController>();
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsiveController.responsiveValue(mobile: 8, tablet: 12),
      ),
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: color),
          SizedBox(
            width: responsiveController.responsiveValue(mobile: 8, tablet: 12),
          ),
          Text(
            message,
            style: TextStyle(color: color, fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}

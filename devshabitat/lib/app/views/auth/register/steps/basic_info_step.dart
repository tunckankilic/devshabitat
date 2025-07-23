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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field
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
              suffixIcon: Obx(() => controller.isEmailValid
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : SizedBox.shrink()),
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
                  mobile: 16.0, tablet: 24.0)),

          // Display Name field
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
              suffixIcon: Obx(() => controller.isDisplayNameValid
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : SizedBox.shrink()),
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
                  mobile: 16.0, tablet: 24.0)),

          // Password field
          Obx(() => TextFormField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppStrings.password,
                  hintText:
                      "En az 8 karakter, büyük/küçük harf, sayı ve özel karakter",
                  prefixIcon: Icon(
                    Icons.lock,
                    size: _responsiveController.responsiveValue(
                      mobile: 24.0,
                      tablet: 32.0,
                    ),
                  ),
                  suffixIcon: controller.allPasswordRequirementsMet
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : SizedBox.shrink(),
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
                    borderSide: BorderSide(
                      color: !controller.passwordIsEmpty
                          ? (controller.allPasswordRequirementsMet
                              ? Colors.green
                              : Colors.orange)
                          : Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      _responsiveController.responsiveValue(
                        mobile: 8.0,
                        tablet: 12.0,
                      ),
                    ),
                    borderSide: BorderSide(
                      color: !controller.passwordIsEmpty
                          ? (controller.allPasswordRequirementsMet
                              ? Colors.green
                              : Colors.orange)
                          : Colors.grey,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: _responsiveController.responsiveValue(
                    mobile: 16.0,
                    tablet: 18.0,
                  ),
                ),
              )),

          SizedBox(
              height: _responsiveController.responsiveValue(
                  mobile: 12.0, tablet: 16.0)),

          // Password Requirements Checklist
          Obx(() => _buildPasswordChecklist()),

          SizedBox(
              height: _responsiveController.responsiveValue(
                  mobile: 16.0, tablet: 24.0)),

          // Confirm Password field
          Obx(() => TextFormField(
                controller: controller.confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppStrings.confirmPassword,
                  hintText: "Şifrenizi tekrar girin",
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    size: _responsiveController.responsiveValue(
                      mobile: 24.0,
                      tablet: 32.0,
                    ),
                  ),
                  suffixIcon: controller.passwordsMatch &&
                          !controller.confirmPasswordIsEmpty
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : !controller.confirmPasswordIsEmpty &&
                              !controller.passwordsMatch
                          ? Icon(Icons.error, color: Colors.red)
                          : SizedBox.shrink(),
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      _responsiveController.responsiveValue(
                        mobile: 8.0,
                        tablet: 12.0,
                      ),
                    ),
                    borderSide: BorderSide(
                      color: !controller.confirmPasswordIsEmpty
                          ? (controller.passwordsMatch
                              ? Colors.green
                              : Colors.red)
                          : Colors.grey,
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
              )),

          SizedBox(
              height: _responsiveController.responsiveValue(
                  mobile: 16.0, tablet: 24.0)),

          // Password Match Status
          Obx(() => !controller.confirmPasswordIsEmpty
              ? _buildPasswordMatchStatus()
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildPasswordChecklist() {
    if (controller.passwordIsEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: _responsiveController.responsivePadding(all: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(
          _responsiveController.responsiveValue(mobile: 8.0, tablet: 12.0),
        ),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Şifre Gereksinimleri:',
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                  mobile: 14.0, tablet: 16.0),
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
                  mobile: 8.0, tablet: 12.0)),
          _buildRequirementItem(
            'En az 8 karakter',
            controller.hasMinLength,
          ),
          _buildRequirementItem(
            'En az bir büyük harf (A-Z)',
            controller.hasUppercase,
          ),
          _buildRequirementItem(
            'En az bir küçük harf (a-z)',
            controller.hasLowercase,
          ),
          _buildRequirementItem(
            'En az bir sayı (0-9)',
            controller.hasNumber,
          ),
          _buildRequirementItem(
            'En az bir özel karakter (!@#\$%^&*)',
            controller.hasSpecialChar,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical:
            _responsiveController.responsiveValue(mobile: 2.0, tablet: 4.0),
      ),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: _responsiveController.responsiveValue(
                mobile: 16.0, tablet: 20.0),
            color: isMet ? Colors.green : Colors.grey,
          ),
          SizedBox(
              width: _responsiveController.responsiveValue(
                  mobile: 8.0, tablet: 12.0)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                    mobile: 12.0, tablet: 14.0),
                color: isMet ? Colors.green[700] : Colors.grey[600],
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordMatchStatus() {
    return Container(
      padding: _responsiveController.responsivePadding(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      decoration: BoxDecoration(
        color: controller.passwordsMatch ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(
          _responsiveController.responsiveValue(mobile: 8.0, tablet: 12.0),
        ),
        border: Border.all(
          color:
              controller.passwordsMatch ? Colors.green[300]! : Colors.red[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            controller.passwordsMatch ? Icons.check_circle : Icons.error,
            size: _responsiveController.responsiveValue(
                mobile: 16.0, tablet: 20.0),
            color:
                controller.passwordsMatch ? Colors.green[700] : Colors.red[700],
          ),
          SizedBox(
              width: _responsiveController.responsiveValue(
                  mobile: 8.0, tablet: 12.0)),
          Expanded(
            child: Text(
              controller.passwordsMatch
                  ? 'Şifreler eşleşiyor'
                  : 'Şifreler eşleşmiyor',
              style: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                    mobile: 12.0, tablet: 14.0),
                color: controller.passwordsMatch
                    ? Colors.green[700]
                    : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
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

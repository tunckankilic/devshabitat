import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../controllers/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  final _responsiveController = Get.find<ResponsiveController>();

  ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.forgotPassword,
          style: TextStyle(
            fontSize: _responsiveController.responsiveValue(
              mobile: 18.0,
              tablet: 22.0,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: _responsiveController.responsivePadding(all: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    height: _responsiveController.responsiveValue(
                  mobile: 32.0,
                  tablet: 48.0,
                )),
                Text(
                  AppStrings.forgotPasswordDescription,
                  style: TextStyle(
                    fontSize: _responsiveController.responsiveValue(
                      mobile: 24.0,
                      tablet: 32.0,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                    height: _responsiveController.responsiveValue(
                  mobile: 8.0,
                  tablet: 12.0,
                )),
                Text(
                  'Enter your email address and we\'ll send you a password reset link.',
                  style: TextStyle(
                    fontSize: _responsiveController.responsiveValue(
                      mobile: 16.0,
                      tablet: 18.0,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(
                    height: _responsiveController.responsiveValue(
                  mobile: 32.0,
                  tablet: 48.0,
                )),
                Form(
                  child: TextFormField(
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
                ),
                SizedBox(
                    height: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                )),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () => controller.sendPasswordResetEmail(),
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
                      child: controller.isLoading
                          ? SizedBox(
                              width: _responsiveController.responsiveValue(
                                mobile: 24.0,
                                tablet: 32.0,
                              ),
                              height: _responsiveController.responsiveValue(
                                mobile: 24.0,
                                tablet: 32.0,
                              ),
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              AppStrings.sendPasswordResetLink,
                              style: TextStyle(
                                fontSize: _responsiveController.responsiveValue(
                                  mobile: 16.0,
                                  tablet: 18.0,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../widgets/social_login_button.dart';

class SmallPhoneLogin extends GetView<AuthController> {
  final _responsiveController = Get.find<ResponsiveController>();

  SmallPhoneLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _responsiveController.responsivePadding(all: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 32.0,
            tablet: 48.0,
          )),
          Image.asset(
            'assets/images/logo.svg',
            height: _responsiveController.responsiveValue(
              mobile: 80.0,
              tablet: 120.0,
            ),
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 32.0,
            tablet: 48.0,
          )),
          Text(
            AppStrings.welcome,
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 20.0,
                tablet: 24.0,
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
            AppStrings.loginDescription,
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 14.0,
                tablet: 16.0,
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
            child: Column(
              children: [
                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(
                      Icons.email,
                      size: _responsiveController.responsiveValue(
                        mobile: 20.0,
                        tablet: 24.0,
                      ),
                    ),
                    contentPadding: _responsiveController.responsivePadding(
                      horizontal: 12.0,
                      vertical: 12.0,
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
                      mobile: 14.0,
                      tablet: 16.0,
                    ),
                  ),
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
                    labelText: 'Şifre',
                    prefixIcon: Icon(
                      Icons.lock,
                      size: _responsiveController.responsiveValue(
                        mobile: 20.0,
                        tablet: 24.0,
                      ),
                    ),
                    contentPadding: _responsiveController.responsivePadding(
                      horizontal: 12.0,
                      vertical: 12.0,
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
                      mobile: 14.0,
                      tablet: 16.0,
                    ),
                  ),
                ),
                SizedBox(
                    height: _responsiveController.responsiveValue(
                  mobile: 8.0,
                  tablet: 12.0,
                )),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed('/forgot-password'),
                    child: Text(
                      AppStrings.forgotPassword,
                      style: TextStyle(
                        fontSize: _responsiveController.responsiveValue(
                          mobile: 12.0,
                          tablet: 14.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    height: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                )),
                Obx(() {
                  return ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () => controller.signInWithEmailAndPassword(),
                    style: ElevatedButton.styleFrom(
                      padding: _responsiveController.responsivePadding(
                        vertical: 12.0,
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
                              mobile: 20.0,
                              tablet: 24.0,
                            ),
                            height: _responsiveController.responsiveValue(
                              mobile: 20.0,
                              tablet: 24.0,
                            ),
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppStrings.login,
                            style: TextStyle(
                              fontSize: _responsiveController.responsiveValue(
                                mobile: 14.0,
                                tablet: 16.0,
                              ),
                            ),
                          ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 24.0,
            tablet: 32.0,
          )),
          Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: _responsiveController.responsivePadding(
                  horizontal: 12.0,
                ),
                child: Text(
                  AppStrings.or,
                  style: TextStyle(
                    fontSize: _responsiveController.responsiveValue(
                      mobile: 12.0,
                      tablet: 14.0,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 24.0,
            tablet: 32.0,
          )),
          SocialLoginButton(
            text: AppStrings.continueWithGoogle,
            imagePath: 'assets/icons/google.png',
            onPressed: () => controller.signInWithGoogle(),
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            isOutlined: true,
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 12.0,
            tablet: 16.0,
          )),
          SocialLoginButton(
            text: AppStrings.continueWithApple,
            imagePath: 'assets/icons/apple.png',
            onPressed: () => controller.signInWithApple(),
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 24.0,
            tablet: 32.0,
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.noAccount,
                style: TextStyle(
                  fontSize: _responsiveController.responsiveValue(
                    mobile: 12.0,
                    tablet: 14.0,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/register'),
                child: Text(
                  AppStrings.register,
                  style: TextStyle(
                    fontSize: _responsiveController.responsiveValue(
                      mobile: 12.0,
                      tablet: 14.0,
                    ),
                    fontWeight: FontWeight.bold,
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

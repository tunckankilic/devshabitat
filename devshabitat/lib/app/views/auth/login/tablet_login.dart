import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../widgets/social_login_button.dart';

class TabletLogin extends GetView<AuthController> {
  final _responsiveController = Get.find<ResponsiveController>();

  TabletLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sol taraf - Görsel ve tanıtım
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.svg',
                        height: _responsiveController.responsiveValue(
                          mobile: 120.0,
                          tablet: 160.0,
                        ),
                      ),
                      SizedBox(
                          height: _responsiveController.responsiveValue(
                        mobile: 40.0,
                        tablet: 56.0,
                      )),
                      Text(
                        AppStrings.welcome,
                        style: TextStyle(
                          fontSize: _responsiveController.responsiveValue(
                            mobile: 32.0,
                            tablet: 40.0,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: _responsiveController.responsiveValue(
                        mobile: 16.0,
                        tablet: 24.0,
                      )),
                      Padding(
                        padding: _responsiveController.responsivePadding(
                          horizontal: 48.0,
                        ),
                        child: Text(
                          AppStrings.welcomeDescription,
                          style: TextStyle(
                            fontSize: _responsiveController.responsiveValue(
                              mobile: 18.0,
                              tablet: 22.0,
                            ),
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Sağ taraf - Giriş formu
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: _responsiveController.responsivePadding(all: 48.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: _responsiveController.responsiveValue(
                      mobile: 480.0,
                      tablet: 600.0,
                    ),
                  ),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.login,
                          style: TextStyle(
                            fontSize: _responsiveController.responsiveValue(
                              mobile: 32.0,
                              tablet: 40.0,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                            height: _responsiveController.responsiveValue(
                          mobile: 40.0,
                          tablet: 56.0,
                        )),
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
                            contentPadding:
                                _responsiveController.responsivePadding(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                _responsiveController.responsiveValue(
                                  mobile: 12.0,
                                  tablet: 16.0,
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
                          mobile: 24.0,
                          tablet: 32.0,
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
                            contentPadding:
                                _responsiveController.responsivePadding(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                _responsiveController.responsiveValue(
                                  mobile: 12.0,
                                  tablet: 16.0,
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
                            if (value.length < 6) {
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Get.toNamed('/forgot-password'),
                            child: Text(
                              AppStrings.forgotPassword,
                              style: TextStyle(
                                fontSize: _responsiveController.responsiveValue(
                                  mobile: 14.0,
                                  tablet: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: _responsiveController.responsiveValue(
                          mobile: 32.0,
                          tablet: 40.0,
                        )),
                        Obx(() {
                          return ElevatedButton(
                            onPressed: controller.isLoading
                                ? null
                                : () => controller.signInWithEmailAndPassword(
                                      controller.emailController.text,
                                      controller.passwordController.text,
                                    ),
                            style: ElevatedButton.styleFrom(
                              padding: _responsiveController.responsivePadding(
                                vertical: 20.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  _responsiveController.responsiveValue(
                                    mobile: 12.0,
                                    tablet: 16.0,
                                  ),
                                ),
                              ),
                            ),
                            child: controller.isLoading
                                ? SizedBox(
                                    width:
                                        _responsiveController.responsiveValue(
                                      mobile: 24.0,
                                      tablet: 32.0,
                                    ),
                                    height:
                                        _responsiveController.responsiveValue(
                                      mobile: 24.0,
                                      tablet: 32.0,
                                    ),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    AppStrings.login,
                                    style: TextStyle(
                                      fontSize:
                                          _responsiveController.responsiveValue(
                                        mobile: 16.0,
                                        tablet: 18.0,
                                      ),
                                    ),
                                  ),
                          );
                        }),
                        SizedBox(
                            height: _responsiveController.responsiveValue(
                          mobile: 32.0,
                          tablet: 40.0,
                        )),
                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: _responsiveController.responsivePadding(
                                horizontal: 24.0,
                              ),
                              child: Text(
                                AppStrings.or,
                                style: TextStyle(
                                  fontSize:
                                      _responsiveController.responsiveValue(
                                    mobile: 16.0,
                                    tablet: 18.0,
                                  ),
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(
                            height: _responsiveController.responsiveValue(
                          mobile: 32.0,
                          tablet: 40.0,
                        )),
                        Row(
                          children: [
                            Expanded(
                              child: SocialLoginButton(
                                text: AppStrings.continueWithGoogle,
                                imagePath: 'assets/icons/google.png',
                                onPressed: () => controller.signInWithGoogle(),
                                backgroundColor: Colors.white,
                                textColor: Colors.black87,
                                isOutlined: true,
                              ),
                            ),
                            SizedBox(
                                width: _responsiveController.responsiveValue(
                              mobile: 16.0,
                              tablet: 24.0,
                            )),
                            Expanded(
                              child: SocialLoginButton(
                                text: AppStrings.continueWithApple,
                                imagePath: 'assets/icons/apple.png',
                                onPressed: () => controller.signInWithApple(),
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                isAppleButton: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: _responsiveController.responsiveValue(
                          mobile: 32.0,
                          tablet: 40.0,
                        )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.noAccount,
                              style: TextStyle(
                                fontSize: _responsiveController.responsiveValue(
                                  mobile: 16.0,
                                  tablet: 18.0,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.toNamed('/register'),
                              child: Text(
                                AppStrings.register,
                                style: TextStyle(
                                  fontSize:
                                      _responsiveController.responsiveValue(
                                    mobile: 16.0,
                                    tablet: 18.0,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

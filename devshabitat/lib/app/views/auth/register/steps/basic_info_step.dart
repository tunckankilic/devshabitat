import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/registration_controller.dart';
import '../../../../controllers/responsive_controller.dart';

class BasicInfoStep extends GetView<RegistrationController> {
  final _responsiveController = Get.find<ResponsiveController>();

  BasicInfoStep({Key? key}) : super(key: key);

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
              labelText: 'E-posta',
              hintText: 'ornek@email.com',
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
                return 'E-posta adresi gerekli';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Geçerli bir e-posta adresi girin';
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
              labelText: 'Ad Soyad',
              hintText: 'Adınız ve Soyadınız',
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
                return 'Ad soyad gerekli';
              }
              if (value.length < 3) {
                return 'Ad soyad en az 3 karakter olmalı';
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
              labelText: 'Şifre',
              hintText: 'En az 8 karakter',
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
                return 'Şifre gerekli';
              }
              if (value.length < 8) {
                return 'Şifre en az 8 karakter olmalı';
              }
              if (!value.contains(RegExp(r'[A-Z]'))) {
                return 'Şifre en az bir büyük harf içermeli';
              }
              if (!value.contains(RegExp(r'[a-z]'))) {
                return 'Şifre en az bir küçük harf içermeli';
              }
              if (!value.contains(RegExp(r'[0-9]'))) {
                return 'Şifre en az bir rakam içermeli';
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
              labelText: 'Şifre Tekrar',
              hintText: 'Şifrenizi tekrar girin',
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
                return 'Şifre tekrarı gerekli';
              }
              if (value != controller.passwordController.text) {
                return 'Şifreler eşleşmiyor';
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
                  'Şifreniz en az 8 karakter uzunluğunda olmalı ve büyük/küçük harf, rakam ve özel karakter içermelidir.',
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
    Key? key,
    required this.icon,
    required this.message,
    required this.color,
    required this.iconSize,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _responsiveController = Get.find<ResponsiveController>();
    return Padding(
      padding: EdgeInsets.only(
        bottom: _responsiveController.responsiveValue(mobile: 8, tablet: 12),
      ),
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: color),
          SizedBox(
            width: _responsiveController.responsiveValue(mobile: 8, tablet: 12),
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

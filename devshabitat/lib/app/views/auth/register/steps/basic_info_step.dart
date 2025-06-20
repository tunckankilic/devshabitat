import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../controllers/registration_controller.dart';

class BasicInfoStep extends GetView<RegistrationController> {
  const BasicInfoStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.basicInfoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-posta',
              hintText: 'ornek@email.com',
              prefixIcon: Icon(Icons.email, size: 24.sp),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            style: TextStyle(fontSize: 16.sp),
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
          SizedBox(height: 16.h),

          TextFormField(
            controller: controller.displayNameController,
            decoration: InputDecoration(
              labelText: 'Ad Soyad',
              hintText: 'Adınız ve Soyadınız',
              prefixIcon: Icon(Icons.person, size: 24.sp),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            style: TextStyle(fontSize: 16.sp),
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
          SizedBox(height: 16.h),

          TextFormField(
            controller: controller.passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Şifre',
              hintText: 'En az 8 karakter',
              prefixIcon: Icon(Icons.lock, size: 24.sp),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            style: TextStyle(fontSize: 16.sp),
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
          SizedBox(height: 16.h),

          TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Şifre Tekrar',
              hintText: 'Şifrenizi tekrar girin',
              prefixIcon: Icon(Icons.lock_outline, size: 24.sp),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            style: TextStyle(fontSize: 16.sp),
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
          SizedBox(height: 24.h),

          // Validation Messages
          Obx(() {
            final List<Widget> messages = [];

            if (!controller.isEmailValid) {
              messages.add(ValidationMessage(
                icon: Icons.error,
                message: 'Geçerli bir e-posta adresi girin',
                color: Colors.red,
                iconSize: 16.sp,
                fontSize: 12.sp,
              ));
            }

            if (!controller.isDisplayNameValid) {
              messages.add(ValidationMessage(
                icon: Icons.error,
                message: 'Ad soyad en az 3 karakter olmalı',
                color: Colors.red,
                iconSize: 16.sp,
                fontSize: 12.sp,
              ));
            }

            if (!controller.isPasswordValid) {
              messages.add(ValidationMessage(
                icon: Icons.error,
                message: 'Şifre kriterleri karşılanmıyor',
                color: Colors.red,
                iconSize: 16.sp,
                fontSize: 12.sp,
              ));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: messages,
            );
          }),
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
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: color),
          SizedBox(width: 8.w),
          Text(
            message,
            style: TextStyle(color: color, fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}

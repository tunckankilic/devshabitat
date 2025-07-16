import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io' show Platform;
import '../../../controllers/auth_controller.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // iOS'ta Apple Sign In'i göster, Android'de Google'ı göster
    if ((Platform.isIOS && text.contains('Google')) ||
        (Platform.isAndroid && text.contains('Apple'))) {
      return const SizedBox.shrink();
    }

    // iOS'ta Apple Sign In'i en üstte göster
    if (Platform.isIOS && text.contains('Apple')) {
      return _buildPrimaryButton();
    }

    return _buildSecondaryButton();
  }

  Widget _buildPrimaryButton() {
    return Obx(() {
      final isLoading = Get.find<AuthController>().isLoading;

      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 24.w,
              height: 24.w,
            ),
            SizedBox(width: 12.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(width: 12),
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSecondaryButton() {
    return Obx(() {
      final isLoading = Get.find<AuthController>().isLoading;

      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          side: BorderSide(
            color: backgroundColor == Colors.white
                ? Colors.grey[300]!
                : backgroundColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 24.w,
              height: 24.w,
            ),
            SizedBox(width: 12.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(width: 12),
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

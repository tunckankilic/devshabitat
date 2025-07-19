import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io' show Platform;
import '../../../controllers/auth_controller.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../services/responsive_performance_service.dart';

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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Obx(() {
      final isLoading = Get.find<AuthController>().isLoading;

      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(
            vertical: responsive.responsiveValue(
              mobile: 16.h,
              tablet: 20.h,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              responsive.responsiveValue(
                mobile: 12.r,
                tablet: 16.r,
              ),
            ),
          ),
          elevation: responsive.responsiveValue(
            mobile: 2,
            tablet: 3,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: responsive.responsiveValue(
                mobile: 24.w,
                tablet: 28.w,
              ),
              height: responsive.responsiveValue(
                mobile: 24.w,
                tablet: 28.w,
              ),
            ),
            SizedBox(
              width: responsive.responsiveValue(
                mobile: 12.w,
                tablet: 16.w,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'social_button_text_$text',
                  mobileSize: 16.sp,
                  tabletSize: 18.sp,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isLoading) ...[
              SizedBox(
                width: responsive.responsiveValue(
                  mobile: 12.w,
                  tablet: 16.w,
                ),
              ),
              SizedBox(
                height: responsive.responsiveValue(
                  mobile: 20.h,
                  tablet: 24.h,
                ),
                width: responsive.responsiveValue(
                  mobile: 20.w,
                  tablet: 24.w,
                ),
                child: CircularProgressIndicator(
                  strokeWidth: responsive.responsiveValue(
                    mobile: 2,
                    tablet: 3,
                  ),
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Obx(() {
      final isLoading = Get.find<AuthController>().isLoading;

      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
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
          side: BorderSide(
            color: backgroundColor == Colors.white
                ? Colors.grey[300]!
                : backgroundColor,
            width: responsive.responsiveValue(
              mobile: 1,
              tablet: 1.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: responsive.responsiveValue(
                mobile: 24.w,
                tablet: 28.w,
              ),
              height: responsive.responsiveValue(
                mobile: 24.w,
                tablet: 28.w,
              ),
            ),
            SizedBox(
              width: responsive.responsiveValue(
                mobile: 12.w,
                tablet: 16.w,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'social_button_text_$text',
                  mobileSize: 16.sp,
                  tabletSize: 18.sp,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isLoading) ...[
              SizedBox(
                width: responsive.responsiveValue(
                  mobile: 12.w,
                  tablet: 16.w,
                ),
              ),
              SizedBox(
                height: responsive.responsiveValue(
                  mobile: 20.h,
                  tablet: 24.h,
                ),
                width: responsive.responsiveValue(
                  mobile: 20.w,
                  tablet: 24.w,
                ),
                child: CircularProgressIndicator(
                  strokeWidth: responsive.responsiveValue(
                    mobile: 2,
                    tablet: 3,
                  ),
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

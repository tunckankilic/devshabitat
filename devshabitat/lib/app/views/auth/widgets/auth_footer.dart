import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../services/responsive_performance_service.dart';

class AuthFooter extends StatelessWidget {
  final bool isLogin;

  const AuthFooter({
    super.key,
    required this.isLogin,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? 'Hesabınız yok mu?' : 'Zaten hesabınız var mı?',
          style: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'auth_footer_text',
              mobileSize: 14.sp,
              tabletSize: 16.sp,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Get.toNamed(isLogin ? '/register' : '/login');
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.responsiveValue(
                mobile: 8.w,
                tablet: 12.w,
              ),
              vertical: responsive.responsiveValue(
                mobile: 4.h,
                tablet: 8.h,
              ),
            ),
          ),
          child: Text(
            isLogin ? 'Kayıt Ol' : 'Giriş Yap',
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'auth_footer_button',
                mobileSize: 14.sp,
                tabletSize: 16.sp,
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../services/responsive_performance_service.dart';

class AuthHeader extends StatelessWidget {
  final bool isLogin;

  const AuthHeader({
    super.key,
    required this.isLogin,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLogin ? 'Hoş Geldiniz!' : 'Hesap Oluşturun',
          style: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'auth_header_title',
              mobileSize: 24.sp,
              tabletSize: 28.sp,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: responsive.responsiveValue(
            mobile: 8.h,
            tablet: 12.h,
          ),
        ),
        Text(
          isLogin ? 'Hesabınıza giriş yapın' : 'Yeni bir hesap oluşturun',
          style: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'auth_header_subtitle',
              mobileSize: 16.sp,
              tabletSize: 18.sp,
            ),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

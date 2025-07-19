import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';

class ResponsiveThemeHelper {
  static ResponsiveController get _responsive =>
      Get.find<ResponsiveController>();

  // Font sizes based on breakpoints
  static double get displayLarge {
    return _responsive.responsiveValue(
      mobile: 32.sp,
      tablet: 40.sp,
    );
  }

  static double get displayMedium {
    return _responsive.responsiveValue(
      mobile: 28.sp,
      tablet: 36.sp,
    );
  }

  static double get displaySmall {
    return _responsive.responsiveValue(
      mobile: 24.sp,
      tablet: 32.sp,
    );
  }

  static double get headlineMedium {
    return _responsive.responsiveValue(
      mobile: 20.sp,
      tablet: 28.sp,
    );
  }

  static double get headlineSmall {
    return _responsive.responsiveValue(
      mobile: 18.sp,
      tablet: 24.sp,
    );
  }

  static double get titleLarge {
    return _responsive.responsiveValue(
      mobile: 16.sp,
      tablet: 20.sp,
    );
  }

  static double get bodyLarge {
    return _responsive.responsiveValue(
      mobile: 16.sp,
      tablet: 18.sp,
    );
  }

  static double get bodyMedium {
    return _responsive.responsiveValue(
      mobile: 14.sp,
      tablet: 16.sp,
    );
  }

  static double get bodySmall {
    return _responsive.responsiveValue(
      mobile: 12.sp,
      tablet: 14.sp,
    );
  }

  // Button padding
  static EdgeInsets get buttonPadding {
    return _responsive.responsiveValue(
      mobile: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      tablet: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
    );
  }

  static EdgeInsets get outlinedButtonPadding {
    return _responsive.responsiveValue(
      mobile: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      tablet: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
    );
  }

  static EdgeInsets get textButtonPadding {
    return _responsive.responsiveValue(
      mobile: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      tablet: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    );
  }

  // Icon sizes
  static double get iconSize {
    return _responsive.responsiveValue(
      mobile: 20.sp,
      tablet: 24.sp,
    );
  }

  // AppBar title size
  static double get appBarTitleSize {
    return _responsive.responsiveValue(
      mobile: 20.sp,
      tablet: 24.sp,
    );
  }

  // AppBar center title
  static bool get appBarCenterTitle {
    return _responsive.isMobile;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveController extends GetxController {
  final Rx<ScreenBreakpoint> currentBreakpoint =
      ScreenBreakpoint.smallPhone.obs;
  final RxDouble screenWidth = 0.0.obs;
  final RxDouble screenHeight = 0.0.obs;

  void updateScreenSize(BuildContext context) {
    screenWidth.value = MediaQuery.of(context).size.width;
    screenHeight.value = MediaQuery.of(context).size.height;
    _updateBreakpoint();
  }

  void _updateBreakpoint() {
    if (screenWidth.value <= 480) {
      currentBreakpoint.value = ScreenBreakpoint.smallPhone;
    } else if (screenWidth.value <= 768) {
      currentBreakpoint.value = ScreenBreakpoint.largePhone;
    } else {
      currentBreakpoint.value = ScreenBreakpoint.tablet;
    }
  }

  // ScreenUtil için yardımcı metodlar
  double get statusBarHeight => ScreenUtil().statusBarHeight;
  double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  // Responsive boyutlar için yardımcı metodlar
  double sp(double size) => size.sp;
  double w(double size) => size.w;
  double h(double size) => size.h;
  double r(double size) => size.r;

  // Responsive padding ve margin için yardımcı metodlar
  EdgeInsets responsivePadding({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.fromLTRB(
      w(left),
      h(top),
      w(right),
      h(bottom),
    );
  }

  bool get isSmallPhone =>
      currentBreakpoint.value == ScreenBreakpoint.smallPhone;
  bool get isLargePhone =>
      currentBreakpoint.value == ScreenBreakpoint.largePhone;
  bool get isTablet => currentBreakpoint.value == ScreenBreakpoint.tablet;
}

enum ScreenBreakpoint {
  smallPhone, // 320-480px
  largePhone, // 480-768px
  tablet, // 768px+
}

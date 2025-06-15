import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

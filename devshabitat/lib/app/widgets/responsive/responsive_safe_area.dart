import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';

class ResponsiveSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets? minimum;
  final bool maintainBottomViewPadding;
  final bool adaptivePadding;

  const ResponsiveSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
    this.adaptivePadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final mediaQuery = MediaQuery.of(context);

    EdgeInsets finalMinimum = minimum ?? EdgeInsets.zero;
    if (adaptivePadding) {
      finalMinimum = EdgeInsets.only(
        left: responsive.responsiveValue(
          mobile: finalMinimum.left,
          tablet: finalMinimum.left * 1.5,
        ),
        top: responsive.responsiveValue(
          mobile: finalMinimum.top,
          tablet: finalMinimum.top * 1.5,
        ),
        right: responsive.responsiveValue(
          mobile: finalMinimum.right,
          tablet: finalMinimum.right * 1.5,
        ),
        bottom: responsive.responsiveValue(
          mobile: finalMinimum.bottom,
          tablet: finalMinimum.bottom * 1.5,
        ),
      );
    }

    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: finalMinimum,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );
  }
}

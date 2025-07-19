import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';

class AnimatedResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Duration animationDuration;
  final Curve curve;
  final Widget? desktop;
  final bool maintainState;
  final bool layoutBuilder;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  const AnimatedResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    this.desktop,
    this.animationDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.maintainState = true,
    this.layoutBuilder = false,
    this.transitionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    Widget getLayoutForBreakpoint() {
      if (responsive.isDesktop && desktop != null) {
        return desktop!;
      }
      if (responsive.isTablet) {
        return tablet;
      }
      return mobile;
    }

    if (layoutBuilder) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedSwitcher(
            duration: animationDuration,
            switchInCurve: curve,
            switchOutCurve: curve,
            transitionBuilder: transitionBuilder ??
                (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: getLayoutForBreakpoint(),
          );
        },
      );
    }

    return AnimatedSwitcher(
      duration: animationDuration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: transitionBuilder ??
          (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
      child: getLayoutForBreakpoint(),
    );
  }
}

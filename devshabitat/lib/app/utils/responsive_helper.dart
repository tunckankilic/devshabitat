import 'package:flutter/material.dart';
import '../constants/app_breakpoints.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ResponsiveHelper {
  static double getResponsiveValue({
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final width = MediaQuery.of(navigatorKey.currentContext!).size.width;

    if (width < AppBreakpoints.tablet) {
      return mobile;
    } else if (width < AppBreakpoints.desktop) {
      return tablet;
    } else {
      return desktop;
    }
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppBreakpoints.tablet;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.tablet &&
      MediaQuery.of(context).size.width < AppBreakpoints.desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.desktop;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double getAdaptiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  static double getAdaptiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  static EdgeInsets getAdaptivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width <= AppBreakpoints.smallPhone) {
      return const EdgeInsets.all(AppBreakpoints.smallPhonePadding);
    } else if (width <= AppBreakpoints.largePhone) {
      return const EdgeInsets.all(AppBreakpoints.largePhonePadding);
    } else if (width <= AppBreakpoints.tablet) {
      return const EdgeInsets.all(AppBreakpoints.tabletPadding);
    } else {
      return const EdgeInsets.all(AppBreakpoints.desktopPadding);
    }
  }

  static double getAdaptiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width <= AppBreakpoints.smallPhone) {
      return AppBreakpoints.smallPhoneSpacing;
    } else if (width <= AppBreakpoints.largePhone) {
      return AppBreakpoints.largePhoneSpacing;
    } else if (width <= AppBreakpoints.tablet) {
      return AppBreakpoints.tabletSpacing;
    } else {
      return AppBreakpoints.desktopSpacing;
    }
  }

  static Widget getAdaptiveLayout({
    required BuildContext context,
    required Widget smallPhoneLayout,
    required Widget largePhoneLayout,
    required Widget tabletLayout,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width <= AppBreakpoints.smallPhone) {
      return smallPhoneLayout;
    } else if (width <= AppBreakpoints.largePhone) {
      return largePhoneLayout;
    } else {
      return tabletLayout;
    }
  }

  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.of(context).size.width <= AppBreakpoints.smallPhone;
  }

  static bool isLargePhone(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > AppBreakpoints.smallPhone &&
        width <= AppBreakpoints.largePhone;
  }

  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width > AppBreakpoints.largePhone;
  }
}

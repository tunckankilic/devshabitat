import 'package:flutter/material.dart';

class AppBreakpoints {
  final BuildContext context;

  AppBreakpoints._(this.context);

  static AppBreakpoints of(BuildContext context) {
    return AppBreakpoints._(context);
  }

  // Ekran boyutu kırılım noktaları
  static const double mobile = 360;
  static const double tablet = 768;
  static const double desktop = 1024;

  // Padding ve margin değerleri
  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 16;
  static const double paddingL = 24;
  static const double paddingXL = 32;

  // Border radius değerleri
  static const double radiusS = 4;
  static const double radiusM = 8;
  static const double radiusL = 16;
  static const double radiusXL = 24;

  // Font boyutları
  static const double fontSizeXS = 12;
  static const double fontSizeS = 14;
  static const double fontSizeM = 16;
  static const double fontSizeL = 18;
  static const double fontSizeXL = 20;
  static const double fontSizeXXL = 24;

  // Icon boyutları
  static const double iconSizeS = 16;
  static const double iconSizeM = 24;
  static const double iconSizeL = 32;
  static const double iconSizeXL = 48;

  bool get isMobile => MediaQuery.of(context).size.width <= mobile;
  bool get isTablet =>
      MediaQuery.of(context).size.width <= tablet &&
      MediaQuery.of(context).size.width > mobile;
  bool get isDesktop => MediaQuery.of(context).size.width > tablet;

  double responsivePadding({double all = 16, double multiplier = 1}) {
    if (isDesktop) {
      return paddingL * multiplier;
    } else if (isTablet) {
      return paddingM * multiplier;
    }
    return all;
  }

  T responsiveValue<T>({
    required T mobile,
    required T tablet,
    T? desktop,
  }) {
    if (isDesktop) {
      return desktop ?? tablet;
    } else if (isTablet) {
      return tablet;
    }
    return mobile;
  }
}

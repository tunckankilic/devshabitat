import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';

class ResponsiveThemeHelper {
  static ResponsiveController get _responsive =>
      Get.find<ResponsiveController>();

  // Font sizes based on breakpoints
  static double get displayLarge {
    return _responsive.responsiveValue(
      mobile: 32,
      tablet: 40,
    );
  }

  static double get displayMedium {
    return _responsive.responsiveValue(
      mobile: 28,
      tablet: 36,
    );
  }

  static double get displaySmall {
    return _responsive.responsiveValue(
      mobile: 24,
      tablet: 32,
    );
  }

  static double get headlineMedium {
    return _responsive.responsiveValue(
      mobile: 20,
      tablet: 28,
    );
  }

  static double get headlineSmall {
    return _responsive.responsiveValue(
      mobile: 18,
      tablet: 24,
    );
  }

  static double get titleLarge {
    return _responsive.responsiveValue(
      mobile: 16,
      tablet: 20,
    );
  }

  static double get bodyLarge {
    return _responsive.responsiveValue(
      mobile: 16,
      tablet: 18,
    );
  }

  static double get bodyMedium {
    return _responsive.responsiveValue(
      mobile: 14,
      tablet: 16,
    );
  }

  static double get bodySmall {
    return _responsive.responsiveValue(
      mobile: 12,
      tablet: 14,
    );
  }

  // Button padding
  static EdgeInsets get buttonPadding {
    return _responsive.responsiveValue(
      mobile: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tablet: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }

  static EdgeInsets get outlinedButtonPadding {
    return _responsive.responsiveValue(
      mobile: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tablet: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }

  static EdgeInsets get textButtonPadding {
    return _responsive.responsiveValue(
      mobile: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      tablet: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Icon sizes
  static double get iconSize {
    return _responsive.responsiveValue(
      mobile: 20,
      tablet: 24,
    );
  }

  // AppBar title size
  static double get appBarTitleSize {
    return _responsive.responsiveValue(
      mobile: 20,
      tablet: 24,
    );
  }

  // AppBar center title
  static bool get appBarCenterTitle {
    return _responsive.isMobile;
  }
}

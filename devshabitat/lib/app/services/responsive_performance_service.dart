import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/responsive_controller.dart';
import '../widgets/responsive/animated_responsive_wrapper.dart';

class ResponsivePerformanceService extends GetxService {
  final _debounceTimer = Rx<DateTime?>(null);
  static const _debounceDelay = Duration(milliseconds: 100);

  // Cache for responsive calculations
  final Map<String, dynamic> _calculationCache = {};

  @override
  void onInit() {
    super.onInit();
    // Clear cache when breakpoint changes
    ever(Get.find<ResponsiveController>().currentBreakpoint, (_) {
      _clearCache();
    });
  }

  /// Debounced screen size update to prevent excessive rebuilds
  void updateScreenSizeDebounced(
      BuildContext context, ResponsiveController controller) {
    final now = DateTime.now();
    _debounceTimer.value = now;

    Future.delayed(_debounceDelay, () {
      if (_debounceTimer.value == now) {}
    });
  }

  /// Cached responsive value calculation
  T getCachedResponsiveValue<T>({
    required String cacheKey,
    required T mobile,
    required T tablet,
    T? desktop,
  }) {
    if (_calculationCache.containsKey(cacheKey)) {
      return _calculationCache[cacheKey] as T;
    }

    final controller = Get.find<ResponsiveController>();
    final result = controller.responsiveValue<T>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );

    _calculationCache[cacheKey] = result;
    return result;
  }

  /// Clear calculation cache
  void _clearCache() {
    _calculationCache.clear();
  }

  /// Get optimized padding with caching
  EdgeInsets getOptimizedPadding({
    required String cacheKey,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    if (_calculationCache.containsKey(cacheKey)) {
      return _calculationCache[cacheKey] as EdgeInsets;
    }

    final controller = Get.find<ResponsiveController>();
    final result = controller.responsivePadding(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );

    _calculationCache[cacheKey] = result;
    return result;
  }

  /// Memory-efficient widget builder for responsive layouts
  Widget buildResponsiveWidget({
    required String cacheKey,
    required Widget Function() mobileBuilder,
    required Widget Function() tabletBuilder,
    Widget Function()? desktopBuilder,
  }) {
    final controller = Get.find<ResponsiveController>();

    return Obx(() {
      switch (controller.currentBreakpoint.value) {
        case ScreenBreakpoint.smallPhone:
        case ScreenBreakpoint.largePhone:
          return mobileBuilder();
        case ScreenBreakpoint.tablet:
          return desktopBuilder?.call() ?? tabletBuilder();
      }
    });
  }

  /// Optimized text size calculation with caching
  double getOptimizedTextSize({
    required String cacheKey,
    required double mobileSize,
    required double tabletSize,
    double? desktopSize,
  }) {
    return getCachedResponsiveValue<double>(
      cacheKey: '${cacheKey}_text_size',
      mobile: mobileSize,
      tablet: tabletSize,
      desktop: desktopSize,
    );
  }

  /// Pre-calculate common responsive values
  void preCalculateCommonValues() {
    final commonSizes = [8, 12, 16, 20, 24, 32, 48];

    for (final size in commonSizes) {
      getCachedResponsiveValue<double>(
        cacheKey: 'padding_$size',
        mobile: size.toDouble(),
        tablet: (size * 1.2).toDouble(),
      );

      getCachedResponsiveValue<double>(
        cacheKey: 'font_$size',
        mobile: size.toDouble(),
        tablet: (size * 1.1).toDouble(),
      );
    }
  }
}

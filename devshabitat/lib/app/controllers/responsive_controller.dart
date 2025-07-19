import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/responsive/animated_responsive_wrapper.dart';

class ResponsiveController extends GetxController {
  static ResponsiveController get to => Get.find();

  // Current breakpoint
  final Rx<ScreenBreakpoint> currentBreakpoint =
      ScreenBreakpoint.largePhone.obs;

  // Breakpoints
  final double smallPhoneBreakpoint = 360.0;
  final double largePhoneBreakpoint = 480.0;
  final double tabletBreakpoint = 768.0;
  final double desktopBreakpoint = 1024.0;
  final double largeDesktopBreakpoint = 1440.0;

  // Minimum touch target size (44pt as per iOS HIG)
  final double minTouchTarget = 44.0;

  // Performance optimization: prevent unnecessary updates
  static const double _breakpointThreshold = 5.0;
  final RxDouble _lastWidth = 0.0.obs;
  final RxDouble _lastHeight = 0.0.obs;

  // Screen metrics
  final RxDouble screenWidth = 0.0.obs;
  final RxDouble screenHeight = 0.0.obs;
  final RxDouble devicePixelRatio = 1.0.obs;
  final Rx<Orientation> orientation = Orientation.portrait.obs;

  // Breakpoint states
  bool get isSmallPhone => screenWidth.value < smallPhoneBreakpoint;
  bool get isLargePhone =>
      screenWidth.value >= smallPhoneBreakpoint &&
      screenWidth.value < tabletBreakpoint;
  bool get isTablet =>
      screenWidth.value >= tabletBreakpoint &&
      screenWidth.value < desktopBreakpoint;
  bool get isDesktop =>
      screenWidth.value >= desktopBreakpoint &&
      screenWidth.value < largeDesktopBreakpoint;
  bool get isLargeDesktop => screenWidth.value >= largeDesktopBreakpoint;

  bool get isMobile => isSmallPhone || isLargePhone;
  bool get isLandscape => orientation.value == Orientation.landscape;
  bool get isPortrait => orientation.value == Orientation.portrait;

  @override
  void onInit() {
    super.onInit();
    _updateScreenMetrics();
    ever(screenWidth, (_) => _onScreenMetricsChanged());
    ever(screenHeight, (_) => _onScreenMetricsChanged());
  }

  void _updateScreenMetrics() {
    final context = Get.context;
    if (context == null) return;

    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final pixelRatio = mediaQuery.devicePixelRatio;
    final newOrientation = mediaQuery.orientation;

    // Only update if significant change
    if ((size.width - _lastWidth.value).abs() > _breakpointThreshold ||
        (size.height - _lastHeight.value).abs() > _breakpointThreshold) {
      screenWidth.value = size.width;
      screenHeight.value = size.height;
      devicePixelRatio.value = pixelRatio;
      orientation.value = newOrientation;

      // Update current breakpoint
      if (size.width < smallPhoneBreakpoint) {
        currentBreakpoint.value = ScreenBreakpoint.smallPhone;
      } else if (size.width < tabletBreakpoint) {
        currentBreakpoint.value = ScreenBreakpoint.largePhone;
      } else {
        currentBreakpoint.value = ScreenBreakpoint.tablet;
      }

      _lastWidth.value = size.width;
      _lastHeight.value = size.height;
    }
  }

  void _onScreenMetricsChanged() {
    // Trigger layout updates only when necessary
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.forceAppUpdate();
    });
  }

  T responsiveValue<T>({
    required T mobile,
    required T tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop && largeDesktop != null) return largeDesktop;
    if (isDesktop && desktop != null) return desktop;
    if (isTablet) return tablet;
    return mobile;
  }

  EdgeInsets responsivePadding({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    if (all != null) {
      final value = responsiveValue(
        mobile: all,
        tablet: all * 1.5,
        desktop: all * 2,
      );
      return EdgeInsets.all(value);
    }

    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: horizontal != null
            ? responsiveValue(
                mobile: horizontal,
                tablet: horizontal * 1.5,
                desktop: horizontal * 2,
              )
            : 0,
        vertical: vertical != null
            ? responsiveValue(
                mobile: vertical,
                tablet: vertical * 1.5,
                desktop: vertical * 2,
              )
            : 0,
      );
    }

    return EdgeInsets.only(
      left: left != null
          ? responsiveValue(
              mobile: left,
              tablet: left * 1.5,
              desktop: left * 2,
            )
          : 0,
      top: top != null
          ? responsiveValue(
              mobile: top,
              tablet: top * 1.5,
              desktop: top * 2,
            )
          : 0,
      right: right != null
          ? responsiveValue(
              mobile: right,
              tablet: right * 1.5,
              desktop: right * 2,
            )
          : 0,
      bottom: bottom != null
          ? responsiveValue(
              mobile: bottom,
              tablet: bottom * 1.5,
              desktop: bottom * 2,
            )
          : 0,
    );
  }

  // Performance optimized scaling functions
  double get textScaleFactor => responsiveValue(
        mobile: 1.0,
        tablet: 1.1,
        desktop: 1.2,
        largeDesktop: 1.3,
      );

  double get iconScaleFactor => responsiveValue(
        mobile: 1.0,
        tablet: 1.2,
        desktop: 1.4,
        largeDesktop: 1.6,
      );

  // Touch target optimization
  double get minTouchTargetSize => responsiveValue(
        mobile: minTouchTarget,
        tablet: minTouchTarget * 1.2,
        desktop: minTouchTarget * 1.4,
      );

  // Animation duration optimization
  Duration get transitionDuration => Duration(
        milliseconds: responsiveValue(
          mobile: 200,
          tablet: 250,
          desktop: 300,
        ),
      );

  // Layout grid optimization
  double get gridSpacing => responsiveValue(
        mobile: 8,
        tablet: 16,
        desktop: 24,
      );

  int get gridColumns => responsiveValue(
        mobile: 2,
        tablet: 3,
        desktop: 4,
        largeDesktop: 6,
      );
}

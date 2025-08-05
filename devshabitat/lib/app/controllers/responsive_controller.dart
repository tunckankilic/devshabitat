import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/responsive/animated_responsive_wrapper.dart';

class ResponsiveController extends GetxController {
  static ResponsiveController get to => Get.find();

  // Current breakpoint
  final Rx<ScreenBreakpoint> currentBreakpoint = ScreenBreakpoint.compact.obs;

  // Breakpoints (Material Design 3 breakpoints)
  final double compactBreakpoint = 0.0; // 0-600dp
  final double mediumBreakpoint = 600.0; // 600-840dp
  final double expandedBreakpoint = 840.0; // 840dp+

  // Legacy breakpoints (for backward compatibility)
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

  // Material Design 3 breakpoint states
  bool get isCompact => screenWidth.value < mediumBreakpoint;
  bool get isMedium =>
      screenWidth.value >= mediumBreakpoint &&
      screenWidth.value < expandedBreakpoint;
  bool get isExpanded => screenWidth.value >= expandedBreakpoint;

  // Legacy breakpoint states (for backward compatibility)
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

  bool get isMobile => isCompact;
  bool get isLandscape => orientation.value == Orientation.landscape;
  bool get isPortrait => orientation.value == Orientation.portrait;

  // Safe area and keyboard handling
  final RxDouble keyboardHeight = 0.0.obs;
  final RxDouble bottomSafeArea = 0.0.obs;
  final RxDouble topSafeArea = 0.0.obs;

  bool get isKeyboardVisible => keyboardHeight.value > 0;

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
    final viewInsets = mediaQuery.viewInsets;
    final padding = mediaQuery.padding;

    // Only update if significant change
    if ((size.width - _lastWidth.value).abs() > _breakpointThreshold ||
        (size.height - _lastHeight.value).abs() > _breakpointThreshold) {
      screenWidth.value = size.width;
      screenHeight.value = size.height;
      devicePixelRatio.value = pixelRatio;
      orientation.value = newOrientation;
      keyboardHeight.value = viewInsets.bottom;
      bottomSafeArea.value = padding.bottom;
      topSafeArea.value = padding.top;

      // Update current breakpoint based on Material Design 3
      if (size.width < mediumBreakpoint) {
        currentBreakpoint.value = ScreenBreakpoint.compact;
      } else if (size.width < expandedBreakpoint) {
        currentBreakpoint.value = ScreenBreakpoint.medium;
      } else {
        currentBreakpoint.value = ScreenBreakpoint.expanded;
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
    // Material Design 3 breakpoints
    if (isExpanded) {
      return largeDesktop ?? desktop ?? tablet;
    } else if (isMedium) {
      return tablet;
    }
    return mobile;
  }

  // Material Design 3 specific responsive value
  T md3ResponsiveValue<T>({
    required T compact,
    required T medium,
    required T expanded,
  }) {
    if (isExpanded) return expanded;
    if (isMedium) return medium;
    return compact;
  }

  EdgeInsets responsivePadding({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
    double? all,
    bool includeSafeArea = true,
  }) {
    if (all != null) {
      final value = md3ResponsiveValue(
        compact: all,
        medium: all * 1.5,
        expanded: all * 2,
      );
      return EdgeInsets.all(value);
    }

    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: horizontal != null
            ? md3ResponsiveValue(
                compact: horizontal,
                medium: horizontal * 1.5,
                expanded: horizontal * 2,
              )
            : 0,
        vertical: vertical != null
            ? md3ResponsiveValue(
                compact: vertical,
                medium: vertical * 1.5,
                expanded: vertical * 2,
              )
            : 0,
      );
    }

    double effectiveTop = top ?? 0;
    double effectiveBottom = bottom ?? 0;

    if (includeSafeArea) {
      effectiveTop += topSafeArea.value;
      effectiveBottom += bottomSafeArea.value;

      // Add keyboard height to bottom padding if keyboard is visible
      if (isKeyboardVisible) {
        effectiveBottom += keyboardHeight.value;
      }
    }

    return EdgeInsets.only(
      left: left != null
          ? md3ResponsiveValue(
              compact: left,
              medium: left * 1.5,
              expanded: left * 2,
            )
          : 0,
      top: effectiveTop != 0
          ? md3ResponsiveValue(
              compact: effectiveTop,
              medium: effectiveTop * 1.5,
              expanded: effectiveTop * 2,
            )
          : 0,
      right: right != null
          ? md3ResponsiveValue(
              compact: right,
              medium: right * 1.5,
              expanded: right * 2,
            )
          : 0,
      bottom: effectiveBottom != 0
          ? md3ResponsiveValue(
              compact: effectiveBottom,
              medium: effectiveBottom * 1.5,
              expanded: effectiveBottom * 2,
            )
          : 0,
    );
  }

  // Material Design 3 optimized scaling functions
  double get textScaleFactor =>
      md3ResponsiveValue(compact: 1.0, medium: 1.1, expanded: 1.2);

  double get iconScaleFactor =>
      md3ResponsiveValue(compact: 1.0, medium: 1.2, expanded: 1.4);

  // Touch target optimization
  double get minTouchTargetSize => md3ResponsiveValue(
    compact: minTouchTarget,
    medium: minTouchTarget * 1.2,
    expanded: minTouchTarget * 1.4,
  );

  // Animation duration optimization
  Duration get transitionDuration => Duration(
    milliseconds: md3ResponsiveValue(compact: 200, medium: 250, expanded: 300),
  );

  // Layout grid optimization based on Material Design 3
  double get gridSpacing =>
      md3ResponsiveValue(compact: 8, medium: 16, expanded: 24);

  int get gridColumns => md3ResponsiveValue(
    compact: 4, // 0-600dp: 4 columns
    medium: 8, // 600-840dp: 8 columns
    expanded: 12, // 840dp+: 12 columns
  );

  // Material Design 3 margins
  double get horizontalMargin => md3ResponsiveValue(
    compact: 16, // 0-600dp: 16dp
    medium: 24, // 600-840dp: 24dp
    expanded: 24, // 840dp+: 24dp
  );

  // Material Design 3 gutters
  double get horizontalGutter => md3ResponsiveValue(
    compact: 16, // 0-600dp: 16dp
    medium: 24, // 600-840dp: 24dp
    expanded: 24, // 840dp+: 24dp
  );

  // Material Design 3 layout body width
  double get layoutBodyWidth => md3ResponsiveValue(
    compact: screenWidth.value, // 0-600dp: full width
    medium: screenWidth.value, // 600-840dp: full width
    expanded: 840.0, // 840dp+: fixed width
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../controllers/responsive_controller.dart';

mixin PerformanceOptimizer {
  final ResponsiveController _responsive = Get.find<ResponsiveController>();
  final RxBool _isAnimating = false.obs;
  final RxInt _frameCount = 0.obs;
  final RxDouble _fps = 0.0.obs;

  // FPS monitoring
  Ticker? _ticker;
  DateTime? _lastFrameTime;

  Widget optimizeWidgetTree(Widget child) {
    return RepaintBoundary(child: child);
  }

  Widget wrapWithRepaintBoundary(Widget child) {
    return RepaintBoundary(child: child);
  }

  Widget onlyWhenVisible(Widget child) {
    return child;
  }

  void startMonitoring() {
    _ticker?.dispose();
    _ticker = Ticker(_onTick)..start();
  }

  void stopMonitoring() {
    _ticker?.dispose();
    _ticker = null;
  }

  void _onTick(Duration elapsed) {
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!);
      _fps.value = 1000 / frameTime.inMilliseconds;
    }
    _lastFrameTime = now;
    _frameCount.value++;
  }

  // Animation optimization
  void startAnimation() {
    _isAnimating.value = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _optimizeForAnimation();
    });
  }

  void stopAnimation() {
    _isAnimating.value = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _restoreOptimizations();
    });
  }

  void _optimizeForAnimation() {
    // Reduce visual complexity during animations
    if (_responsive.isTablet || _responsive.isDesktop) {
      // Scale down effects on larger screens
      _reduceVisualEffects();
    }
  }

  void _restoreOptimizations() {
    // Restore normal visual effects
    _restoreVisualEffects();
  }

  void _reduceVisualEffects() {
    // Implement platform-specific optimizations
  }

  void _restoreVisualEffects() {
    // Restore platform-specific effects
  }

  // Text rendering optimization
  TextStyle optimizeTextStyle(TextStyle style) {
    if (style.fontSize == null) return style;

    return style.copyWith(
      fontSize: _responsive.responsiveValue(
        mobile: style.fontSize,
        tablet: style.fontSize! * _responsive.textScaleFactor,
        desktop: style.fontSize! * _responsive.textScaleFactor * 1.2,
      ),
      height: _optimizeLineHeight(style.height),
      letterSpacing: _optimizeLetterSpacing(style.letterSpacing),
    );
  }

  double? _optimizeLineHeight(double? height) {
    if (height == null) return null;
    return _responsive.responsiveValue(
      mobile: height,
      tablet: height * 1.1,
      desktop: height * 1.2,
    );
  }

  double? _optimizeLetterSpacing(double? letterSpacing) {
    if (letterSpacing == null) return null;
    return _responsive.responsiveValue(
      mobile: letterSpacing,
      tablet: letterSpacing * 1.1,
      desktop: letterSpacing * 1.2,
    );
  }

  // Layout optimization
  EdgeInsets optimizeEdgeInsets(EdgeInsets padding) {
    return EdgeInsets.only(
      left: _optimizeSpacing(padding.left),
      top: _optimizeSpacing(padding.top),
      right: _optimizeSpacing(padding.right),
      bottom: _optimizeSpacing(padding.bottom),
    );
  }

  double _optimizeSpacing(double value) {
    return _responsive.responsiveValue(
      mobile: value,
      tablet: value * 1.5,
      desktop: value * 2.0,
    );
  }

  // Animation duration optimization
  Duration optimizeAnimationDuration(Duration duration) {
    return Duration(
      milliseconds: _responsive.responsiveValue(
        mobile: duration.inMilliseconds,
        tablet: (duration.inMilliseconds * 1.2).round(),
        desktop: (duration.inMilliseconds * 1.5).round(),
      ),
    );
  }

  // Performance metrics
  double get currentFPS => _fps.value;
  int get frameCount => _frameCount.value;
  bool get isAnimating => _isAnimating.value;

  // Memory optimization
  void clearCache() {
    // Implement cache clearing logic
    _frameCount.value = 0;
    _fps.value = 0.0;
    _lastFrameTime = null;
  }

  // Dispose
  void dispose() {
    stopMonitoring();
    clearCache();
  }
}

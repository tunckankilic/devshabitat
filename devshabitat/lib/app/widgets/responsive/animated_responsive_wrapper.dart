import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/responsive_controller.dart';

enum ScreenBreakpoint {
  smallPhone,
  largePhone,
  tablet,
}

class AnimatedResponsiveWrapper extends StatefulWidget {
  final Widget Function(BuildContext context, ScreenBreakpoint breakpoint)
      builder;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedResponsiveWrapper({
    super.key,
    required this.builder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AnimatedResponsiveWrapper> createState() =>
      _AnimatedResponsiveWrapperState();
}

class _AnimatedResponsiveWrapperState extends State<AnimatedResponsiveWrapper>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ResponsiveController _responsiveController;
  ScreenBreakpoint? _currentBreakpoint;
  Widget? _currentWidget;
  Widget? _nextWidget;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _responsiveController = Get.find<ResponsiveController>();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));

    _currentBreakpoint = _responsiveController.currentBreakpoint.value;
    _currentWidget = widget.builder(context, _currentBreakpoint!);

    // Listen for breakpoint changes
    ever(_responsiveController.currentBreakpoint, _onBreakpointChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onBreakpointChanged(ScreenBreakpoint newBreakpoint) {
    if (_currentBreakpoint == newBreakpoint || _isTransitioning) return;

    setState(() {
      _isTransitioning = true;
      _nextWidget = widget.builder(context, newBreakpoint);
      _currentBreakpoint = newBreakpoint;
    });

    _animationController.forward().then((_) {
      setState(() {
        _currentWidget = _nextWidget;
        _nextWidget = null;
        _isTransitioning = false;
      });
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTransitioning) {
      return _currentWidget ?? Container();
    }

    return Stack(
      children: [
        // Current widget fading out
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: 1.0 - _fadeAnimation.value,
              child: _currentWidget ?? Container(),
            );
          },
        ),
        // Next widget fading in
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: _nextWidget ?? Container(),
            );
          },
        ),
      ],
    );
  }
}

// Specific animated responsive layouts
class AnimatedResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget? desktop;
  final Duration animationDuration;

  const AnimatedResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    this.desktop,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedResponsiveWrapper(
      animationDuration: animationDuration,
      builder: (context, breakpoint) {
        switch (breakpoint) {
          case ScreenBreakpoint.smallPhone:
          case ScreenBreakpoint.largePhone:
            return mobile;
          case ScreenBreakpoint.tablet:
            return desktop ?? tablet;
        }
      },
    );
  }
}

// Animated responsive padding
class AnimatedResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets mobilePadding;
  final EdgeInsets tabletPadding;
  final EdgeInsets? desktopPadding;
  final Duration animationDuration;

  const AnimatedResponsivePadding({
    super.key,
    required this.child,
    required this.mobilePadding,
    required this.tabletPadding,
    this.desktopPadding,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(() {
      EdgeInsets targetPadding = mobilePadding;
      switch (responsive.currentBreakpoint.value) {
        case ScreenBreakpoint.smallPhone:
        case ScreenBreakpoint.largePhone:
          targetPadding = mobilePadding;
          break;
        case ScreenBreakpoint.tablet:
          targetPadding = desktopPadding ?? tabletPadding;
          break;
      }

      return AnimatedPadding(
        duration: animationDuration,
        curve: Curves.easeInOut,
        padding: targetPadding,
        child: child,
      );
    });
  }
}

// Animated responsive container
class AnimatedResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final Duration animationDuration;

  const AnimatedResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(() {
      double? targetWidth;
      double? targetHeight;

      switch (responsive.currentBreakpoint.value) {
        case ScreenBreakpoint.smallPhone:
        case ScreenBreakpoint.largePhone:
          targetWidth = mobileWidth;
          targetHeight = mobileHeight;
          break;
        case ScreenBreakpoint.tablet:
          targetWidth = desktopWidth ?? tabletWidth;
          targetHeight = desktopHeight ?? tabletHeight;
          break;
      }

      return AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInOut,
        width: targetWidth,
        height: targetHeight,
        child: child,
      );
    });
  }
}

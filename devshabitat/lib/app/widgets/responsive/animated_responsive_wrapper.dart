import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';

enum ScreenBreakpoint {
  compact, // 0-600dp
  medium, // 600-840dp
  expanded, // 840dp+
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ),
    );

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
  final Widget compact;
  final Widget medium;
  final Widget expanded;
  final Duration animationDuration;

  const AnimatedResponsiveLayout({
    super.key,
    required this.compact,
    required this.medium,
    required this.expanded,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedResponsiveWrapper(
      animationDuration: animationDuration,
      builder: (context, breakpoint) {
        switch (breakpoint) {
          case ScreenBreakpoint.compact:
            return compact;
          case ScreenBreakpoint.medium:
            return medium;
          case ScreenBreakpoint.expanded:
            return expanded;
        }
      },
    );
  }
}

// Animated responsive padding
class AnimatedResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets compactPadding;
  final EdgeInsets mediumPadding;
  final EdgeInsets expandedPadding;
  final Duration animationDuration;
  final bool includeSafeArea;

  const AnimatedResponsivePadding({
    super.key,
    required this.child,
    required this.compactPadding,
    required this.mediumPadding,
    required this.expandedPadding,
    this.animationDuration = const Duration(milliseconds: 200),
    this.includeSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(() {
      EdgeInsets targetPadding;
      switch (responsive.currentBreakpoint.value) {
        case ScreenBreakpoint.compact:
          targetPadding = compactPadding;
          break;
        case ScreenBreakpoint.medium:
          targetPadding = mediumPadding;
          break;
        case ScreenBreakpoint.expanded:
          targetPadding = expandedPadding;
          break;
      }

      if (includeSafeArea) {
        final mediaQuery = MediaQuery.of(context);
        targetPadding = targetPadding.copyWith(
          top: targetPadding.top + mediaQuery.padding.top,
          bottom:
              targetPadding.bottom +
              mediaQuery.padding.bottom +
              (mediaQuery.viewInsets.bottom > 0
                  ? mediaQuery.viewInsets.bottom
                  : 0),
        );
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
  final double? compactWidth;
  final double? mediumWidth;
  final double? expandedWidth;
  final double? compactHeight;
  final double? mediumHeight;
  final double? expandedHeight;
  final Duration animationDuration;

  const AnimatedResponsiveContainer({
    super.key,
    required this.child,
    this.compactWidth,
    this.mediumWidth,
    this.expandedWidth,
    this.compactHeight,
    this.mediumHeight,
    this.expandedHeight,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(() {
      double? targetWidth;
      double? targetHeight;

      switch (responsive.currentBreakpoint.value) {
        case ScreenBreakpoint.compact:
          targetWidth = compactWidth;
          targetHeight = compactHeight;
          break;
        case ScreenBreakpoint.medium:
          targetWidth = mediumWidth;
          targetHeight = mediumHeight;
          break;
        case ScreenBreakpoint.expanded:
          targetWidth = expandedWidth;
          targetHeight = expandedHeight;
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

// Keyboard aware container
class KeyboardAwareContainer extends StatelessWidget {
  final Widget child;
  final bool maintainBottomViewPadding;
  final bool maintainState;

  const KeyboardAwareContainer({
    super.key,
    required this.child,
    this.maintainBottomViewPadding = true,
    this.maintainState = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.only(
          bottom: maintainBottomViewPadding
              ? MediaQuery.of(context).viewInsets.bottom
              : 0,
        ),
        child: child,
      ),
    );
  }
}

// Safe area container
class SafeAreaContainer extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets minimum;
  final bool maintainBottomViewPadding;

  const SafeAreaContainer({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/responsive_controller.dart';

class AdaptiveTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? tooltip;
  final bool enabled;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? hoverColor;
  final Color? focusColor;
  final double? customMinSize;
  final EdgeInsets? padding;
  final bool adaptivePadding;
  final bool maintainSize;

  const AdaptiveTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.tooltip,
    this.enabled = true,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.focusColor,
    this.customMinSize,
    this.padding,
    this.adaptivePadding = true,
    this.maintainSize = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final minSize = customMinSize ?? responsive.minTouchTarget;

    Widget result = child;

    if (maintainSize) {
      result = SizedBox(
        width: minSize,
        height: minSize,
        child: Center(child: result),
      );
    }

    if (padding != null) {
      EdgeInsets finalPadding = padding!;
      if (adaptivePadding) {
        finalPadding = EdgeInsets.only(
          left: responsive.responsiveValue(
            mobile: padding!.left,
            tablet: padding!.left * 1.5,
          ),
          top: responsive.responsiveValue(
            mobile: padding!.top,
            tablet: padding!.top * 1.5,
          ),
          right: responsive.responsiveValue(
            mobile: padding!.right,
            tablet: padding!.right * 1.5,
          ),
          bottom: responsive.responsiveValue(
            mobile: padding!.bottom,
            tablet: padding!.bottom * 1.5,
          ),
        );
      }
      result = Padding(
        padding: finalPadding,
        child: result,
      );
    }

    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        child: result,
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        splashColor: splashColor,
        highlightColor: highlightColor,
        hoverColor: hoverColor,
        focusColor: focusColor,
        borderRadius: BorderRadius.circular(minSize / 2),
        child: result,
      ),
    );
  }
}

// Accessibility-compliant button wrapper
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final bool enabled;
  final EdgeInsets? padding;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.enabled = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: enabled,
      child: AdaptiveTouchTarget(
        onTap: enabled ? onPressed : null,
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: responsive.responsiveValue(mobile: 16, tablet: 20),
              vertical: responsive.responsiveValue(mobile: 12, tablet: 16),
            ),
        child: child,
      ),
    );
  }
}

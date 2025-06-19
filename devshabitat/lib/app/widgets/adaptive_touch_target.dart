import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdaptiveTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double minSize;
  final EdgeInsets? padding;
  final Color? splashColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;

  const AdaptiveTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minSize = 48.0,
    this.padding,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 480;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor ?? Theme.of(context).splashColor,
        highlightColor: highlightColor ?? Theme.of(context).highlightColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        child: Container(
          constraints: BoxConstraints(
            minWidth: isSmallScreen ? minSize.w : (minSize * 1.2).w,
            minHeight: isSmallScreen ? minSize.h : (minSize * 1.2).h,
          ),
          padding: padding ?? EdgeInsets.all(8.r),
          child: Center(child: child),
        ),
      ),
    );
  }
}

// Kullanım örneği:
/*
AdaptiveTouchTarget(
  onTap: () => print('Tapped!'),
  child: Icon(Icons.add),
)
*/

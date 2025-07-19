import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../services/responsive_performance_service.dart';

class AdaptiveLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const AdaptiveLoadingIndicator({
    super.key,
    this.color,
    this.size = 24.0,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Center(
      child: SizedBox(
        height: responsive.responsiveValue(
          mobile: size,
          tablet: size * 1.2,
        ),
        width: responsive.responsiveValue(
          mobile: size,
          tablet: size * 1.2,
        ),
        child: CircularProgressIndicator(
          strokeWidth: responsive.responsiveValue(
            mobile: strokeWidth,
            tablet: strokeWidth * 1.2,
          ),
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

class AdaptiveLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? color;
  final String? message;

  const AdaptiveLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                margin: EdgeInsets.all(
                  responsive.responsiveValue(
                    mobile: 16.w,
                    tablet: 20.w,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    responsive.responsiveValue(
                      mobile: 16.w,
                      tablet: 20.w,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AdaptiveLoadingIndicator(color: color),
                      if (message != null) ...[
                        SizedBox(
                          height: responsive.responsiveValue(
                            mobile: 16.h,
                            tablet: 20.h,
                          ),
                        ),
                        Text(
                          message!,
                          style: TextStyle(
                            fontSize: performanceService.getOptimizedTextSize(
                              cacheKey: 'loading_message',
                              mobileSize: 16.sp,
                              tabletSize: 18.sp,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

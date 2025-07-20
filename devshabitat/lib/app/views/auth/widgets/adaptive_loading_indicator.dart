import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../services/responsive_performance_service.dart';

class AdaptiveLoadingIndicator extends StatelessWidget {
  final _responsiveController = Get.find<ResponsiveController>();
  final Color? color;
  final String? message;
  final bool isSmall;

  AdaptiveLoadingIndicator({
    Key? key,
    this.color,
    this.message,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _responsiveController.responsiveValue(
            mobile: isSmall ? 16.0 : 24.0,
            tablet: isSmall ? 20.0 : 32.0,
          ),
          height: _responsiveController.responsiveValue(
            mobile: isSmall ? 16.0 : 24.0,
            tablet: isSmall ? 20.0 : 32.0,
          ),
          child: CircularProgressIndicator(
            strokeWidth: _responsiveController.responsiveValue(
              mobile: isSmall ? 2.0 : 3.0,
              tablet: isSmall ? 2.5 : 3.5,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (message != null) ...[
          SizedBox(
              height: _responsiveController.responsiveValue(
            mobile: 16.0,
            tablet: 20.0,
          )),
          Text(
            message!,
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 18.0,
              ),
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ],
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
                    mobile: 16,
                    tablet: 20,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    responsive.responsiveValue(
                      mobile: 16,
                      tablet: 20,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AdaptiveLoadingIndicator(color: color),
                      if (message != null) ...[
                        SizedBox(
                          height: responsive.responsiveValue(
                            mobile: 16,
                            tablet: 20,
                          ),
                        ),
                        Text(
                          message!,
                          style: TextStyle(
                            fontSize: performanceService.getOptimizedTextSize(
                              cacheKey: 'loading_message',
                              mobileSize: 16,
                              tabletSize: 18,
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

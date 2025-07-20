import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_strings.dart';
import '../controllers/responsive_controller.dart';

class ErrorStateWidget extends StatelessWidget {
  final String? message;
  final String? retryText;
  final VoidCallback? onRetry;
  final IconData? icon;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  const ErrorStateWidget({
    super.key,
    this.message,
    this.retryText,
    this.onRetry,
    this.icon,
    this.iconSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Center(
      child: Padding(
        padding: padding ??
            EdgeInsets.all(responsive.responsiveValue(mobile: 16, tablet: 20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: iconSize ??
                  responsive.responsiveValue(mobile: 48, tablet: 56),
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            Text(
              message ?? AppStrings.errorGeneric,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16),
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(
                  height: responsive.responsiveValue(mobile: 16, tablet: 20)),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        responsive.responsiveValue(mobile: 16, tablet: 20),
                    vertical: responsive.responsiveValue(mobile: 8, tablet: 12),
                  ),
                ),
                child: Text(
                  retryText ?? AppStrings.retry,
                  style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

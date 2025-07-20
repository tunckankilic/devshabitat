import 'package:devshabitat/app/core/theme/dev_habitat_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/dev_habitat_theme.dart';
import '../controllers/responsive_controller.dart';

class GlobalLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isDismissible;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? size;

  const GlobalLoadingOverlay({
    super.key,
    this.message,
    this.isDismissible = false,
    this.backgroundColor,
    this.progressColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Material(
      color: backgroundColor ?? Colors.black54,
      child: Center(
        child: GlassContainer(
          borderRadius: responsive.responsiveValue(mobile: 16, tablet: 20),
          padding: EdgeInsets.all(
              responsive.responsiveValue(mobile: 16, tablet: 20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width:
                    size ?? responsive.responsiveValue(mobile: 40, tablet: 48),
                height:
                    size ?? responsive.responsiveValue(mobile: 40, tablet: 48),
                child: CircularProgressIndicator(
                  color: progressColor ?? DevHabitatColors.primary,
                  strokeWidth: responsive.responsiveValue(mobile: 2, tablet: 3),
                ),
              ),
              if (message != null) ...[
                SizedBox(
                    height: responsive.responsiveValue(mobile: 12, tablet: 16)),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize:
                            responsive.responsiveValue(mobile: 14, tablet: 16),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static void show({
    String? message,
    bool isDismissible = false,
    Color? backgroundColor,
    Color? progressColor,
    double? size,
  }) {
    Get.dialog(
      GlobalLoadingOverlay(
        message: message,
        isDismissible: isDismissible,
        backgroundColor: backgroundColor,
        progressColor: progressColor,
        size: size,
      ),
      barrierDismissible: isDismissible,
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

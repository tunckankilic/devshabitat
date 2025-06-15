import 'package:devshabitat/app/core/theme/dev_habitat_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/app_controller.dart';
import '../constants/app_strings.dart';
import '../core/theme/dev_habitat_theme.dart';

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
    return Material(
      color: backgroundColor ?? Colors.black54,
      child: Center(
        child: GlassContainer(
          borderRadius: 16.r,
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size ?? 40.w,
                height: size ?? 40.w,
                child: CircularProgressIndicator(
                  color: progressColor ?? DevHabitatColors.primary,
                  strokeWidth: 2.w,
                ),
              ),
              if (message != null) ...[
                SizedBox(height: 12.h),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
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

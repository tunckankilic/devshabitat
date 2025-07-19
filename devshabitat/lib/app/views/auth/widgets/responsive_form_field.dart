import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../services/responsive_performance_service.dart';

class ResponsiveFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const ResponsiveFormField({
    super.key,
    required this.label,
    this.hint,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'form_field_label_$label',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: responsive.responsiveValue(
                mobile: 8.h,
                tablet: 12.h,
              ),
            ),
            Flexible(
              child: TextFormField(
                controller: controller,
                obscureText: isPassword,
                validator: validator,
                inputFormatters: inputFormatters,
                keyboardType: keyboardType,
                enabled: enabled,
                maxLines: maxLines,
                minLines: minLines,
                autofocus: autofocus,
                focusNode: focusNode,
                textInputAction: textInputAction,
                onFieldSubmitted: onFieldSubmitted,
                style: TextStyle(
                  fontSize: performanceService.getOptimizedTextSize(
                    cacheKey: 'form_field_text_$label',
                    mobileSize: 16.sp,
                    tabletSize: 18.sp,
                  ),
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: performanceService.getOptimizedTextSize(
                      cacheKey: 'form_field_hint_$label',
                      mobileSize: 16.sp,
                      tabletSize: 18.sp,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      responsive.responsiveValue(
                        mobile: 8.r,
                        tablet: 12.r,
                      ),
                    ),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      responsive.responsiveValue(
                        mobile: 8.r,
                        tablet: 12.r,
                      ),
                    ),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      responsive.responsiveValue(
                        mobile: 8.r,
                        tablet: 12.r,
                      ),
                    ),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      responsive.responsiveValue(
                        mobile: 8.r,
                        tablet: 12.r,
                      ),
                    ),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive.responsiveValue(
                      mobile: 16.w,
                      tablet: 20.w,
                    ),
                    vertical: responsive.responsiveValue(
                      mobile: 12.h,
                      tablet: 16.h,
                    ),
                  ),
                  isDense: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

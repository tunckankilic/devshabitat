import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/responsive_controller.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return ListTile(
      contentPadding: responsive.responsivePadding(
        horizontal: 16,
        vertical: 8,
      ),
      leading: Icon(
        icon,
        size: responsive.responsiveValue(
          mobile: 24.sp,
          tablet: 32.sp,
        ),
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: responsive.responsiveValue(
            mobile: 16.sp,
            tablet: 18.sp,
          ),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 12.sp,
                  tablet: 14.sp,
                ),
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

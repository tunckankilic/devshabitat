import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? logoPath;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Column(
      children: [
        if (logoPath != null)
          Image.asset(
            logoPath!,
            width: responsive.responsiveValue(
              mobile: 80,
              tablet: 100,
            ),
            height: responsive.responsiveValue(
              mobile: 80,
              tablet: 100,
            ),
          ),
        SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 24,
              tablet: 28,
            ),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

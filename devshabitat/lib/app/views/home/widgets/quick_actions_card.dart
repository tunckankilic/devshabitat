import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/responsive_controller.dart';

class QuickActionsCard extends GetView<HomeController> {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(
            mobile: 16.r,
            tablet: 20.r,
          ),
        ),
      ),
      child: Padding(
        padding: responsive.responsivePadding(
          all: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hızlı Eylemler',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 18.sp,
                  tablet: 22.sp,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16.h, tablet: 20.h)),
            _buildActionButton(
              icon: Icons.add_circle_outline,
              label: 'Yeni Proje',
              onTap: () => Get.toNamed('/new-project'),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 8.h, tablet: 12.h)),
            _buildActionButton(
              icon: Icons.people_outline,
              label: 'Bağlantı Ekle',
              onTap: () => Get.toNamed('/connections'),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 8.h, tablet: 12.h)),
            _buildActionButton(
              icon: Icons.article_outlined,
              label: 'Blog Yaz',
              onTap: () => Get.toNamed('/new-blog'),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 8.h, tablet: 12.h)),
            _buildActionButton(
              icon: Icons.event_outlined,
              label: 'Etkinlik Oluştur',
              onTap: () => Get.toNamed('/new-event'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final responsive = Get.find<ResponsiveController>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        responsive.responsiveValue(
          mobile: 8.r,
          tablet: 12.r,
        ),
      ),
      child: Container(
        padding: responsive.responsivePadding(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(
            responsive.responsiveValue(
              mobile: 8.r,
              tablet: 12.r,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: responsive.responsiveValue(
                mobile: 24.r,
                tablet: 28.r,
              ),
            ),
            SizedBox(
                width: responsive.responsiveValue(mobile: 12.w, tablet: 16.w)),
            Text(
              label,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16.sp,
                  tablet: 18.sp,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: responsive.responsiveValue(
                mobile: 16.r,
                tablet: 18.r,
              ),
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}

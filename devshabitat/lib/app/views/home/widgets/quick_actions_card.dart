import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/home_controller.dart';

class QuickActionsCard extends GetView<HomeController> {
  const QuickActionsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hızlı Eylemler',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildActionButton(
              icon: Icons.add_circle_outline,
              label: 'Yeni Proje',
              onTap: () => Get.toNamed('/new-project'),
            ),
            SizedBox(height: 8.h),
            _buildActionButton(
              icon: Icons.people_outline,
              label: 'Bağlantı Ekle',
              onTap: () => Get.toNamed('/connections'),
            ),
            SizedBox(height: 8.h),
            _buildActionButton(
              icon: Icons.article_outlined,
              label: 'Blog Yaz',
              onTap: () => Get.toNamed('/new-blog'),
            ),
            SizedBox(height: 8.h),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.r),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.r,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}

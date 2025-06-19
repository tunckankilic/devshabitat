import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/home_controller.dart';

class ConnectionsOverviewCard extends GetView<HomeController> {
  const ConnectionsOverviewCard({super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bağlantılarım',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/connections'),
                  child: Text(
                    'Tümünü Gör',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  _buildConnectionStat(
                    label: 'Toplam Bağlantı',
                    value: controller.connectionCount.value.toString(),
                    icon: Icons.people,
                  ),
                  SizedBox(height: 12.h),
                  _buildConnectionStat(
                    label: 'Yeni Mesajlar',
                    value: '3',
                    icon: Icons.message,
                  ),
                  SizedBox(height: 12.h),
                  _buildConnectionStat(
                    label: 'Bekleyen İstekler',
                    value: '5',
                    icon: Icons.person_add,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.r),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

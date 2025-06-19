import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileSummaryCard extends GetView<AuthController> {
  const ProfileSummaryCard({super.key});

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
              children: [
                Obx(() {
                  final user = controller.currentUser;
                  return CircleAvatar(
                    radius: 30.r,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Icon(Icons.person, size: 30.r)
                        : null,
                  );
                }),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final user = controller.currentUser;
                        return Text(
                          user?.displayName ?? 'İsimsiz Kullanıcı',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                      SizedBox(height: 4.h),
                      Obx(() {
                        final user = controller.currentUser;
                        return Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final profile = controller.userProfile;
              return Text(
                profile?['bio'] ?? 'Henüz bir biyografi eklenmemiş.',
                style: TextStyle(fontSize: 14.sp),
              );
            }),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.code,
                  label: 'Projeler',
                  value: '12',
                ),
                _buildStatItem(
                  icon: Icons.people,
                  label: 'Takipçiler',
                  value: '250',
                ),
                _buildStatItem(
                  icon: Icons.star,
                  label: 'Yıldızlar',
                  value: '1.2K',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24.r),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

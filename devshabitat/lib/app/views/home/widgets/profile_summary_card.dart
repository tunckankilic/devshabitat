import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/responsive_controller.dart';

class ProfileSummaryCard extends GetView<AuthController> {
  const ProfileSummaryCard({super.key});

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
            Row(
              children: [
                Obx(() {
                  final user = controller.currentUser;
                  return CircleAvatar(
                    radius: responsive.responsiveValue(
                      mobile: 30.r,
                      tablet: 40.r,
                    ),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Icon(
                            Icons.person,
                            size: responsive.responsiveValue(
                              mobile: 30.r,
                              tablet: 40.r,
                            ),
                          )
                        : null,
                  );
                }),
                SizedBox(
                    width:
                        responsive.responsiveValue(mobile: 16.w, tablet: 20.w)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final user = controller.currentUser;
                        return Text(
                          user?.displayName ?? 'İsimsiz Kullanıcı',
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                              mobile: 18.sp,
                              tablet: 22.sp,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                      SizedBox(
                          height: responsive.responsiveValue(
                              mobile: 4.h, tablet: 6.h)),
                      Obx(() {
                        final user = controller.currentUser;
                        return Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                              mobile: 14.sp,
                              tablet: 16.sp,
                            ),
                            color: Colors.grey[600],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16.h, tablet: 20.h)),
            Obx(() {
              final profile = controller.userProfile;
              return Text(
                profile['bio'] ?? 'Henüz bir biyografi eklenmemiş.',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14.sp,
                    tablet: 16.sp,
                  ),
                ),
              );
            }),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16.h, tablet: 20.h)),
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
    final responsive = Get.find<ResponsiveController>();

    return Column(
      children: [
        Icon(
          icon,
          size: responsive.responsiveValue(
            mobile: 24.r,
            tablet: 32.r,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 4.h, tablet: 6.h)),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16.sp,
              tablet: 18.sp,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 12.sp,
              tablet: 14.sp,
            ),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

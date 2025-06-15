import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/home_controller.dart';

class ActivityFeedCard extends GetView<HomeController> {
  const ActivityFeedCard({Key? key}) : super(key: key);

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
              'Aktivite Akışı',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.activityFeed.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 48.r,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Henüz aktivite yok',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.activityFeed.length,
                separatorBuilder: (context, index) => Divider(height: 16.h),
                itemBuilder: (context, index) {
                  final activity = controller.activityFeed[index];
                  return _buildActivityItem(activity);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundImage: NetworkImage(activity['userAvatar'] ?? ''),
          child: activity['userAvatar'] == null
              ? Icon(Icons.person, size: 24.r)
              : null,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: activity['userName'] ?? 'Kullanıcı',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' ${activity['action'] ?? ''}'),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                activity['time'] ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

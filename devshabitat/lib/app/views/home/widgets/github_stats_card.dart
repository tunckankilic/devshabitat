import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/home_controller.dart';

class GithubStatsCard extends GetView<HomeController> {
  const GithubStatsCard({Key? key}) : super(key: key);

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
                  'GitHub İstatistikleri',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.refreshData,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final stats = controller.githubStats;
              return Column(
                children: [
                  _buildStatRow(
                    label: 'Toplam Commit',
                    value: stats['totalCommits']?.toString() ?? '0',
                    icon: Icons.commit,
                  ),
                  SizedBox(height: 12.h),
                  _buildStatRow(
                    label: 'Açık PR\'lar',
                    value: stats['openPRs']?.toString() ?? '0',
                    icon: Icons.call_merge,
                  ),
                  SizedBox(height: 12.h),
                  _buildStatRow(
                    label: 'Katkı Yapılan Repolar',
                    value: stats['contributedRepos']?.toString() ?? '0',
                    icon: Icons.source,
                  ),
                  SizedBox(height: 12.h),
                  _buildStatRow(
                    label: 'Yıldızlı Repolar',
                    value: stats['starredRepos']?.toString() ?? '0',
                    icon: Icons.star_border,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

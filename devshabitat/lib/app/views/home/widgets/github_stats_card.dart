import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/responsive_controller.dart';

class GithubStatsCard extends GetView<HomeController> {
  const GithubStatsCard({super.key});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GitHub İstatistikleri',
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 18.sp,
                      tablet: 22.sp,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    size: responsive.responsiveValue(
                      mobile: 24.r,
                      tablet: 28.r,
                    ),
                  ),
                  onPressed: controller.refreshData,
                ),
              ],
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16.h, tablet: 20.h)),
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
                  SizedBox(
                      height: responsive.responsiveValue(
                          mobile: 12.h, tablet: 16.h)),
                  _buildStatRow(
                    label: 'Açık PR\'lar',
                    value: stats['openPRs']?.toString() ?? '0',
                    icon: Icons.call_merge,
                  ),
                  SizedBox(
                      height: responsive.responsiveValue(
                          mobile: 12.h, tablet: 16.h)),
                  _buildStatRow(
                    label: 'Katkı Yapılan Repolar',
                    value: stats['contributedRepos']?.toString() ?? '0',
                    icon: Icons.source,
                  ),
                  SizedBox(
                      height: responsive.responsiveValue(
                          mobile: 12.h, tablet: 16.h)),
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
    final responsive = Get.find<ResponsiveController>();

    return Container(
      padding: responsive.responsivePadding(
        vertical: 8,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
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
              mobile: 20.r,
              tablet: 24.r,
            ),
          ),
          SizedBox(
              width: responsive.responsiveValue(mobile: 12.w, tablet: 16.w)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14.sp,
                  tablet: 16.sp,
                ),
                color: Colors.grey[700],
              ),
            ),
          ),
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
        ],
      ),
    );
  }
}

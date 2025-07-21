import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            mobile: 16,
            tablet: 20,
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
                  AppStrings.githubStats,
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 18,
                      tablet: 22,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    size: responsive.responsiveValue(
                      mobile: 24,
                      tablet: 28,
                    ),
                  ),
                  onPressed: controller.refreshData,
                ),
              ],
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final stats = controller.githubStats;
              return Column(
                children: [
                  _buildStatRow(
                    label: AppStrings.totalCommits,
                    value: stats['totalCommits']?.toString() ?? '0',
                    icon: Icons.commit,
                  ),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 12, tablet: 16)),
                  _buildStatRow(
                    label: AppStrings.openPRs,
                    value: stats['openPRs']?.toString() ?? '0',
                    icon: Icons.call_merge,
                  ),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 12, tablet: 16)),
                  _buildStatRow(
                    label: AppStrings.contributedRepos,
                    value: stats['contributedRepos']?.toString() ?? '0',
                    icon: Icons.source,
                  ),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 12, tablet: 16)),
                  _buildStatRow(
                    label: AppStrings.starredRepos,
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
            mobile: 8,
            tablet: 12,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: responsive.responsiveValue(
              mobile: 20,
              tablet: 24,
            ),
          ),
          SizedBox(width: responsive.responsiveValue(mobile: 12, tablet: 16)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 16,
                tablet: 18,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

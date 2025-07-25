import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../controllers/home_controller.dart';

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
              children: [
                Obx(() {
                  final user = controller.currentUser;
                  return CircleAvatar(
                    radius: responsive.responsiveValue(
                      mobile: 30,
                      tablet: 40,
                    ),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Icon(
                            Icons.person,
                            size: responsive.responsiveValue(
                              mobile: 30,
                              tablet: 40,
                            ),
                          )
                        : null,
                  );
                }),
                SizedBox(
                    width: responsive.responsiveValue(mobile: 16, tablet: 20)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final user = controller.currentUser;
                        return Text(
                          user?.displayName ?? AppStrings.noName,
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                              mobile: 18,
                              tablet: 22,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                      SizedBox(
                          height:
                              responsive.responsiveValue(mobile: 4, tablet: 6)),
                      Obx(() {
                        final user = controller.currentUser;
                        return Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                              mobile: 14,
                              tablet: 16,
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
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            Obx(() {
              final profile = controller.userProfile;
              return Text(
                profile['bio'] ?? AppStrings.noBio,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14,
                    tablet: 16,
                  ),
                ),
              );
            }),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            // GitHub Stats Row
            Obx(() {
              final homeController = Get.find<HomeController>();
              final githubStats = homeController.githubStats;
              final userInfo = githubStats['userInfo'] as Map<String, dynamic>?;
              final repos = githubStats['repos'] as List<dynamic>?;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.code,
                    label: AppStrings.projects,
                    value: (repos?.length ?? 0).toString(),
                  ),
                  _buildStatItem(
                    icon: Icons.people,
                    label: AppStrings.followers,
                    value: _formatNumber(userInfo?['followers'] ?? 0),
                  ),
                  _buildStatItem(
                    icon: Icons.star,
                    label: AppStrings.stars,
                    value: _formatNumber(_calculateTotalStars(repos ?? [])),
                  ),
                ],
              );
            }),
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
            mobile: 24,
            tablet: 32,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 4, tablet: 6)),
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
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 12,
              tablet: 14,
            ),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  int _calculateTotalStars(List<dynamic> repos) {
    int totalStars = 0;
    for (var repo in repos) {
      if (repo is Map<String, dynamic>) {
        totalStars += (repo['stargazers_count'] as int?) ?? 0;
      }
    }
    return totalStars;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';
import '../../models/community/community_model.dart';

class CommunityStatsWidget extends StatelessWidget {
  final CommunityModel community;

  const CommunityStatsWidget({
    Key? key,
    required this.community,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Card(
      child: Padding(
        padding: responsive.responsivePadding(all: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topluluk İstatistikleri',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'community_stats_title',
                  mobileSize: 20,
                  tabletSize: 24.sp,
                ),
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(
              mobile: 16.h,
              tablet: 20.h,
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.people,
                  'Üyeler',
                  community.memberCount.toString(),
                ),
                _buildStatItem(
                  context,
                  Icons.event,
                  'Etkinlikler',
                  community.eventCount.toString(),
                ),
                _buildStatItem(
                  context,
                  Icons.message,
                  'Gönderiler',
                  community.postCount.toString(),
                ),
              ],
            ),
            SizedBox(
                height: responsive.responsiveValue(
              mobile: 16.h,
              tablet: 20.h,
            )),
            Divider(
              thickness: responsive.responsiveValue(
                mobile: 1,
                tablet: 1.5,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(
              mobile: 16.h,
              tablet: 20.h,
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.admin_panel_settings,
                  'Moderatörler',
                  community.moderatorIds.length.toString(),
                ),
                _buildStatItem(
                  context,
                  Icons.person_add,
                  'Bekleyen İstekler',
                  community.pendingMemberIds.length.toString(),
                ),
                _buildStatItem(
                  context,
                  Icons.calendar_today,
                  'Kuruluş',
                  _formatDate(community.createdAt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: responsive.responsiveValue(
            mobile: 28.sp,
            tablet: 32.sp,
          ),
        ),
        SizedBox(
            height: responsive.responsiveValue(
          mobile: 8.h,
          tablet: 12.h,
        )),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_stats_label',
              mobileSize: 14.sp,
              tabletSize: 16.sp,
            ),
          ),
        ),
        SizedBox(
            height: responsive.responsiveValue(
          mobile: 4.h,
          tablet: 6.h,
        )),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_stats_value',
              mobileSize: 16.sp,
              tabletSize: 18.sp,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

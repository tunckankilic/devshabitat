import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';
import '../../models/community/community_model.dart';

class CommunityStatsWidget extends StatelessWidget {
  final CommunityModel community;

  const CommunityStatsWidget({
    super.key,
    required this.community,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Container(
      padding: responsive.responsivePadding(all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.communityStatistics,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  responsive,
                  AppStrings.members,
                  '${community.memberCount}',
                  Icons.people,
                ),
              ),
              SizedBox(
                  width: responsive.responsiveValue(mobile: 16, tablet: 20)),
              Expanded(
                child: _buildStatItem(
                  responsive,
                  AppStrings.events,
                  '${community.eventCount}',
                  Icons.event,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  responsive,
                  AppStrings.activity,
                  _getActivityLevel(75),
                  Icons.trending_up,
                ),
              ),
              SizedBox(
                  width: responsive.responsiveValue(mobile: 16, tablet: 20)),
              Expanded(
                child: _buildStatItem(
                  responsive,
                  AppStrings.rating,
                  '4.5',
                  Icons.star,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          LinearProgressIndicator(
            value: 75 / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getActivityColor(75),
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 4, tablet: 6)),
          Text(
            '${AppStrings.activityLevel}: ${_getActivityLevel(75)}',
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ResponsiveController responsive,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: responsive.responsiveValue(mobile: 24, tablet: 28),
          color: Colors.blue,
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 20, tablet: 24),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getActivityLevel(int level) {
    if (level >= 80) return AppStrings.veryHigh;
    if (level >= 60) return AppStrings.high;
    if (level >= 40) return AppStrings.medium;
    if (level >= 20) return AppStrings.low;
    return AppStrings.veryLow;
  }

  Color _getActivityColor(int level) {
    if (level >= 80) return Colors.green;
    if (level >= 60) return Colors.lightGreen;
    if (level >= 40) return Colors.orange;
    if (level >= 20) return Colors.orange[300]!;
    return Colors.red;
  }
}

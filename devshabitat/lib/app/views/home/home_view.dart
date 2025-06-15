import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/home_controller.dart';
import 'widgets/profile_summary_card.dart';
import 'widgets/connections_overview_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/activity_feed_card.dart';
import 'widgets/github_stats_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1200) {
                return _buildDesktopLayout();
              } else if (constraints.maxWidth > 600) {
                return _buildTabletLayout();
              } else {
                return _buildMobileLayout();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              const ProfileSummaryCard(),
              SizedBox(height: 16.h),
              const QuickActionsCard(),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              const ActivityFeedCard(),
              SizedBox(height: 16.h),
              const GithubStatsCard(),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              const ConnectionsOverviewCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              flex: 3,
              child: ProfileSummaryCard(),
            ),
            SizedBox(width: 16.w),
            const Expanded(
              flex: 2,
              child: QuickActionsCard(),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            const Expanded(
              flex: 2,
              child: ConnectionsOverviewCard(),
            ),
            SizedBox(width: 16.w),
            const Expanded(
              flex: 3,
              child: GithubStatsCard(),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        const ActivityFeedCard(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const ProfileSummaryCard(),
          SizedBox(height: 16.h),
          const QuickActionsCard(),
          SizedBox(height: 16.h),
          const ConnectionsOverviewCard(),
          SizedBox(height: 16.h),
          const GithubStatsCard(),
          SizedBox(height: 16.h),
          const ActivityFeedCard(),
        ],
      ),
    );
  }
}

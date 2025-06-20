import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/responsive_controller.dart';
import '../base/base_view.dart';
import 'widgets/profile_summary_card.dart';
import 'widgets/connections_overview_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/activity_feed_card.dart';
import 'widgets/github_stats_card.dart';
import '../../widgets/loading_widget.dart';

class HomeView extends BaseView<HomeController> {
  const HomeView({super.key});

  @override
  Widget buildView(BuildContext context) {
    final ResponsiveController responsive = Get.find<ResponsiveController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ana Sayfa',
          style: TextStyle(fontSize: 20.sp),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, size: 24.sp),
            onPressed: () => Get.toNamed('/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.search, size: 24.sp),
            onPressed: () => Get.toNamed('/search'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const LoadingList();
            }

            if (controller.hasError.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      controller.errorMessage.value,
                      style: TextStyle(fontSize: 16.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: controller.loadData,
                      child: Text(
                        'Tekrar Dene',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1200.w) {
                  return _buildDesktopLayout();
                } else if (constraints.maxWidth > 600.w) {
                  return _buildTabletLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            );
          }),
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
              Obx(() {
                if (controller.items.isEmpty) {
                  return Center(
                    child: Text(
                      'Henüz içerik yok',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  );
                }
                return ActivityFeedCard(
                  feedItem: controller.items.first,
                  onLike: () => controller.onLike(controller.items.first),
                  onComment: () => controller.onComment(controller.items.first),
                  onShare: () => controller.onShare(controller.items.first),
                );
              }),
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
        Obx(() {
          if (controller.items.isEmpty) {
            return Center(
              child: Text(
                'Henüz içerik yok',
                style: TextStyle(fontSize: 16.sp),
              ),
            );
          }
          return ActivityFeedCard(
            feedItem: controller.items.first,
            onLike: () => controller.onLike(controller.items.first),
            onComment: () => controller.onComment(controller.items.first),
            onShare: () => controller.onShare(controller.items.first),
          );
        }),
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
          Obx(() {
            if (controller.items.isEmpty) {
              return Center(
                child: Text(
                  'Henüz içerik yok',
                  style: TextStyle(fontSize: 16.sp),
                ),
              );
            }
            return ActivityFeedCard(
              feedItem: controller.items.first,
              onLike: () => controller.onLike(controller.items.first),
              onComment: () => controller.onComment(controller.items.first),
              onShare: () => controller.onShare(controller.items.first),
            );
          }),
        ],
      ),
    );
  }
}

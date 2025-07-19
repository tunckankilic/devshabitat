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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ana Sayfa',
          style: TextStyle(
              fontSize: responsive.responsiveValue(
            mobile: 20.sp,
            tablet: 24.sp,
          )),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none,
                size: responsive.minTouchTarget.sp),
            onPressed: () => Get.toNamed('/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.search, size: responsive.minTouchTarget.sp),
            onPressed: () => Get.toNamed('/search'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: responsive.responsivePadding(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16,
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const LoadingList();
            }

            if (controller.hasError.value) {
              return _buildErrorState();
            }

            return Obx(() => _buildResponsiveLayout());
          }),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildResponsiveLayout() {
    if (responsive.isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const ProfileSummaryCard(),
                SizedBox(height: 16.h),
                const QuickActionsCard(),
                SizedBox(height: 16.h),
                const ConnectionsOverviewCard(),
              ],
            ),
          ),
          SizedBox(width: 24.w),
          // Right Column - Main Content
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Obx(() {
                  if (controller.items.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ActivityFeedCard(
                    feedItem: controller.items.first,
                    onLike: () => controller.onLike(controller.items.first),
                    onComment: () =>
                        controller.onComment(controller.items.first),
                    onShare: () => controller.onShare(controller.items.first),
                  );
                }),
                SizedBox(height: 16.h),
                const GithubStatsCard(),
              ],
            ),
          ),
        ],
      ),
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
              return _buildEmptyState();
            }
            return ActivityFeedCard(
              feedItem: controller.items.first,
              onLike: () => controller.onLike(controller.items.first),
              onComment: () => controller.onComment(controller.items.first),
              onShare: () => controller.onShare(controller.items.first),
            );
          }),
          // Add bottom padding for navigation
          SizedBox(
              height: responsive.responsiveValue(
            mobile: 100.h,
            tablet: 20.h,
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          Icon(
            Icons.explore_outlined,
            size: 48.sp,
            color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            'Henüz içerik yok',
            style: Theme.of(Get.context!).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Topluluklar ve etkinlikler keşfetmeye başlayın',
            style: Theme.of(Get.context!).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

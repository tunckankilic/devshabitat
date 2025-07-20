import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
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
            mobile: 20,
            tablet: 24,
          )),
        ),
        actions: [
          IconButton(
            icon:
                Icon(Icons.notifications_none, size: responsive.minTouchTarget),
            onPressed: () => Get.toNamed('/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.search, size: responsive.minTouchTarget),
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
            Icon(Icons.error_outline,
                size: responsive.responsiveValue(mobile: 48, tablet: 56),
                color: Colors.red),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
              textAlign: TextAlign.center,
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            ElevatedButton(
              onPressed: controller.loadData,
              child: Text(
                'Tekrar Dene',
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
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
                SizedBox(
                    height: responsive.responsiveValue(mobile: 16, tablet: 20)),
                const QuickActionsCard(),
                SizedBox(
                    height: responsive.responsiveValue(mobile: 16, tablet: 20)),
                const ConnectionsOverviewCard(),
              ],
            ),
          ),
          SizedBox(width: responsive.responsiveValue(mobile: 24, tablet: 32)),
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
                SizedBox(
                    height: responsive.responsiveValue(mobile: 16, tablet: 20)),
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
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
          const QuickActionsCard(),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
          const ConnectionsOverviewCard(),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
          const GithubStatsCard(),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
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
            mobile: 100,
            tablet: 20,
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: responsive.responsivePadding(all: 24),
      child: Column(
        children: [
          Icon(
            Icons.explore_outlined,
            size: responsive.responsiveValue(mobile: 48, tablet: 56),
            color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
          Text(
            'Henüz içerik yok',
            style: Theme.of(Get.context!).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
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

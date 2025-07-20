// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/feed_controller.dart';
import '../../models/feed_item.dart';
import '../../utils/performance_optimizer.dart';
import '../../widgets/paginated_list_view.dart';
import 'widgets/activity_feed_card.dart';

class FeedView extends StatelessWidget with PerformanceOptimizer {
  final FeedController controller = Get.find<FeedController>();

  FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return optimizeWidgetTree(
      Scaffold(
        appBar: AppBar(
          title: const Text('Feed'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.refreshFeed(),
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return PaginatedListView<FeedItem>(
      onFetch: controller.fetchFeedItems,
      itemBuilder: (item) => _buildFeedItem(item),
      loadingWidget: const Center(
        child: CircularProgressIndicator(),
      ),
      emptyWidget: const Center(
        child: Text('Henüz gönderi yok'),
      ),
      errorWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Feed yüklenirken bir hata oluştu'),
            ElevatedButton(
              onPressed: () => controller.refreshFeed(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedItem(FeedItem item) {
    return wrapWithRepaintBoundary(
      ActivityFeedCard(
        feedItem: item,
        onLike: () => controller.likeFeedItem(item.id),
        onComment: () => controller.commentOnFeedItem(item.id),
        onShare: () => controller.shareFeedItem(item.id),
      ),
    );
  }
}

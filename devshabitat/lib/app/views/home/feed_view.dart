import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/feed_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/post_card.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // For You butonu
              TextButton(
                onPressed: () => controller.changeFeedType(FeedType.forYou),
                child: Text(
                  'For You',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: controller.currentFeedType.value == FeedType.forYou
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Popular butonu
              TextButton(
                onPressed: () => controller.changeFeedType(FeedType.popular),
                child: Text(
                  'Popular',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: controller.currentFeedType.value == FeedType.popular
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          );
        }),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Etiket listesi
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTagChip('Flutter'),
                _buildTagChip('Firebase'),
                _buildTagChip('Mobile'),
                _buildTagChip('Web'),
                _buildTagChip('Backend'),
                _buildTagChip('UI/UX'),
              ],
            ),
          ),

          // Post listesi
          Expanded(
            child: Obx(() {
              final posts = controller.currentPosts;

              if (controller.isLoading.value) {
                return const LoadingList();
              }

              if (posts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.post_add_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz gösterilecek post yok',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.refreshPosts();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(
                      post: post,
                      onTap: () => Get.toNamed('/post-detail', arguments: post),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Obx(() {
      final isSelected = controller.selectedTag.value == tag;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (_) => controller.selectTag(tag),
          backgroundColor: Colors.grey[200],
          selectedColor: Theme.of(Get.context!).primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(Get.context!).primaryColor
                : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../../models/feed_item.dart';

class ItemDetailView extends GetView<HomeController> {
  const ItemDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedItem item = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detay'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null)
              Image.network(
                item.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Text(
              item.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.favorite,
                  label: '${item.likesCount} Beğeni',
                  isActive: item.isLiked,
                  onTap: () => controller.onLike(item),
                ),
                _buildStatItem(
                  icon: Icons.comment,
                  label: '${item.commentsCount} Yorum',
                  onTap: () => controller.onComment(item),
                ),
                _buildStatItem(
                  icon: Icons.share,
                  label: '${item.sharesCount} Paylaşım',
                  onTap: () => controller.onShare(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.red : null,
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

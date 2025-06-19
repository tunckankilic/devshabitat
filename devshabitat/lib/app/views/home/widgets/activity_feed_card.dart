import 'package:flutter/material.dart';
import '../../../models/feed_item.dart';
import '../../../services/asset_optimization_service.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeedCard extends StatelessWidget {
  final FeedItem feedItem;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final AssetOptimizationService _assetService = Get.find();

  ActivityFeedCard({
    super.key,
    required this.feedItem,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (feedItem.imageUrl != null) _buildImage(),
          _buildContent(context),
          _buildActions(context),
          _buildStats(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(feedItem.imageUrl ?? ''),
      ),
      title: Text(
        feedItem.userId,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        timeago.format(feedItem.createdAt, locale: 'tr'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          // Menü göster
        },
      ),
    );
  }

  Widget _buildImage() {
    return _assetService.getOptimizedNetworkImage(
      imageUrl: feedItem.imageUrl!,
      fit: BoxFit.cover,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        feedItem.content,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: feedItem.isLiked ? Icons.favorite : Icons.favorite_border,
          label: 'Beğen',
          onPressed: onLike,
          color: feedItem.isLiked ? Colors.red : null,
        ),
        _buildActionButton(
          icon: Icons.comment_outlined,
          label: 'Yorum Yap',
          onPressed: onComment,
        ),
        _buildActionButton(
          icon: Icons.share_outlined,
          label: 'Paylaş',
          onPressed: onShare,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatText(
            '${feedItem.likesCount} beğeni',
            context,
          ),
          const SizedBox(width: 16),
          _buildStatText(
            '${feedItem.commentsCount} yorum',
            context,
          ),
          const SizedBox(width: 16),
          _buildStatText(
            '${feedItem.sharesCount} paylaşım',
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildStatText(String text, BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

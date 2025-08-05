import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/blog_model.dart';
import '../responsive/responsive_wrapper.dart';

class BlogCard extends StatelessWidget {
  final BlogModel blog;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const BlogCard({
    super.key,
    required this.blog,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      mobile: _buildMobileCard(),
      tablet: _buildTabletCard(),
      desktop: _buildDesktopCard(),
    );
  }

  Widget _buildMobileCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with thumbnail
            if (blog.thumbnailUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                child: Image.network(
                  blog.thumbnailUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              ),
            _buildContent(isMobile: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail - sol taraf
            if (blog.thumbnailUrl != null)
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(4),
                  ),
                  child: Image.network(
                    blog.thumbnailUrl!,
                    height: 160,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 160,
                      width: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),
                ),
              ),
            // Content - sağ taraf
            Expanded(child: _buildContent(isMobile: false)),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail - sol taraf
            if (blog.thumbnailUrl != null)
              SizedBox(
                width: 280,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(4),
                  ),
                  child: Image.network(
                    blog.thumbnailUrl!,
                    height: 200,
                    width: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 200,
                      width: 280,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 64),
                    ),
                  ),
                ),
              ),
            // Content - sağ taraf
            Expanded(child: _buildContent(isMobile: false, isDesktop: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({bool isMobile = false, bool isDesktop = false}) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : (isDesktop ? 20 : 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            blog.title,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 16 : (isDesktop ? 20 : 18),
            ),
            maxLines: isMobile ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: isMobile ? 6 : 8),

          // Description
          Text(
            blog.description,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontSize: isMobile ? 13 : (isDesktop ? 15 : 14),
            ),
            maxLines: isMobile ? 2 : (isDesktop ? 4 : 3),
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: isMobile ? 8 : 12),

          // Tags
          Wrap(
            spacing: isMobile ? 6 : 8,
            children: blog.tags.take(isMobile ? 2 : 3).map((tag) {
              return Chip(
                label: Text(
                  tag,
                  style: TextStyle(fontSize: isMobile ? 10 : 12),
                ),
                backgroundColor: Get.theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: Get.theme.colorScheme.onPrimaryContainer,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),

          SizedBox(height: isMobile ? 8 : 12),

          // Author and stats
          Row(
            children: [
              CircleAvatar(
                radius: isMobile ? 14 : 16,
                backgroundImage: blog.authorPhotoUrl != null
                    ? NetworkImage(blog.authorPhotoUrl!)
                    : null,
                child: blog.authorPhotoUrl == null
                    ? Icon(Icons.person, size: isMobile ? 14 : 16)
                    : null,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.authorName,
                      style: Get.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: isMobile ? 12 : 13,
                      ),
                    ),
                    Text(
                      timeago.format(blog.createdAt, locale: 'tr'),
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: isMobile ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Stats
              if (!isMobile) ...[
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      blog.viewCount.toString(),
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.favorite, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      blog.likeCount.toString(),
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
              if (onDelete != null) ...[
                SizedBox(width: isMobile ? 4 : 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  iconSize: isMobile ? 18 : 20,
                ),
              ],
            ],
          ),
          // Mobile stats (ayrı satırda)
          if (isMobile) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.visibility, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  blog.viewCount.toString(),
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.favorite, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  blog.likeCount.toString(),
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  blog.estimatedReadingTime,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

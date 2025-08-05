import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/community/community_content_controller.dart';
import '../../models/community/content_model.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';

class CommunityContentFeedWidget extends StatelessWidget {
  final CommunityContentController controller;

  const CommunityContentFeedWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSafeArea(
      child: Column(
        children: [
          _buildContentTypeFilters(context),
          const SizedBox(height: 16),
          _buildNewContentButton(context),
          const SizedBox(height: 16),
          Expanded(child: _buildContentList(context)),
        ],
      ),
    );
  }

  Widget _buildContentTypeFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ContentType.values.map((type) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(_getContentTypeLabel(type)),
              selected: controller.selectedContentType.value == type,
              onSelected: (selected) {
                controller.selectedContentType.value = selected ? type : null;
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNewContentButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showNewContentDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('Yeni İçerik Ekle'),
    );
  }

  Widget _buildContentList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.contentItems.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        itemCount: controller.contentItems.length + 1,
        itemBuilder: (context, index) {
          if (index == controller.contentItems.length) {
            if (controller.hasMoreContent.value) {
              if (!controller.isLoadingMore.value) {
                controller.loadMoreContent();
              }
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final content = controller.contentItems[index];
          return _buildContentCard(context, content);
        },
      );
    });
  }

  Widget _buildContentCard(
    BuildContext context,
    CommunityContentModel content,
  ) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Card(
      margin: responsive.responsivePadding(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getContentTypeIcon(content.type),
                  size: performanceService.getOptimizedIconSize(
                    cacheKey: 'content_type_icon',
                    mobileSize: 24,
                    tabletSize: 28,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResponsiveText(
                    content.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: performanceService.getOptimizedTextSize(
                        cacheKey: 'content_title',
                        mobileSize: 16,
                        tabletSize: 18,
                      ),
                    ),
                  ),
                ),
                if (controller.canModerateContent())
                  AdaptiveTouchTarget(
                    onTap: () => _showModerateContentDialog(context, content),
                    child: const Icon(Icons.more_vert),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ResponsiveText(
              content.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'content_body',
                  mobileSize: 14,
                  tabletSize: 16,
                ),
              ),
            ),
            if (content.url != null || content.githubRepo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (content.url != null)
                      TextButton.icon(
                        onPressed: () {
                          if (content.url != null) {
                            launchUrl(Uri.parse(content.url!));
                          }
                        },
                        icon: const Icon(Icons.link),
                        label: const Text('Bağlantıya Git'),
                      ),
                    if (content.githubRepo != null)
                      TextButton.icon(
                        onPressed: () {
                          if (content.githubRepo != null) {
                            launchUrl(
                              Uri.parse(
                                'https://github.com/${content.githubRepo}',
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.code),
                        label: const Text('GitHub'),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Obx(() {
                  final isLiked = content.likedBy.contains(
                    Get.find<String>(), // Current user ID
                  );
                  return IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null,
                    ),
                    onPressed: () {
                      if (isLiked) {
                        controller.unlikeContent(content.id);
                      } else {
                        controller.likeContent(content.id);
                      }
                    },
                  );
                }),
                Text(content.likedBy.length.toString()),
                const Spacer(),
                Text(
                  _formatDate(content.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNewContentDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String content = '';
    ContentType type = ContentType.blogPost;
    String? url;
    String? githubRepo;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni İçerik Ekle'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ContentType>(
                  value: type,
                  onChanged: (value) => type = value!,
                  items: ContentType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getContentTypeLabel(type)),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'İçerik Türü'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Başlık'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Başlık gereklidir';
                    }
                    return null;
                  },
                  onSaved: (value) => title = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'İçerik'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'İçerik gereklidir';
                    }
                    return null;
                  },
                  onSaved: (value) => content = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'URL (İsteğe bağlı)',
                  ),
                  onSaved: (value) => url = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'GitHub Repo (İsteğe bağlı)',
                  ),
                  onSaved: (value) => githubRepo = value,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                controller.submitContent(
                  title: title,
                  content: content,
                  type: type,
                  url: url,
                  githubRepo: githubRepo,
                );
                Get.back();
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _showModerateContentDialog(
    BuildContext context,
    CommunityContentModel content,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İçerik Yönetimi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('İçeriği Sil'),
              onTap: () {
                controller.deleteContent(content.id);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('İçeriği Raporla'),
              onTap: () {
                Get.back();
                _showReportDialog(context, content);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getContentTypeLabel(ContentType type) {
    switch (type) {
      case ContentType.blogPost:
        return 'Blog Yazısı';
      case ContentType.githubProject:
        return 'GitHub Projesi';
      case ContentType.event:
        return 'Etkinlik';
      case ContentType.resource:
        return 'Kaynak';
      case ContentType.achievement:
        return 'Başarı';
    }
  }

  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.blogPost:
        return Icons.article;
      case ContentType.githubProject:
        return Icons.code;
      case ContentType.event:
        return Icons.event;
      case ContentType.resource:
        return Icons.library_books;
      case ContentType.achievement:
        return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReportDialog(BuildContext context, CommunityContentModel content) {
    final formKey = GlobalKey<FormState>();
    String reason = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İçeriği Raporla'),
        content: Form(
          key: formKey,
          child: TextFormField(
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Raporlama Nedeni',
              hintText: 'Lütfen raporlama nedeninizi açıklayın',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Raporlama nedeni gereklidir';
              }
              return null;
            },
            onSaved: (value) => reason = value!,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                controller.reportContent(content.id, reason);
                Get.back();
              }
            },
            child: const Text('Raporla'),
          ),
        ],
      ),
    );
  }
}

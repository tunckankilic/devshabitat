import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/blog_controller.dart';
import '../../models/blog_model.dart';
import 'blog_detail_view.dart';
import 'new_blog_view.dart';

class BlogListView extends GetView<BlogController> {
  const BlogListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Yazıları'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Get.to(() => const NewBlogView()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadUserBlogs,
        child: Obx(() {
          if (controller.isLoadingBlogs.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.blogsError.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Hata',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.blogsError.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadUserBlogs,
                    child: Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (controller.blogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz blog yazısı yok',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk blog yazınızı oluşturmak için + butonuna tıklayın',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const NewBlogView()),
                    icon: Icon(Icons.add),
                    label: Text('İlk Blog Yazısını Oluştur'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.blogs.length,
            itemBuilder: (context, index) {
              final blogData = controller.blogs[index];
              final blog = BlogModel.fromMap(blogData);
              return _buildBlogCard(context, blog);
            },
          );
        }),
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, BlogModel blog) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => Get.to(() => BlogDetailView(blog: blog)),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category and Status
                        Row(
                          children: [
                            Chip(
                              label: Text(blog.category),
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (blog.status == 'draft') ...[
                              Chip(
                                label: Text('Taslak'),
                                backgroundColor: Colors.orange.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (blog.codeSnippets.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Chip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.code,
                                        size: 14, color: Colors.purple),
                                    const SizedBox(width: 4),
                                    Text('${blog.codeSnippets.length}'),
                                  ],
                                ),
                                backgroundColor: Colors.purple.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, blog);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('Sil'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                blog.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                blog.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Tags
              if (blog.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: blog.tags
                      .take(3)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Footer
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(blog.publishedAt ?? blog.createdAt),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    blog.estimatedReadingTime,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text('${blog.likeCount}', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.visibility, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${blog.viewCount}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, BlogModel blog) {
    Get.dialog(
      AlertDialog(
        title: Text('Blog Yazısını Sil'),
        content: Text(
            'Bu blog yazısını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteBlogPost(blog.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Sil'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

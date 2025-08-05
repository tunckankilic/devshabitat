import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/blog_controller.dart';
import '../../models/blog_model.dart';
import '../../widgets/blog/blog_card.dart';
import '../../widgets/blog/blog_search_bar.dart';
import 'blog_detail_view.dart';
import 'new_blog_view.dart';

class BlogListView extends GetView<BlogController> {
  const BlogListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Yazıları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const NewBlogView()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Obx(
            () => BlogSearchBar(
              controller: TextEditingController(
                text: controller.searchQuery.value,
              ),
              onSearch: (query) => controller.searchQuery.value = query,
              categories: controller.availableCategories,
              selectedCategory: controller.selectedCategory.value,
              onCategoryChanged: (category) =>
                  controller.selectedCategory.value = category ?? '',
              isLoading: controller.isLoadingBlogs.value,
            ),
          ),

          // Blog List
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshBlogs,
              child: Obx(() {
                if (controller.isLoadingBlogs.value &&
                    controller.blogs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.blogsError.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Hata',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.blogsError.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.refreshBlogs,
                          child: const Text('Tekrar Dene'),
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
                        const Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Henüz blog yazısı yok',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                          icon: const Icon(Icons.add),
                          label: const Text('İlk Blog Yazısını Oluştur'),
                        ),
                      ],
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      if (controller.hasMoreBlogs.value &&
                          !controller.isLoadingBlogs.value) {
                        controller.loadMoreBlogs();
                      }
                    }
                    return true;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        controller.blogs.length +
                        (controller.hasMoreBlogs.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.blogs.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final blog = controller.blogs[index];
                      return BlogCard(
                        blog: blog,
                        onTap: () => Get.to(() => BlogDetailView(blog: blog)),
                        onDelete: () => controller.deleteBlogPost(blog.id),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const NewBlogView()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

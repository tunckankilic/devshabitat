import 'package:flutter/material.dart';
import '../../models/blog_model.dart';
import '../../models/user_profile_model.dart';
import '../blog/blog_preview_card.dart';
import '../github/repository_preview_card.dart';

class ContentPortfolioWidget extends StatelessWidget {
  final UserProfile developer;
  final List<BlogModel> blogs;
  final List<dynamic> repositories;
  final Function(String) onBlogTap;
  final Function(String) onRepoTap;
  final Function() onViewAllContent;

  const ContentPortfolioWidget({
    Key? key,
    required this.developer,
    required this.blogs,
    required this.repositories,
    required this.onBlogTap,
    required this.onRepoTap,
    required this.onViewAllContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve İstatistikler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İçerik Portföyü',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: onViewAllContent,
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildStatistics(),
            const Divider(),

            // Blog Yazıları
            if (blogs.isNotEmpty) ...[
              Text(
                'Blog Yazıları',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: blogs.length.clamp(0, 3),
                  itemBuilder: (context, index) => SizedBox(
                    width: 300,
                    child: BlogPreviewCard(
                      blog: blogs[index],
                      onTap: () => onBlogTap(blogs[index].id.toString()),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // GitHub Projeleri
            if (repositories.isNotEmpty) ...[
              Text(
                'GitHub Projeleri',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: repositories.length.clamp(0, 3),
                  itemBuilder: (context, index) => SizedBox(
                    width: 280,
                    child: RepositoryPreviewCard(
                      repository: repositories[index],
                      onTap: () => onRepoTap(repositories[index].name),
                    ),
                  ),
                ),
              ),
            ],

            // İçerik Etiketleri
            const SizedBox(height: 16),
            _buildContentTags(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.article,
          label: 'Blog Yazıları',
          value: blogs.length.toString(),
        ),
        _buildStatItem(
          icon: Icons.code,
          label: 'Projeler',
          value: repositories.length.toString(),
        ),
        _buildStatItem(
          icon: Icons.remove_red_eye,
          label: 'Toplam Görüntülenme',
          value: _calculateTotalViews().toString(),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildContentTags() {
    final allTags = <String>{
      ...blogs.expand((blog) => blog.tags),
      ...repositories.expand((repo) => repo.topics ?? []),
    }.take(10).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: allTags.map((tag) {
        return Chip(label: Text(tag), backgroundColor: Colors.grey[200]);
      }).toList(),
    );
  }

  int _calculateTotalViews() {
    return blogs.fold<int>(0, (sum, blog) => sum + blog.viewCount);
  }
}

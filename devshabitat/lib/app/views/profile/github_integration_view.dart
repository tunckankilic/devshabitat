import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/github_content_controller.dart';
import '../../widgets/github/repository_showcase_widget.dart';

import '../../widgets/responsive/responsive_text.dart';

class GithubIntegrationView extends StatelessWidget {
  final _controller = Get.find<GitHubContentController>();

  GithubIntegrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _controller.loadInitialRepositories(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGitHubStats(context),
                    SizedBox(height: 24),
                    _buildRepositorySection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateContentDialog(context),
        icon: Icon(Icons.add),
        label: Text('İçerik Oluştur'),
      ),
    );
  }

  Widget _buildGitHubStats(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.blue),
                SizedBox(width: 12),
                ResponsiveText(
                  'GitHub İstatistikleri',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            Obx(() {
              if (_controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              return GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Repolar',
                    '${_controller.repositories.length}',
                    Icons.folder_outlined,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Katkılar',
                    '${_controller.contributionCount}',
                    Icons.commit_outlined,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'İşbirlikleri',
                    '${_controller.collaborationCount}',
                    Icons.people_outline,
                    Colors.purple,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          ResponsiveText(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          ResponsiveText(
            title,
            style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRepositorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.book_outlined, color: Colors.grey[800]),
            SizedBox(width: 12),
            ResponsiveText(
              'GitHub Projeleri',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 16),
        Obx(() {
          if (_controller.isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (_controller.repositories.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_off_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    ResponsiveText(
                      'Henüz repo bulunamadı',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _controller.repositories.length,
            separatorBuilder: (context, index) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              final repo = _controller.repositories[index];
              return RepositoryShowcaseWidget(repository: repo);
            },
          );
        }),
      ],
    );
  }

  void _showCreateContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İçerik Türü Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.article_outlined),
              title: Text('Blog Yazısı'),
              subtitle: Text('Repository\'den blog yazısı oluştur'),
              onTap: () {
                Navigator.pop(context);
                _createBlogPost(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.school_outlined),
              title: Text('Öğretici'),
              subtitle: Text('Repository\'den öğretici içerik oluştur'),
              onTap: () {
                Navigator.pop(context);
                _createTutorial(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people_outline),
              title: Text('İşbirliği'),
              subtitle: Text('Repository için işbirliği isteği oluştur'),
              onTap: () {
                Navigator.pop(context);
                _createCollaboration(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createBlogPost(BuildContext context) {
    final selectedRepo = _controller.repositories.firstWhereOrNull(
      (repo) => repo.hasReadme && !repo.isPrivate,
    );

    if (selectedRepo == null) {
      Get.snackbar(
        'Hata',
        'Uygun repository bulunamadı. README dosyası olan public bir repo seçin.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      '/blog/create',
      arguments: {
        'repoId': selectedRepo.id,
        'repoName': selectedRepo.name,
        'repoDescription': selectedRepo.description,
      },
    );
  }

  void _createTutorial(BuildContext context) {
    final selectedRepo = _controller.repositories.firstWhereOrNull(
      (repo) => repo.hasReadme && repo.languages.isNotEmpty,
    );

    if (selectedRepo == null) {
      Get.snackbar(
        'Hata',
        'Uygun repository bulunamadı. README ve kod örnekleri olan bir repo seçin.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      '/tutorials/create',
      arguments: {
        'repoId': selectedRepo.id,
        'repoName': selectedRepo.name,
        'languages': selectedRepo.languages,
        'description': selectedRepo.description,
      },
    );
  }

  void _createCollaboration(BuildContext context) {
    final selectedRepo = _controller.repositories.firstWhereOrNull(
      (repo) => !repo.isPrivate,
    );

    if (selectedRepo == null) {
      Get.snackbar(
        'Hata',
        'Public bir repository seçin.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      '/collaborations/create',
      arguments: {
        'repoId': selectedRepo.id,
        'repoName': selectedRepo.name,
        'owner': selectedRepo.owner,
        'topics': selectedRepo.topics,
      },
    );
  }
}

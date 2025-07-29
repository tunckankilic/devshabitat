import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/github_integration_controller.dart';
import '../base/base_view.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/animated_responsive_layout.dart';
import 'widgets/github_repository_showcase.dart';
import 'widgets/contribution_graph_widget.dart';
import 'widgets/portfolio_integration_widget.dart';

class GithubIntegrationView extends BaseView<GithubIntegrationController> {
  const GithubIntegrationView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'GitHub Entegrasyonu',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 16),
                ResponsiveText(
                  'GitHub verileri yükleniyor...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return AnimatedResponsiveLayout(
          mobile: _buildMobileLayout(context),
          tablet: _buildTabletLayout(context),
          animationDuration: const Duration(milliseconds: 300),
        );
      }),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.loadGithubStats(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildConnectionCard(context),
            SizedBox(height: 16),
            if (controller.isConnected) ...[
              _buildStatsCard(context),
              SizedBox(height: 16),
              _buildContributionGraph(context),
              SizedBox(height: 16),
              _buildRepositoryShowcase(context),
              SizedBox(height: 16),
              _buildPortfolioIntegration(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.loadGithubStats(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _buildConnectionCard(context),
            SizedBox(height: 24),
            if (controller.isConnected) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildStatsCard(context),
                        SizedBox(height: 24),
                        _buildContributionGraph(context),
                      ],
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildRepositoryShowcase(context),
                        SizedBox(height: 24),
                        _buildPortfolioIntegration(context),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[800]!,
                    Colors.grey[700]!,
                  ],
                ),
              ),
              child: Icon(
                Icons.code,
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            ResponsiveText(
              controller.isConnected ? 'GitHub Bağlı' : 'GitHub Bağlantısı',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            ResponsiveText(
              controller.isConnected
                  ? 'GitHub hesabınız başarıyla bağlandı'
                  : 'GitHub hesabınızı bağlayarak projelerinizi sergileyin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            if (controller.isConnected)
              ElevatedButton.icon(
                onPressed: () => controller.disconnectGithub(),
                icon: Icon(Icons.link_off),
                label: ResponsiveText('Bağlantıyı Kes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => controller.connectGithub(),
                icon: Icon(Icons.link),
                label: ResponsiveText('GitHub Bağla'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            if (controller.error.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: ResponsiveText(
                        controller.error,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final stats = controller.githubStats;
    if (stats == null) return SizedBox.shrink();

    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[800]!,
              Colors.grey[700]!,
            ],
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: stats.avatarUrl != null
                      ? CachedNetworkImageProvider(stats.avatarUrl!)
                      : null,
                  child: stats.avatarUrl == null
                      ? Icon(Icons.person, color: Colors.grey[600])
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveText(
                        stats.username,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (stats.bio != null) ...[
                        SizedBox(height: 4),
                        ResponsiveText(
                          stats.bio!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Repositories',
                  stats.totalRepositories.toString(),
                  Icons.folder_outlined,
                ),
                _buildStatItem(
                  context,
                  'Followers',
                  stats.followers.toString(),
                  Icons.people_outline,
                ),
                _buildStatItem(
                  context,
                  'Following',
                  stats.following.toString(),
                  Icons.person_add_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        ResponsiveText(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        ResponsiveText(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _buildContributionGraph(BuildContext context) {
    final stats = controller.githubStats;
    if (stats == null) return SizedBox.shrink();

    return ContributionGraphWidget(
      contributionData: stats.contributionGraph,
      username: stats.username,
    );
  }

  Widget _buildRepositoryShowcase(BuildContext context) {
    final stats = controller.githubStats;
    if (stats == null) return SizedBox.shrink();

    return GithubRepositoryShowcase(
      repositories: stats.recentRepositories,
      onRefresh: () => controller.loadGithubStats(),
      isLoading: controller.isLoading,
    );
  }

  Widget _buildPortfolioIntegration(BuildContext context) {
    return PortfolioIntegrationWidget(
      onIntegrate: () => controller.verifyGithubProfile(),
      isIntegrated: controller.isConnected,
      isLoading: controller.isLoading,
    );
  }
}

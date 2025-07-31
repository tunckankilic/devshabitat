import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../controllers/registration_controller.dart';

class GithubStatsCard extends GetView<HomeController> {
  const GithubStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(
            mobile: 16,
            tablet: 20,
          ),
        ),
      ),
      child: Padding(
        padding: responsive.responsivePadding(
          all: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.code,
                      size: responsive.responsiveValue(
                        mobile: 24,
                        tablet: 28,
                      ),
                      color: Colors.black87,
                    ),
                    SizedBox(
                        width:
                            responsive.responsiveValue(mobile: 8, tablet: 12)),
                    Text(
                      'GitHub İstatistikleri',
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 18,
                          tablet: 22,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // GitHub verilerini güncelle butonu
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: responsive.responsiveValue(
                          mobile: 20,
                          tablet: 24,
                        ),
                      ),
                      onPressed: () => _updateGithubData(),
                      tooltip: 'GitHub verilerini güncelle',
                    ),
                    // GitHub profiline git butonu
                    IconButton(
                      icon: Icon(
                        Icons.open_in_new,
                        size: responsive.responsiveValue(
                          mobile: 20,
                          tablet: 24,
                        ),
                      ),
                      onPressed: () => _openGithubProfile(),
                      tooltip: 'GitHub profilini aç',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final stats = controller.githubStats;
              if (stats.isEmpty) {
                return _buildNoGithubData();
              }

              return Column(
                children: [
                  // Ana istatistikler
                  _buildMainStats(stats),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                  // Dil istatistikleri
                  _buildLanguageStats(stats),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                  // Son aktiviteler
                  _buildRecentActivity(stats),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNoGithubData() {
    final responsive = Get.find<ResponsiveController>();

    return Container(
      padding: responsive.responsivePadding(all: 20),
      child: Column(
        children: [
          Icon(
            Icons.code_off,
            size: responsive.responsiveValue(mobile: 48, tablet: 56),
            color: Colors.grey[400],
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 12, tablet: 16)),
          Text(
            'GitHub verisi bulunamadı',
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Text(
            'GitHub hesabınızı bağlayarak istatistiklerinizi görebilirsiniz',
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
          ElevatedButton.icon(
            onPressed: () => _connectGithub(),
            icon: Icon(Icons.link),
            label: Text('GitHub Bağla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStats(Map<String, dynamic> stats) {
    final responsive = Get.find<ResponsiveController>();
    final githubStats = stats['stats'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genel İstatistikler',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 12, tablet: 16)),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Repositories',
                githubStats?['totalRepositories']?.toString() ?? '0',
                Icons.folder,
                Colors.blue,
              ),
            ),
            SizedBox(width: responsive.responsiveValue(mobile: 8, tablet: 12)),
            Expanded(
              child: _buildStatCard(
                'Followers',
                githubStats?['followers']?.toString() ?? '0',
                Icons.people,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Following',
                githubStats?['following']?.toString() ?? '0',
                Icons.person_add,
                Colors.orange,
              ),
            ),
            SizedBox(width: responsive.responsiveValue(mobile: 8, tablet: 12)),
            Expanded(
              child: _buildStatCard(
                'Contributions',
                githubStats?['totalContributions']?.toString() ?? '0',
                Icons.trending_up,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageStats(Map<String, dynamic> stats) {
    final responsive = Get.find<ResponsiveController>();
    final githubStats = stats['stats'];
    final languageStats = githubStats?['languageStats'] as Map<String, int>?;

    if (languageStats == null || languageStats.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'En Çok Kullanılan Diller',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 12, tablet: 16)),
        ...languageStats.entries
            .take(5)
            .map((entry) => _buildLanguageRow(entry.key, entry.value))
            .toList(),
      ],
    );
  }

  Widget _buildRecentActivity(Map<String, dynamic> stats) {
    final responsive = Get.find<ResponsiveController>();
    final activities = stats['activities'] as List?;

    if (activities == null || activities.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Aktiviteler',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 12, tablet: 16)),
        ...activities.take(3).map((activity) => _buildActivityRow(activity)),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    final responsive = Get.find<ResponsiveController>();

    return Container(
      padding: responsive.responsivePadding(all: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(mobile: 8, tablet: 12),
        ),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon,
              color: color,
              size: responsive.responsiveValue(mobile: 24, tablet: 28)),
          SizedBox(height: responsive.responsiveValue(mobile: 4, tablet: 8)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRow(String language, int count) {
    final responsive = Get.find<ResponsiveController>();

    return Container(
      margin: EdgeInsets.only(
          bottom: responsive.responsiveValue(mobile: 4, tablet: 8)),
      padding: responsive.responsivePadding(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(mobile: 6, tablet: 8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: responsive.responsiveValue(mobile: 12, tablet: 16),
            height: responsive.responsiveValue(mobile: 12, tablet: 16),
            decoration: BoxDecoration(
              color: _getLanguageColor(language),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Expanded(
            child: Text(
              language,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$count repo',
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(Map<String, dynamic> activity) {
    final responsive = Get.find<ResponsiveController>();

    return Container(
      margin: EdgeInsets.only(
          bottom: responsive.responsiveValue(mobile: 4, tablet: 8)),
      padding: responsive.responsivePadding(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(mobile: 6, tablet: 8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getActivityIcon(activity['type']),
            size: responsive.responsiveValue(mobile: 16, tablet: 20),
            color: Colors.grey[600],
          ),
          SizedBox(width: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Expanded(
            child: Text(
              activity['description'] ?? 'Aktivite',
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLanguageColor(String language) {
    final colors = {
      'JavaScript': Colors.yellow[700]!,
      'TypeScript': Colors.blue[700]!,
      'Python': Colors.blue[500]!,
      'Java': Colors.orange[600]!,
      'C++': Colors.pink[600]!,
      'C#': Colors.purple[600]!,
      'PHP': Colors.purple[500]!,
      'Ruby': Colors.red[600]!,
      'Go': Colors.cyan[600]!,
      'Rust': Colors.orange[800]!,
      'Swift': Colors.orange[500]!,
      'Kotlin': Colors.purple[700]!,
      'Dart': Colors.blue[400]!,
      'HTML': Colors.orange[500]!,
      'CSS': Colors.blue[600]!,
    };

    return colors[language] ?? Colors.grey[600]!;
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'PushEvent':
        return Icons.push_pin;
      case 'CreateEvent':
        return Icons.create;
      case 'PullRequestEvent':
        return Icons.merge;
      case 'IssuesEvent':
        return Icons.bug_report;
      case 'ForkEvent':
        return Icons.fork_right;
      default:
        return Icons.code;
    }
  }

  void _updateGithubData() async {
    try {
      final registrationController = Get.find<RegistrationController>();
      await registrationController.updateGithubData();
      await controller.refreshData();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'GitHub verileri güncellenirken bir hata oluştu',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _openGithubProfile() async {
    try {
      final username = await controller.getGithubUsername();
      if (username != null && username.isNotEmpty) {
        final url = 'https://github.com/$username';
        // URL'yi açmak için url_launcher kullanılabilir
        Get.snackbar(
          'GitHub Profili',
          'Profil: $url',
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'GitHub profili açılırken bir hata oluştu',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _connectGithub() {
    Get.toNamed('/register');
  }
}

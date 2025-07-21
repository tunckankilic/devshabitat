import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/networking_controller.dart';
import '../../controllers/responsive_controller.dart';

class ProfessionalToolsScreen extends StatelessWidget {
  final NetworkingController controller = Get.find<NetworkingController>();

  ProfessionalToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.professionalTools,
            style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20))),
      ),
      body: ListView(
        padding: responsive.responsivePadding(all: 16),
        children: [
          _buildSection(
            AppStrings.profileTools,
            [
              _buildToolCard(
                AppStrings.profileAnalysis,
                AppStrings.analyzeYourProfile,
                Icons.analytics,
                () => _showAnalyticsDetails(responsive),
                responsive,
              ),
              SizedBox(
                  height: responsive.responsiveValue(mobile: 8, tablet: 12)),
              _buildToolCard(
                AppStrings.seoOptimization,
                AppStrings.improveYourSearchResults,
                Icons.search,
                () => _showSkillGapAnalysis(responsive),
                responsive,
              ),
              SizedBox(
                  height: responsive.responsiveValue(mobile: 8, tablet: 12)),
              _buildToolCard(
                AppStrings.dataExport,
                AppStrings.exportYourData,
                Icons.download,
                () => _showExportOptions(responsive),
                responsive,
              ),
            ],
            responsive,
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
          _buildSection(
            AppStrings.connectionTools,
            [
              _buildToolCard(
                AppStrings.connectionManager,
                AppStrings.organizeYourConnections,
                Icons.people,
                () {},
                responsive,
              ),
              SizedBox(
                  height: responsive.responsiveValue(mobile: 8, tablet: 12)),
              _buildToolCard(
                AppStrings.contentSharing,
                AppStrings.shareYourContent,
                Icons.share,
                () {},
                responsive,
              ),
            ],
            responsive,
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
          _buildSection(
            AppStrings.statistics,
            [
              _buildStatCard(
                AppStrings.profileViews,
                '1.2K',
                '+15%',
                Icons.visibility,
                responsive,
              ),
              SizedBox(
                  height: responsive.responsiveValue(mobile: 8, tablet: 12)),
              _buildStatCard(
                AppStrings.interactionRate,
                '%78',
                '+5%',
                Icons.trending_up,
                responsive,
              ),
            ],
            responsive,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, List<Widget> children, ResponsiveController responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 20, tablet: 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
        ...children,
      ],
    );
  }

  Widget _buildToolCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
    ResponsiveController responsive,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: responsive.responsivePadding(all: 16),
          child: Row(
            children: [
              Icon(icon,
                  size: responsive.responsiveValue(mobile: 32, tablet: 40)),
              SizedBox(
                  width: responsive.responsiveValue(mobile: 16, tablet: 20)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize:
                            responsive.responsiveValue(mobile: 18, tablet: 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height:
                            responsive.responsiveValue(mobile: 4, tablet: 6)),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize:
                            responsive.responsiveValue(mobile: 14, tablet: 16),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String trend,
    IconData icon,
    ResponsiveController responsive,
  ) {
    final isPositive = trend.startsWith('+');
    return Card(
      child: Padding(
        padding: responsive.responsivePadding(all: 16),
        child: Row(
          children: [
            Icon(icon,
                size: responsive.responsiveValue(mobile: 32, tablet: 40)),
            SizedBox(width: responsive.responsiveValue(mobile: 16, tablet: 20)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18),
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(
                      height: responsive.responsiveValue(mobile: 4, tablet: 6)),
                  Row(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                              mobile: 24, tablet: 28),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                          width: responsive.responsiveValue(
                              mobile: 8, tablet: 12)),
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size:
                            responsive.responsiveValue(mobile: 16, tablet: 20),
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                              mobile: 14, tablet: 16),
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(ResponsiveController responsive) {
    Get.bottomSheet(
      Container(
        padding: responsive.responsivePadding(all: 16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                responsive.responsiveValue(mobile: 16, tablet: 20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.dataExport,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            ListTile(
              leading: Icon(Icons.picture_as_pdf,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.exportAsPdf,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              onTap: () {
                Get.back();
                _exportData('pdf', responsive);
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.exportAsCsv,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              onTap: () {
                Get.back();
                _exportData('csv', responsive);
              },
            ),
            ListTile(
              leading: Icon(Icons.code,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.exportAsJson,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              onTap: () {
                Get.back();
                _exportData('json', responsive);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportData(String format, ResponsiveController responsive) {
    Get.snackbar(
      AppStrings.dataExport,
      '${AppStrings.exportingData} $format',
      snackPosition: SnackPosition.BOTTOM,
      margin: responsive.responsivePadding(all: 16),
      borderRadius: responsive.responsiveValue(mobile: 8, tablet: 12),
      duration: const Duration(seconds: 2),
    );
  }

  void _showAnalyticsDetails(ResponsiveController responsive) {
    Get.bottomSheet(
      Container(
        padding: responsive.responsivePadding(all: 16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                responsive.responsiveValue(mobile: 16, tablet: 20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.detailedAnalysis,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            _buildAnalyticItem(
              AppStrings.profileViews,
              '1.2K',
              '+15%',
              Icons.visibility,
              responsive,
            ),
            SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
            _buildAnalyticItem(
              AppStrings.interactionRate,
              '%78',
              '+5%',
              Icons.trending_up,
              responsive,
            ),
            SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
            _buildAnalyticItem(
              AppStrings.connectionGrowth,
              '45',
              '+8%',
              Icons.people,
              responsive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticItem(
    String title,
    String value,
    String trend,
    IconData icon,
    ResponsiveController responsive,
  ) {
    final isPositive = trend.startsWith('+');
    return ListTile(
      leading:
          Icon(icon, size: responsive.responsiveValue(mobile: 24, tablet: 28)),
      title: Text(
        title,
        style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: responsive.responsiveValue(mobile: 16, tablet: 20),
            color: isPositive ? Colors.green : Colors.red,
          ),
          Text(
            trend,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showSkillGapAnalysis(ResponsiveController responsive) {
    Get.bottomSheet(
      Container(
        padding: responsive.responsivePadding(all: 16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                responsive.responsiveValue(mobile: 16, tablet: 20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.skillAnalysis,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            _buildSkillBar('Flutter', 85, Colors.blue, responsive),
            SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
            _buildSkillBar('Dart', 80, Colors.green, responsive),
            SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
            _buildSkillBar('Firebase', 75, Colors.orange, responsive),
            SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
            _buildSkillBar('UI/UX', 70, Colors.purple, responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillBar(String skill, double percentage, Color color,
      ResponsiveController responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skill,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 14, tablet: 16)),
            ),
            Text(
              '${percentage.toInt()}%',
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 14, tablet: 16)),
            ),
          ],
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 4, tablet: 6)),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: responsive.responsiveValue(mobile: 8, tablet: 10),
          borderRadius: BorderRadius.circular(
              responsive.responsiveValue(mobile: 4, tablet: 6)),
        ),
      ],
    );
  }
}

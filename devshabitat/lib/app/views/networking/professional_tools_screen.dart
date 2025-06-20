import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/networking_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfessionalToolsScreen extends StatelessWidget {
  final NetworkingController controller = Get.find<NetworkingController>();

  ProfessionalToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profesyonel Araçlar', style: TextStyle(fontSize: 18.sp)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          _buildSection(
            'Profil Araçları',
            [
              _buildToolCard(
                'Profil Analizi',
                'Profilinizin performansını analiz edin',
                Icons.analytics,
                () {},
              ),
              SizedBox(height: 8.h),
              _buildToolCard(
                'SEO Optimizasyonu',
                'Profilinizi arama sonuçlarında öne çıkarın',
                Icons.search,
                () {},
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildSection(
            'Bağlantı Araçları',
            [
              _buildToolCard(
                'Bağlantı Yöneticisi',
                'Bağlantılarınızı organize edin',
                Icons.people,
                () {},
              ),
              SizedBox(height: 8.h),
              _buildToolCard(
                'İçerik Paylaşımı',
                'Bağlantılarınızla içerik paylaşın',
                Icons.share,
                () {},
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildSection(
            'İstatistikler',
            [
              _buildStatCard(
                'Profil Görüntülenme',
                '1.2K',
                '+15%',
                Icons.visibility,
              ),
              SizedBox(height: 8.h),
              _buildStatCard(
                'Etkileşim Oranı',
                '%78',
                '+5%',
                Icons.trending_up,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        ...children,
      ],
    );
  }

  Widget _buildToolCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Icon(icon, size: 32.sp),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 24.sp),
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
  ) {
    final isPositive = trend.startsWith('+');
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Icon(icon, size: 32.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16.sp,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 14.sp,
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

  void _showExportOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Veri Dışa Aktarma',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, size: 24.sp),
              title: Text(
                'PDF Olarak Dışa Aktar',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                _exportData('pdf');
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, size: 24.sp),
              title: Text(
                'CSV Olarak Dışa Aktar',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                _exportData('csv');
              },
            ),
            ListTile(
              leading: Icon(Icons.code, size: 24.sp),
              title: Text(
                'JSON Olarak Dışa Aktar',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                _exportData('json');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportData(String format) {
    Get.snackbar(
      'Dışa Aktarma',
      'Veriler $format formatında dışa aktarılıyor...',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16.r),
      borderRadius: 8.r,
      duration: const Duration(seconds: 2),
    );
  }

  void _showAnalyticsDetails() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Detaylı Analiz',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildAnalyticItem(
              'Profil Görüntülenme',
              '1.2K',
              '+15%',
              Icons.visibility,
            ),
            SizedBox(height: 8.h),
            _buildAnalyticItem(
              'Etkileşim Oranı',
              '%78',
              '+5%',
              Icons.trending_up,
            ),
            SizedBox(height: 8.h),
            _buildAnalyticItem(
              'Bağlantı Artışı',
              '45',
              '+8%',
              Icons.people,
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
  ) {
    final isPositive = trend.startsWith('+');
    return ListTile(
      leading: Icon(icon, size: 24.sp),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16.sp,
            color: isPositive ? Colors.green : Colors.red,
          ),
          Text(
            trend,
            style: TextStyle(
              fontSize: 14.sp,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showSkillGapAnalysis() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Yetenek Analizi',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSkillBar('Flutter', 85, Colors.blue),
            SizedBox(height: 8.h),
            _buildSkillBar('Dart', 80, Colors.green),
            SizedBox(height: 8.h),
            _buildSkillBar('Firebase', 75, Colors.orange),
            SizedBox(height: 8.h),
            _buildSkillBar('UI/UX', 70, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillBar(String skill, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skill,
              style: TextStyle(fontSize: 14.sp),
            ),
            Text(
              '${percentage.toInt()}%',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ],
    );
  }
}

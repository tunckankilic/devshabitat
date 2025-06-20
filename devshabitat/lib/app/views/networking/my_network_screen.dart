import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyNetworkScreen extends StatelessWidget {
  const MyNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ağım', style: TextStyle(fontSize: 18.sp)),
          bottom: TabBar(
            labelStyle: TextStyle(fontSize: 14.sp),
            tabs: const [
              Tab(text: 'Genel Bakış'),
              Tab(text: 'Bağlantılar'),
              Tab(text: 'Analitik'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(),
            _ConnectionsTab(),
            _AnalyticsTab(),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(),
          SizedBox(height: 24.h),
          _buildWeeklyGrowthChart(),
          SizedBox(height: 24.h),
          _buildTopSkills(),
          SizedBox(height: 24.h),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(Get.context!).size.width > 600 ? 3 : 2,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: 1.5.w,
      children: [
        _StatCard(
          title: 'Toplam Bağlantı',
          value: '156',
          trend: '+12%',
          isPositive: true,
          icon: Icons.people_outline,
        ),
        _StatCard(
          title: 'Kabul Oranı',
          value: '%85',
          trend: '+5%',
          isPositive: true,
          icon: Icons.check_circle_outline,
        ),
        _StatCard(
          title: 'Haftalık Büyüme',
          value: '+23',
          trend: '+15%',
          isPositive: true,
          icon: Icons.trending_up,
        ),
        _StatCard(
          title: 'Aktif Bağlantılar',
          value: '89',
          trend: '-3%',
          isPositive: false,
          icon: Icons.person_outline,
        ),
      ],
    );
  }

  Widget _buildWeeklyGrowthChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Haftalık Büyüme',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: _SimpleBarChart(
                data: [
                  _ChartData('Pzt', 45),
                  _ChartData('Sal', 60),
                  _ChartData('Çar', 35),
                  _ChartData('Per', 70),
                  _ChartData('Cum', 55),
                  _ChartData('Cmt', 40),
                  _ChartData('Paz', 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSkills() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'En İyi Yetenekler',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _SkillBar(
              skill: 'Flutter',
              percentage: 85,
              color: Colors.blue,
            ),
            SizedBox(height: 8.h),
            _SkillBar(
              skill: 'Dart',
              percentage: 80,
              color: Colors.green,
            ),
            SizedBox(height: 8.h),
            _SkillBar(
              skill: 'Firebase',
              percentage: 75,
              color: Colors.orange,
            ),
            SizedBox(height: 8.h),
            _SkillBar(
              skill: 'UI/UX',
              percentage: 70,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son Aktiviteler',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _ActivityItem(
              title: 'Yeni Bağlantı',
              description: 'Ahmet Y. ile bağlantı kuruldu',
              time: '2 saat önce',
              icon: Icons.person_add,
            ),
            SizedBox(height: 8.h),
            _ActivityItem(
              title: 'Profil Görüntüleme',
              description: 'Profiliniz 25 kez görüntülendi',
              time: '1 gün önce',
              icon: Icons.visibility,
            ),
            SizedBox(height: 8.h),
            _ActivityItem(
              title: 'Yetenek Onayı',
              description: 'Flutter yeteneğiniz 3 kişi tarafından onaylandı',
              time: '2 gün önce',
              icon: Icons.verified,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(fontSize: 16.sp),
                  decoration: InputDecoration(
                    hintText: 'Bağlantılarda ara...',
                    hintStyle: TextStyle(fontSize: 16.sp),
                    prefixIcon: Icon(Icons.search, size: 24.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: Icon(Icons.filter_list, size: 24.sp),
                onPressed: () => _showFilterDialog(),
              ),
              IconButton(
                icon: Icon(Icons.sort, size: 24.sp),
                onPressed: () => _showSortDialog(),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16.r),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              childAspectRatio: 0.8.w,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
            ),
            itemCount: 10, // Örnek veri
            itemBuilder: (context, index) {
              return _buildConnectionCard(
                'Kullanıcı ${index + 1}',
                'Flutter Developer',
                'https://via.placeholder.com/150',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          _buildAnalyticCard(
            'Bağlantı Dağılımı',
            _PieChartWidget(
              segments: [
                _PieSegment('Aktif', 0.45, Colors.green),
                _PieSegment('Yeni', 0.30, Colors.blue),
                _PieSegment('Pasif', 0.25, Colors.grey),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _buildAnalyticCard(
            'Etkileşim Analizi',
            _InteractionChart(),
          ),
          SizedBox(height: 16.h),
          _buildAnalyticCard(
            'Büyüme Trendi',
            _TrendLineChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(String title, Widget chart) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
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
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16.sp,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                Text(
                  trend,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final String skill;
  final int percentage;
  final Color color;

  const _SkillBar({
    required this.skill,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(skill, style: TextStyle(fontSize: 14.sp)),
            Text('$percentage%', style: TextStyle(fontSize: 14.sp)),
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

class _ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;

  const _ActivityItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, size: 24.sp, color: Theme.of(context).primaryColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<_ChartData> data;

  const _SimpleBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final height = (item.value / maxValue) * 150.h;
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: height,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 8.h),
              Text(item.label, style: TextStyle(fontSize: 12.sp)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ChartData {
  final String label;
  final double value;

  _ChartData(this.label, this.value);
}

class _PieChartWidget extends StatelessWidget {
  final List<_PieSegment> segments;

  const _PieChartWidget({required this.segments});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PieChartPainter(segments),
      size: Size(200.w, 200.h),
    );
  }
}

class _PieSegment {
  final String label;
  final double value;
  final Color color;

  _PieSegment(this.label, this.value, this.color);
}

class _PieChartPainter extends CustomPainter {
  final List<_PieSegment> segments;

  _PieChartPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    var startAngle = 0.0;

    for (final segment in segments) {
      final sweepAngle = segment.value * 2 * 3.14159;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) => false;
}

class _InteractionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InteractionPainter(),
      size: Size(double.infinity, 200.h),
    );
  }
}

class _InteractionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.w
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.3,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.4,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_InteractionPainter oldDelegate) => false;
}

class _TrendLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrendLinePainter(),
      size: Size(double.infinity, 200.h),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.w
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.4, size.height * 0.4);
    path.lineTo(size.width * 0.6, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrendLinePainter oldDelegate) => false;
}

void _showFilterDialog() {
  Get.dialog(
    AlertDialog(
      title: Text(
        'Filtreleme Seçenekleri',
        style: TextStyle(fontSize: 18.sp),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              'Tüm Bağlantılar',
              style: TextStyle(fontSize: 16.sp),
            ),
            leading: Icon(Icons.people, size: 24.sp),
            onTap: () {
              Get.back();
              // Tüm bağlantıları göster
            },
          ),
          ListTile(
            title: Text(
              'Yeni Bağlantılar',
              style: TextStyle(fontSize: 16.sp),
            ),
            leading: Icon(Icons.person_add, size: 24.sp),
            onTap: () {
              Get.back();
              // Yeni bağlantıları göster
            },
          ),
          ListTile(
            title: Text(
              'Aktif Bağlantılar',
              style: TextStyle(fontSize: 16.sp),
            ),
            leading: Icon(Icons.star, size: 24.sp),
            onTap: () {
              Get.back();
              // Aktif bağlantıları göster
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'İptal',
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    ),
  );
}

void _showSortDialog() {
  Get.dialog(
    AlertDialog(
      title: Text(
        'Sıralama Seçenekleri',
        style: TextStyle(fontSize: 18.sp),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              'İsme Göre',
              style: TextStyle(fontSize: 16.sp),
            ),
            leading: Icon(Icons.sort_by_alpha, size: 24.sp),
            onTap: () {
              Get.back();
              // İsme göre sırala
            },
          ),
          ListTile(
            title: Text(
              'Bağlantı Tarihine Göre',
              style: TextStyle(fontSize: 16.sp),
            ),
            leading: Icon(Icons.date_range, size: 24.sp),
            onTap: () {
              Get.back();
              // Tarihe göre sırala
            },
          ),
          ListTile(
            title: Text(
              'Etkileşime Göre',
              style: TextStyle(fontSize: 16.sp),
            ),
            leading: Icon(Icons.trending_up, size: 24.sp),
            onTap: () {
              Get.back();
              // Etkileşime göre sırala
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'İptal',
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    ),
  );
}

Widget _buildConnectionCard(String name, String title, String imageUrl) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32.r,
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(height: 8.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.message, size: 24.sp),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person, size: 24.sp),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

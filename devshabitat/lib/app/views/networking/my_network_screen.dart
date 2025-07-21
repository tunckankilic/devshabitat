import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';

class MyNetworkScreen extends StatelessWidget {
  const MyNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.myNetwork,
              style: TextStyle(
                  fontSize:
                      responsive.responsiveValue(mobile: 18, tablet: 20))),
          bottom: TabBar(
            labelStyle: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16)),
            tabs: const [
              Tab(text: AppStrings.generalOverview),
              Tab(text: AppStrings.connections),
              Tab(text: AppStrings.analytics),
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
    final responsive = Get.find<ResponsiveController>();

    return SingleChildScrollView(
      padding: responsive.responsivePadding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
          _buildWeeklyGrowthChart(),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
          _buildTopSkills(),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final responsive = Get.find<ResponsiveController>();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: responsive.gridColumns,
      mainAxisSpacing: responsive.gridSpacing,
      crossAxisSpacing: responsive.gridSpacing,
      childAspectRatio:
          responsive.responsiveValue(mobile: 1.5, tablet: 1.8, desktop: 2.0),
      children: [
        _StatCard(
          title: AppStrings.totalConnections,
          value: '156',
          trend: '+12%',
          isPositive: true,
          icon: Icons.people_outline,
        ),
        _StatCard(
          title: AppStrings.acceptanceRate,
          value: '%85',
          trend: '+5%',
          isPositive: true,
          icon: Icons.check_circle_outline,
        ),
        _StatCard(
          title: AppStrings.weeklyGrowth,
          value: '+23',
          trend: '+15%',
          isPositive: true,
          icon: Icons.trending_up,
        ),
        _StatCard(
          title: AppStrings.activeConnections,
          value: '89',
          trend: '-3%',
          isPositive: false,
          icon: Icons.person_outline,
        ),
      ],
    );
  }

  Widget _buildWeeklyGrowthChart() {
    final responsive = Get.find<ResponsiveController>();

    return Card(
      child: Padding(
        padding: responsive.responsivePadding(all: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.weeklyGrowth,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            SizedBox(
              height: responsive.responsiveValue(mobile: 200, tablet: 250),
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
    final responsive = Get.find<ResponsiveController>();

    return Card(
      child: Padding(
        padding: responsive.responsivePadding(all: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.bestSkills,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            _SkillBar(
              skill: 'Flutter',
              percentage: 85,
              color: Colors.blue,
            ),
            SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
            _SkillBar(
              skill: 'Dart',
              percentage: 80,
              color: Colors.green,
            ),
            SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
            _SkillBar(
              skill: 'Firebase',
              percentage: 75,
              color: Colors.orange,
            ),
            SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
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
    final responsive = Get.find<ResponsiveController>();

    return Card(
      child: Padding(
        padding: responsive.responsivePadding(all: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.recentActivity,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            _ActivityItem(
              title: AppStrings.newConnection,
              description: 'Ahmet Y. ile bağlantı kuruldu',
              time: '2 hours ago',
              icon: Icons.person_add,
            ),
            SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
            _ActivityItem(
              title: AppStrings.profileView,
              description: 'Profiliniz 25 kez görüntülendi',
              time: '1 day ago',
              icon: Icons.visibility,
            ),
            SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
            _ActivityItem(
              title: AppStrings.skillApproval,
              description: 'Flutter yeteneğiniz 3 kişi tarafından onaylandı',
              time: '2 days ago',
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
    final responsive = Get.find<ResponsiveController>();

    return Column(
      children: [
        Padding(
          padding: responsive.responsivePadding(all: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18)),
                  decoration: InputDecoration(
                    hintText: AppStrings.searchConnections,
                    hintStyle: TextStyle(
                        fontSize:
                            responsive.responsiveValue(mobile: 16, tablet: 18)),
                    prefixIcon: Icon(Icons.search,
                        size:
                            responsive.responsiveValue(mobile: 24, tablet: 28)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          responsive.responsiveValue(mobile: 12, tablet: 16)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  width: responsive.responsiveValue(mobile: 8, tablet: 12)),
              IconButton(
                icon: Icon(Icons.filter_list,
                    size: responsive.responsiveValue(mobile: 24, tablet: 28)),
                onPressed: () => _showFilterDialog(),
              ),
              IconButton(
                icon: Icon(Icons.sort,
                    size: responsive.responsiveValue(mobile: 24, tablet: 28)),
                onPressed: () => _showSortDialog(),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: responsive.responsivePadding(all: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.gridColumns,
              childAspectRatio: responsive.responsiveValue(
                  mobile: 0.8, tablet: 1.0, desktop: 1.2),
              crossAxisSpacing: responsive.gridSpacing,
              mainAxisSpacing: responsive.gridSpacing,
            ),
            itemCount: 10, // Örnek veri
            itemBuilder: (context, index) {
              return _buildConnectionCard(
                'User ${index + 1}',
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
    final responsive = Get.find<ResponsiveController>();

    return SingleChildScrollView(
      padding: responsive.responsivePadding(all: 16),
      child: Column(
        children: [
          _buildAnalyticCard(
            AppStrings.connectionDistribution,
            _PieChartWidget(
              segments: [
                _PieSegment('Aktif', 0.45, Colors.green),
                _PieSegment('Yeni', 0.30, Colors.blue),
                _PieSegment('Pasif', 0.25, Colors.grey),
              ],
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
          _buildAnalyticCard(
            AppStrings.interactionAnalysis,
            _InteractionChart(),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
          _buildAnalyticCard(
            AppStrings.growthTrend,
            _TrendLineChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(String title, Widget chart) {
    final responsive = Get.find<ResponsiveController>();

    return Card(
      child: Padding(
        padding: responsive.responsivePadding(all: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            SizedBox(
              height: responsive.responsiveValue(mobile: 200, tablet: 250),
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
    final responsive = Get.find<ResponsiveController>();

    return Card(
      child: Padding(
        padding: responsive.responsivePadding(all: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: responsive.responsiveValue(mobile: 24, tablet: 28)),
                SizedBox(
                    width: responsive.responsiveValue(mobile: 8, tablet: 12)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 24, tablet: 28),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.responsiveValue(mobile: 4, tablet: 6)),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: responsive.responsiveValue(mobile: 16, tablet: 18),
                  color: isPositive ? Colors.green : Colors.red,
                ),
                Text(
                  trend,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16),
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
    final responsive = Get.find<ResponsiveController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(skill,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16))),
            Text('$percentage%',
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16))),
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
    final responsive = Get.find<ResponsiveController>();

    return Row(
      children: [
        CircleAvatar(
          radius: responsive.responsiveValue(mobile: 20, tablet: 24),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon,
              size: responsive.responsiveValue(mobile: 24, tablet: 28),
              color: Theme.of(context).primaryColor),
        ),
        SizedBox(width: responsive.responsiveValue(mobile: 12, tablet: 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                  height: responsive.responsiveValue(mobile: 4, tablet: 6)),
              Text(
                description,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16)),
              ),
              SizedBox(
                  height: responsive.responsiveValue(mobile: 4, tablet: 6)),
              Text(
                time,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
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
    final responsive = Get.find<ResponsiveController>();
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final height = (item.value / maxValue) *
            responsive.responsiveValue(mobile: 150, tablet: 180);
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: height,
                margin: EdgeInsets.symmetric(
                    horizontal:
                        responsive.responsiveValue(mobile: 4, tablet: 6)),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(
                      responsive.responsiveValue(mobile: 4, tablet: 6)),
                ),
              ),
              SizedBox(
                  height: responsive.responsiveValue(mobile: 8, tablet: 10)),
              Text(item.label,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 12, tablet: 14))),
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
    final responsive = Get.find<ResponsiveController>();
    return CustomPaint(
      painter: _PieChartPainter(segments),
      size: Size(
        responsive.responsiveValue(mobile: 200, tablet: 250),
        responsive.responsiveValue(mobile: 200, tablet: 250),
      ),
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
    final responsive = Get.find<ResponsiveController>();
    return CustomPaint(
      painter: _InteractionPainter(),
      size: Size(double.infinity,
          responsive.responsiveValue(mobile: 200, tablet: 250)),
    );
  }
}

class _InteractionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
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
    final responsive = Get.find<ResponsiveController>();
    return CustomPaint(
      painter: _TrendLinePainter(),
      size: Size(double.infinity,
          responsive.responsiveValue(mobile: 200, tablet: 250)),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
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
  final responsive = Get.find<ResponsiveController>();
  Get.dialog(
    AlertDialog(
      title: Text(
        AppStrings.filterOptions,
        style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 18, tablet: 20)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              AppStrings.allConnections,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
            ),
            leading: Icon(Icons.people,
                size: responsive.responsiveValue(mobile: 24, tablet: 28)),
            onTap: () {
              Get.back();
              // Tüm bağlantıları göster
            },
          ),
          ListTile(
            title: Text(
              AppStrings.newConnections,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
            ),
            leading: Icon(Icons.person_add,
                size: responsive.responsiveValue(mobile: 24, tablet: 28)),
            onTap: () {
              Get.back();
              // Yeni bağlantıları göster
            },
          ),
          ListTile(
            title: Text(
              AppStrings.activeConnections,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
            ),
            leading: Icon(Icons.star,
                size: responsive.responsiveValue(mobile: 24, tablet: 28)),
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
            AppStrings.cancel,
            style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16)),
          ),
        ),
      ],
    ),
  );
}

void _showSortDialog() {
  final responsive = Get.find<ResponsiveController>();
  Get.dialog(
    AlertDialog(
      title: Text(
        AppStrings.sortOptions,
        style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 18, tablet: 20)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              AppStrings.byName,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
            ),
            leading: Icon(Icons.sort_by_alpha,
                size: responsive.responsiveValue(mobile: 24, tablet: 28)),
            onTap: () {
              Get.back();
              // İsme göre sırala
            },
          ),
          ListTile(
            title: Text(
              AppStrings.byConnectionDate,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
            ),
            leading: Icon(Icons.date_range,
                size: responsive.responsiveValue(mobile: 24, tablet: 28)),
            onTap: () {
              Get.back();
              // Tarihe göre sırala
            },
          ),
          ListTile(
            title: Text(
              AppStrings.byInteraction,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
            ),
            leading: Icon(Icons.trending_up,
                size: responsive.responsiveValue(mobile: 24, tablet: 28)),
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
            AppStrings.cancel,
            style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16)),
          ),
        ),
      ],
    ),
  );
}

Widget _buildConnectionCard(String name, String title, String imageUrl) {
  final responsive = Get.find<ResponsiveController>();
  return Card(
    child: Padding(
      padding: responsive.responsivePadding(all: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: responsive.responsiveValue(mobile: 32, tablet: 40),
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Text(
            name,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 4, tablet: 6)),
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.message,
                    size: responsive.responsiveValue(mobile: 24, tablet: 28)),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person,
                    size: responsive.responsiveValue(mobile: 24, tablet: 28)),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

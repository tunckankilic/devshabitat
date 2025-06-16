import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/network_stats_model.dart';
import '../../services/network_analytics_service.dart';

class MyNetworkScreen extends StatelessWidget {
  const MyNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ağım'),
          bottom: const TabBar(
            tabs: [
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(),
          const SizedBox(height: 24),
          _buildWeeklyGrowthChart(),
          const SizedBox(height: 24),
          _buildTopSkills(),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Haftalık Büyüme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'En İyi Yetenekler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _SkillBar(
              skill: 'Flutter',
              percentage: 85,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _SkillBar(
              skill: 'Dart',
              percentage: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            _SkillBar(
              skill: 'Firebase',
              percentage: 75,
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
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
}

class _ConnectionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text('Bağlantı ${index + 1}'),
            subtitle: Text('Flutter Developer'),
            trailing: IconButton(
              icon: const Icon(Icons.message_outlined),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 16),
          _buildAnalyticCard(
            'Etkileşim Analizi',
            _InteractionChart(),
          ),
          const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                Text(
                  trend,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
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

class _SimpleBarChart extends StatelessWidget {
  final List<_ChartData> data;

  const _SimpleBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final height = (item.value / maxValue) * 150;
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(item.label),
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
            Text(skill),
            Text('$percentage%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final List<_PieSegment> segments;

  const _PieChartWidget({required this.segments});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PieChartPainter(segments),
      size: const Size(200, 200),
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
      size: const Size(double.infinity, 200),
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
    return CustomPaint(
      painter: _TrendLinePainter(),
      size: const Size(double.infinity, 200),
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

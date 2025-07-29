import 'package:flutter/material.dart';
import '../../../widgets/responsive/responsive_text.dart';

class ContributionGraphWidget extends StatelessWidget {
  final Map<String, int> contributionData;
  final String username;

  const ContributionGraphWidget({
    super.key,
    required this.contributionData,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ResponsiveText(
                    'Contribution Graph',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (contributionData.isEmpty)
              _buildEmptyState(context)
            else
              _buildContributionGraph(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart,
              size: 40,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8),
            ResponsiveText(
              'Contribution verisi yok',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            ResponsiveText(
              'GitHub aktiviteleriniz görüntülenecek',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionGraph(BuildContext context) {
    // Son 365 günün contribution verilerini al
    final now = DateTime.now();
    final contributions = <DateTime, int>{};

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      contributions[date] = contributionData[dateKey] ?? 0;
    }

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: _buildGraphGrid(contributions),
        ),
        SizedBox(height: 12),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildGraphGrid(Map<DateTime, int> contributions) {
    final weeks = <List<DateTime>>[];
    final dates = contributions.keys.toList()..sort();

    // Haftalık gruplara böl
    for (int i = 0; i < dates.length; i += 7) {
      final week = dates.skip(i).take(7).toList();
      if (week.length == 7) {
        weeks.add(week);
      }
    }

    return Row(
      children: weeks.map((week) {
        return Expanded(
          child: Column(
            children: week.map((date) {
              final contribution = contributions[date] ?? 0;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: _getContributionColor(contribution),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ResponsiveText(
          'Daha az',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getContributionColor(0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 4),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getContributionColor(1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 4),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getContributionColor(3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 4),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getContributionColor(6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 4),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getContributionColor(10),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        ResponsiveText(
          'Daha çok',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getContributionColor(int contribution) {
    if (contribution == 0) return Colors.grey[100]!;
    if (contribution <= 1) return Colors.green[200]!;
    if (contribution <= 3) return Colors.green[300]!;
    if (contribution <= 6) return Colors.green[400]!;
    if (contribution <= 10) return Colors.green[500]!;
    return Colors.green[600]!;
  }
}

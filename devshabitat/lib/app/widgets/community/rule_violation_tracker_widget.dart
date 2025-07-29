import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/community/rule_violation_model.dart';
import '../../models/community/rule_model.dart';

class RuleViolationTrackerWidget extends StatelessWidget {
  final String communityId;
  final String userId;
  final List<RuleViolationModel> violations;
  final List<RuleModel> rules;
  final Function(RuleViolationModel) onViolationAction;
  final bool isModerator;

  const RuleViolationTrackerWidget({
    super.key,
    required this.communityId,
    required this.userId,
    required this.violations,
    required this.rules,
    required this.onViolationAction,
    this.isModerator = false,
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
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Kural İhlali Takibi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isModerator)
                  ElevatedButton.icon(
                    onPressed: () => _navigateToRulesManagement(),
                    icon: const Icon(Icons.settings),
                    label: const Text('Yönet'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // İstatistikler
            _buildStatistics(),
            const SizedBox(height: 16),

            // Son İhlaller
            _buildRecentViolations(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final pendingCount =
        violations.where((v) => v.status == ViolationStatus.pending).length;
    final resolvedCount =
        violations.where((v) => v.status == ViolationStatus.resolved).length;
    final totalCount = violations.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Toplam',
            totalCount.toString(),
            Colors.blue,
            Icons.list,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Bekleyen',
            pendingCount.toString(),
            Colors.orange,
            Icons.pending,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Çözülen',
            resolvedCount.toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentViolations(BuildContext context) {
    final recentViolations = violations
        .where((v) => v.status == ViolationStatus.pending)
        .take(3)
        .toList();

    if (recentViolations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Bekleyen ihlal bulunmuyor',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Son İhlaller',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...recentViolations
            .map((violation) => _buildViolationItem(context, violation)),
      ],
    );
  }

  Widget _buildViolationItem(
      BuildContext context, RuleViolationModel violation) {
    final rule = rules.firstWhere(
      (r) => r.id == violation.ruleId,
      orElse: () => RuleModel(
        id: '',
        communityId: '',
        title: 'Bilinmeyen Kural',
        description: '',
        category: RuleCategory.other,
        severity: RuleSeverity.medium,
        enforcement: RuleEnforcement.manual,
        keywords: [],
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: '',
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: _getSeverityColor(rule.severity),
          child: Icon(
            Icons.warning,
            color: Colors.white,
            size: 16,
          ),
        ),
        title: Text(
          rule.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              violation.description,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Tarih: ${_formatDate(violation.createdAt)}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        trailing: isModerator
            ? PopupMenuButton<String>(
                onSelected: (action) =>
                    _handleViolationAction(violation, action),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'confirm',
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Text('Onayla', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reject',
                    child: Row(
                      children: [
                        Icon(Icons.close, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text('Reddet', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'resolve',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Text('Çözüldü', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _navigateToRulesManagement() {
    Get.toNamed(
      '/community/rules',
      arguments: {
        'communityId': communityId,
        'userId': userId,
      },
    );
  }

  void _handleViolationAction(RuleViolationModel violation, String action) {
    switch (action) {
      case 'confirm':
        final updatedViolation = violation.copyWith(
          status: ViolationStatus.confirmed,
          action: ViolationAction.warning,
        );
        onViolationAction(updatedViolation);
        break;
      case 'reject':
        final updatedViolation = violation.copyWith(
          status: ViolationStatus.rejected,
        );
        onViolationAction(updatedViolation);
        break;
      case 'resolve':
        final updatedViolation = violation.copyWith(
          status: ViolationStatus.resolved,
          resolvedAt: DateTime.now(),
        );
        onViolationAction(updatedViolation);
        break;
    }
  }

  Color _getSeverityColor(RuleSeverity severity) {
    switch (severity) {
      case RuleSeverity.low:
        return Colors.green;
      case RuleSeverity.medium:
        return Colors.orange;
      case RuleSeverity.high:
        return Colors.red;
      case RuleSeverity.critical:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

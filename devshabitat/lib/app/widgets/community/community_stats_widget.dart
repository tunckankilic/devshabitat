import 'package:flutter/material.dart';
import '../../models/community/community_model.dart';

class CommunityStatsWidget extends StatelessWidget {
  final CommunityModel community;

  const CommunityStatsWidget({
    Key? key,
    required this.community,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topluluk İstatistikleri',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.people,
                  'Üyeler',
                  community.memberCount.toString(),
                ),
                _buildStatItem(
                  context,
                  Icons.event,
                  'Etkinlikler',
                  community.eventCount.toString(),
                ),
                _buildStatItem(
                  context,
                  Icons.message,
                  'Gönderiler',
                  community.postCount.toString(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.admin_panel_settings,
                  'Moderatörler',
                  community.moderatorIds.length.toString(),
                ),
                _buildStatItem(
                  context,
                  Icons.person_add,
                  'Bekleyen İstekler',
                  community.pendingMemberIds.length.toString(),
                ),
                _buildStatItem(
                  context,
                  Icons.calendar_today,
                  'Kuruluş',
                  _formatDate(community.createdAt),
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
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

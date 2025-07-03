import 'package:flutter/material.dart';
import '../../models/community/community_model.dart';
import '../../routes/app_routes.dart';
import 'package:get/get.dart';

class CommunityCardWidget extends StatelessWidget {
  final CommunityModel community;
  final bool isManageable;
  final VoidCallback? onTap;

  const CommunityCardWidget({
    Key? key,
    required this.community,
    this.isManageable = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap ??
            () => Get.toNamed(
                  Routes.COMMUNITY_DETAIL,
                  arguments: community,
                ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topluluk Kapak Fotoğrafı
            if (community.coverImageUrl != null)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(community.coverImageUrl!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topluluk Adı ve Yönetici Rozeti
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          community.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isManageable)
                        Icon(
                          Icons.admin_panel_settings,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Topluluk Açıklaması
                  Text(
                    community.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Topluluk İstatistikleri
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        context,
                        Icons.people,
                        '${community.memberCount} Üye',
                      ),
                      _buildStat(
                        context,
                        Icons.event,
                        '${community.eventCount} Etkinlik',
                      ),
                      _buildStat(
                        context,
                        Icons.message,
                        '${community.postCount} Gönderi',
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

  Widget _buildStat(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

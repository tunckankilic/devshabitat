import 'package:devshabitat/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';
import '../../models/community/community_model.dart';

class CommunityCardWidget extends StatelessWidget {
  final CommunityModel community;
  final bool isManageable;
  final VoidCallback? onTap;

  const CommunityCardWidget({
    super.key,
    required this.community,
    this.isManageable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Card(
      elevation: responsive.responsiveValue(
        mobile: 2,
        tablet: 3,
      ),
      margin: responsive.responsivePadding(
        vertical: 8,
        horizontal: 16,
      ),
      child: InkWell(
        onTap: onTap ??
            () => Get.toNamed(
                  AppRoutes.COMMUNITY_DETAIL,
                  arguments: community,
                ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topluluk Kapak Fotoğrafı
            if (community.coverImageUrl != null)
              Container(
                height: responsive.responsiveValue(
                  mobile: 120,
                  tablet: 160,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(community.coverImageUrl!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      responsive.responsiveValue(
                        mobile: 12,
                        tablet: 16,
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: responsive.responsivePadding(all: 16),
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
                            fontSize: performanceService.getOptimizedTextSize(
                              cacheKey: 'community_card_title',
                              mobileSize: 18,
                              tabletSize: 20,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isManageable)
                        Icon(
                          Icons.admin_panel_settings,
                          color: theme.colorScheme.primary,
                          size: responsive.responsiveValue(
                            mobile: 20,
                            tablet: 24,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(
                      height: responsive.responsiveValue(
                    mobile: 8,
                    tablet: 12,
                  )),

                  // Topluluk Açıklaması
                  Text(
                    community.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: performanceService.getOptimizedTextSize(
                        cacheKey: 'community_card_description',
                        mobileSize: 14,
                        tabletSize: 16,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(
                      height: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 20,
                  )),

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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Row(
      children: [
        Icon(
          icon,
          size: responsive.responsiveValue(
            mobile: 16,
            tablet: 18,
          ),
          color: Theme.of(context).colorScheme.secondary,
        ),
        SizedBox(
            width: responsive.responsiveValue(
          mobile: 4,
          tablet: 6,
        )),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'community_card_stat_text',
                  mobileSize: 12,
                  tabletSize: 14,
                ),
              ),
        ),
      ],
    );
  }
}

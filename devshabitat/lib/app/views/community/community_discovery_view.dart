import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/community/community_discovery_controller.dart';
import '../../widgets/community/community_card_widget.dart';
import '../../widgets/community/community_discovery_skeleton.dart';
import '../../routes/app_pages.dart';
import '../base/base_view.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveText, ResponsiveSafeArea;
import '../../widgets/responsive/animated_responsive_layout.dart';

class CommunityDiscoveryView extends BaseView<CommunityDiscoveryController> {
  const CommunityDiscoveryView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          AppStrings.discoverCommunities,
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
          ),
        ),
        actions: [
          AdaptiveTouchTarget(
            onTap: controller.showFilters,
            child: Icon(Icons.filter_list, size: responsive.minTouchTarget),
          ),
          AdaptiveTouchTarget(
            onTap: controller.showSearch,
            child: Icon(Icons.search, size: responsive.minTouchTarget),
          ),
        ],
      ),
      body: ResponsiveSafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshCommunities,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const CommunityDiscoverySkeleton();
            }

            if (controller.errorMessage.value != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResponsiveText(
                      'Hata: ${controller.errorMessage.value}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 16,
                          tablet: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller.refreshCommunities,
                      child: ResponsiveText(
                        AppStrings.retry,
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 14,
                            tablet: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.communities.isEmpty) {
              return Center(
                child: ResponsiveText(
                  AppStrings.noCommunitiesFound,
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 16,
                      tablet: 18,
                    ),
                  ),
                ),
              );
            }

            return ResponsiveOverflowHandler(
              child: AnimatedResponsiveLayout(
                mobile: _buildMobileCommunityList(),
                tablet: _buildTabletCommunityGrid(),
                animationDuration: const Duration(milliseconds: 300),
              ),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.COMMUNITY_CREATE),
        icon: Icon(
          Icons.add,
          size: responsive.responsiveValue(mobile: 24, tablet: 28),
        ),
        label: ResponsiveText(
          AppStrings.createCommunity,
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCommunityList() {
    return ListView.builder(
      padding: responsive.responsivePadding(top: 8, bottom: 16),
      itemCount: controller.communities.length,
      itemBuilder: (context, index) {
        final community = controller.communities[index];
        return CommunityCardWidget(
          key: ValueKey('community_card_${community.id}'),
          community: community,
          isManageable: controller.isUserModerator(community),
        );
      },
    );
  }

  Widget _buildTabletCommunityGrid() {
    return GridView.builder(
      padding: responsive.responsivePadding(all: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: controller.communities.length,
      itemBuilder: (context, index) {
        final community = controller.communities[index];
        return CommunityCardWidget(
          key: ValueKey('community_grid_card_${community.id}'),
          community: community,
          isManageable: controller.isUserModerator(community),
        );
      },
    );
  }
}

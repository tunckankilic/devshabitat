import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/community_controller.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';
import '../../widgets/community/community_stats_widget.dart';
import '../../widgets/community/member_list_widget.dart';
import '../../widgets/community/membership_request_widget.dart';
import '../../routes/app_pages.dart';
import '../base/base_view.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveSafeArea, ResponsiveText;
import '../../widgets/responsive/animated_responsive_layout.dart';

class CommunityDetailView extends BaseView<CommunityController> {
  const CommunityDetailView({Key? key}) : super(key: key);

  @override
  Widget buildView(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Scaffold(
      body: ResponsiveSafeArea(
        child: Obx(
          () {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: responsive.responsiveValue(
                    mobile: 2,
                    tablet: 3,
                  ),
                ),
              );
            }

            if (controller.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResponsiveText(
                      'Hata: ${controller.error.value}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: performanceService.getOptimizedTextSize(
                          cacheKey: 'community_detail_error',
                          mobileSize: 16,
                          tabletSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                        height: responsive.responsiveValue(
                      mobile: 16,
                      tablet: 20,
                    )),
                    ElevatedButton(
                      onPressed: () => controller
                          .loadCommunity(controller.community.value?.id ?? ''),
                      child: ResponsiveText(
                        'Tekrar Dene',
                        style: TextStyle(
                          fontSize: performanceService.getOptimizedTextSize(
                            cacheKey: 'community_detail_retry',
                            mobileSize: 14,
                            tabletSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final community = controller.community.value;
            if (community == null) {
              return Center(
                child: ResponsiveText(
                  'Topluluk bulunamadı',
                  style: TextStyle(
                    fontSize: performanceService.getOptimizedTextSize(
                      cacheKey: 'community_detail_not_found',
                      mobileSize: 16,
                      tabletSize: 18,
                    ),
                  ),
                ),
              );
            }

            return ResponsiveOverflowHandler(
              child: AnimatedResponsiveLayout(
                mobile: _buildMobileCommunityDetail(community, context),
                tablet: _buildTabletCommunityDetail(community, context),
                animationDuration: const Duration(milliseconds: 300),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileCommunityDetail(dynamic community, BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return CustomScrollView(
      slivers: [
        _buildAppBar(community, context),
        SliverToBoxAdapter(
          child: Padding(
            padding: responsive.responsivePadding(all: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDescription(community, context),
                SizedBox(
                    height: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 32,
                )),
                _buildStats(community),
                SizedBox(
                    height: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 32,
                )),
                _buildMembershipButton(),
                SizedBox(
                    height: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 32,
                )),
                _buildMembershipRequests(),
                _buildMembersList(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletCommunityDetail(dynamic community, BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return CustomScrollView(
      slivers: [
        _buildAppBar(community, context),
        SliverToBoxAdapter(
          child: Padding(
            padding: responsive.responsivePadding(all: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDescription(community, context),
                      SizedBox(
                          height: responsive.responsiveValue(
                        mobile: 24,
                        tablet: 32,
                      )),
                      _buildStats(community),
                      SizedBox(
                          height: responsive.responsiveValue(
                        mobile: 24,
                        tablet: 32,
                      )),
                      _buildMembershipButton(),
                    ],
                  ),
                ),
                SizedBox(
                    width: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 32,
                )),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMembershipRequests(),
                      _buildMembersList(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(dynamic community, BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return SliverAppBar(
      expandedHeight: responsive.responsiveValue(
        mobile: 200,
        tablet: 300,
      ),
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: ResponsiveText(
          community.name,
          style: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_detail_appbar_title',
              mobileSize: 20,
              tabletSize: 24,
            ),
          ),
        ),
        background: community.coverImageUrl != null
            ? Image.network(
                community.coverImageUrl!,
                fit: BoxFit.cover,
              )
            : Container(
                color: Theme.of(context).primaryColor,
              ),
      ),
      actions: [
        if (controller.isUserModerator.value)
          AdaptiveTouchTarget(
            onTap: () => Get.toNamed(
              AppRoutes.COMMUNITY_MANAGE,
              arguments: community,
            ),
            child: Icon(
              Icons.settings,
              size: responsive.minTouchTarget,
            ),
          ),
      ],
    );
  }

  Widget _buildDescription(dynamic community, BuildContext context) {
    final performanceService = Get.find<ResponsivePerformanceService>();

    return ResponsiveText(
      community.description,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_detail_description',
              mobileSize: 16,
              tabletSize: 18,
            ),
          ),
    );
  }

  Widget _buildStats(dynamic community) {
    return CommunityStatsWidget(community: community);
  }

  Widget _buildMembershipButton() {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    if (controller.isUserModerator.value) return const SizedBox.shrink();

    return Obx(
      () => Center(
        child: ElevatedButton.icon(
          onPressed: controller.isMember.value
              ? controller.leaveCommunity
              : controller.joinCommunity,
          icon: Icon(
            controller.isMember.value ? Icons.exit_to_app : Icons.person_add,
            size: performanceService.getOptimizedTextSize(
              cacheKey: 'community_detail_button_icon',
              mobileSize: 24,
              tabletSize: 28,
            ),
          ),
          label: ResponsiveText(
            controller.isMember.value ? 'Topluluktan Ayrıl' : 'Topluluğa Katıl',
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'community_detail_button_text',
                mobileSize: 14,
                tabletSize: 16,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isMember.value ? Colors.red : null,
            padding: responsive.responsivePadding(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipRequests() {
    final responsive = Get.find<ResponsiveController>();

    if (!controller.isUserModerator.value ||
        controller.pendingMembers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MembershipRequestWidget(
          pendingMembers: controller.pendingMembers,
          onAccept: controller.acceptMember,
          onReject: controller.rejectMember,
        ),
        SizedBox(
            height: responsive.responsiveValue(
          mobile: 24,
          tablet: 32,
        )),
      ],
    );
  }

  Widget _buildMembersList(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Üyeler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'community_detail_members_title',
                  mobileSize: 20,
                  tabletSize: 24,
                ),
              ),
        ),
        SizedBox(
            height: responsive.responsiveValue(
          mobile: 16,
          tablet: 20,
        )),
        MemberListWidget(
          members: controller.members,
          isAdmin: controller.isUserModerator.value,
          onMemberTap: controller.showMemberProfile,
          onRemoveMember: controller.removeMember,
          onPromoteToModerator: controller.promoteToModerator,
        ),
      ],
    );
  }
}

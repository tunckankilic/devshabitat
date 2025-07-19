import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/community/community_controller.dart';
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
    return Scaffold(
      body: ResponsiveSafeArea(
        child: Obx(
          () {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: responsive.responsiveValue(
                    mobile: 2.w,
                    tablet: 3.w,
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
                        fontSize: responsive.responsiveValue(
                          mobile: 16.sp,
                          tablet: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => controller
                          .loadCommunity(controller.community.value?.id ?? ''),
                      child: ResponsiveText(
                        'Tekrar Dene',
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 14.sp,
                            tablet: 16.sp,
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
                    fontSize: responsive.responsiveValue(
                      mobile: 16.sp,
                      tablet: 18.sp,
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
                SizedBox(height: 24.h),
                _buildStats(community),
                SizedBox(height: 24.h),
                _buildMembershipButton(),
                SizedBox(height: 24.h),
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
                      SizedBox(height: 24.h),
                      _buildStats(community),
                      SizedBox(height: 24.h),
                      _buildMembershipButton(),
                    ],
                  ),
                ),
                SizedBox(width: 32.w),
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
    return SliverAppBar(
      expandedHeight: responsive.responsiveValue(
        mobile: 200.h,
        tablet: 300.h,
      ),
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: ResponsiveText(
          community.name,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 20.sp,
              tablet: 24.sp,
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
              size: responsive.minTouchTarget.sp,
            ),
          ),
      ],
    );
  }

  Widget _buildDescription(dynamic community, BuildContext context) {
    return ResponsiveText(
      community.description,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: responsive.responsiveValue(
              mobile: 16.sp,
              tablet: 18.sp,
            ),
          ),
    );
  }

  Widget _buildStats(dynamic community) {
    return CommunityStatsWidget(community: community);
  }

  Widget _buildMembershipButton() {
    if (controller.isUserModerator.value) return const SizedBox.shrink();

    return Obx(
      () => Center(
        child: ElevatedButton.icon(
          onPressed: controller.isMember.value
              ? controller.leaveCommunity
              : controller.joinCommunity,
          icon: Icon(
            controller.isMember.value ? Icons.exit_to_app : Icons.person_add,
            size: responsive.responsiveValue(
              mobile: 24.sp,
              tablet: 28.sp,
            ),
          ),
          label: ResponsiveText(
            controller.isMember.value ? 'Topluluktan Ayrıl' : 'Topluluğa Katıl',
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 14.sp,
                tablet: 16.sp,
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
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildMembersList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Üyeler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: responsive.responsiveValue(
                  mobile: 20.sp,
                  tablet: 24.sp,
                ),
              ),
        ),
        SizedBox(height: 16.h),
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

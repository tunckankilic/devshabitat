import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/community/community_discovery_controller.dart';
import '../../widgets/community/community_card_widget.dart';
import '../../routes/app_pages.dart';
import '../base/base_view.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveText, ResponsiveSafeArea;
import '../../widgets/responsive/animated_responsive_layout.dart';

class CommunityDiscoveryView extends BaseView<CommunityDiscoveryController> {
  const CommunityDiscoveryView({Key? key}) : super(key: key);

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Toplulukları Keşfet',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18.sp,
              tablet: 22.sp,
            ),
          ),
        ),
        actions: [
          AdaptiveTouchTarget(
            onTap: controller.showFilters,
            child: Icon(
              Icons.filter_list,
              size: responsive.minTouchTarget.sp,
            ),
          ),
          AdaptiveTouchTarget(
            onTap: controller.showSearch,
            child: Icon(
              Icons.search,
              size: responsive.minTouchTarget.sp,
            ),
          ),
        ],
      ),
      body: ResponsiveSafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshCommunities,
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

              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveText(
                        'Hata: ${controller.errorMessage.value}',
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
                        onPressed: controller.refreshCommunities,
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

              if (controller.communities.isEmpty) {
                return Center(
                  child: ResponsiveText(
                    'Henüz topluluk bulunmamaktadır.',
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
                  mobile: _buildMobileCommunityList(),
                  tablet: _buildTabletCommunityGrid(),
                  animationDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.COMMUNITY_CREATE),
        icon: Icon(
          Icons.add,
          size: responsive.responsiveValue(
            mobile: 24.sp,
            tablet: 28.sp,
          ),
        ),
        label: ResponsiveText(
          'Topluluk Oluştur',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 14.sp,
              tablet: 16.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCommunityList() {
    return ListView.builder(
      padding: responsive.responsivePadding(
        top: 8,
        bottom: 16,
      ),
      itemCount: controller.communities.length,
      itemBuilder: (context, index) {
        final community = controller.communities[index];
        return CommunityCardWidget(
          community: community,
          isManageable: controller.isUserModerator(community),
        );
      },
    );
  }

  Widget _buildTabletCommunityGrid() {
    return GridView.builder(
      padding: responsive.responsivePadding(
        all: 24,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5.w,
        crossAxisSpacing: 24.w,
        mainAxisSpacing: 24.h,
      ),
      itemCount: controller.communities.length,
      itemBuilder: (context, index) {
        final community = controller.communities[index];
        return CommunityCardWidget(
          community: community,
          isManageable: controller.isUserModerator(community),
        );
      },
    );
  }
}

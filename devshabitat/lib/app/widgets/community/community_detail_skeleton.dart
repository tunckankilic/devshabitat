import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';
import '../responsive/responsive_safe_area.dart';
import '../responsive/responsive_overflow_handler.dart' hide ResponsiveSafeArea;
import '../responsive/animated_responsive_layout.dart';

class CommunityDetailSkeleton extends StatelessWidget {
  const CommunityDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return ResponsiveSafeArea(
      child: ResponsiveOverflowHandler(
        child: AnimatedResponsiveLayout(
          mobile: _buildMobileSkeleton(responsive),
          tablet: _buildTabletSkeleton(responsive),
          animationDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  Widget _buildMobileSkeleton(ResponsiveController responsive) {
    return CustomScrollView(
      slivers: [
        _buildAppBarSkeleton(responsive),
        SliverToBoxAdapter(
          child: Padding(
            padding: responsive.responsivePadding(all: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDescriptionSkeleton(),
                SizedBox(
                  height: responsive.responsiveValue(mobile: 24, tablet: 32),
                ),
                _buildStatsSkeleton(),
                SizedBox(
                  height: responsive.responsiveValue(mobile: 24, tablet: 32),
                ),
                _buildMembershipButtonSkeleton(),
                SizedBox(
                  height: responsive.responsiveValue(mobile: 24, tablet: 32),
                ),
                _buildMembersListSkeleton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletSkeleton(ResponsiveController responsive) {
    return CustomScrollView(
      slivers: [
        _buildAppBarSkeleton(responsive),
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
                      _buildDescriptionSkeleton(),
                      SizedBox(
                        height: responsive.responsiveValue(
                          mobile: 24,
                          tablet: 32,
                        ),
                      ),
                      _buildStatsSkeleton(),
                      SizedBox(
                        height: responsive.responsiveValue(
                          mobile: 24,
                          tablet: 32,
                        ),
                      ),
                      _buildMembershipButtonSkeleton(),
                    ],
                  ),
                ),
                SizedBox(
                  width: responsive.responsiveValue(mobile: 16, tablet: 32),
                ),
                Expanded(flex: 3, child: _buildMembersListSkeleton()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarSkeleton(ResponsiveController responsive) {
    return SliverAppBar(
      expandedHeight: responsive.responsiveValue(mobile: 200, tablet: 300),
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          width: 120,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        background: Container(color: Colors.grey[200]),
      ),
    );
  }

  Widget _buildDescriptionSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 16,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          width: double.infinity,
          height: 16,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          width: 200,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(3, (index) => _buildStatItemSkeleton()),
    );
  }

  Widget _buildStatItemSkeleton() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipButtonSkeleton() {
    return Center(
      child: Container(
        width: 150,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildMembersListSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 24,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        ...List.generate(
          5,
          (index) => Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

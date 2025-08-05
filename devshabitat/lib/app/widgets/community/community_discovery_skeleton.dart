import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';
import '../responsive/responsive_safe_area.dart';
import '../responsive/responsive_overflow_handler.dart' hide ResponsiveSafeArea;
import '../responsive/animated_responsive_layout.dart';

class CommunityDiscoverySkeleton extends StatelessWidget {
  const CommunityDiscoverySkeleton({super.key});

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
    return ListView.builder(
      padding: responsive.responsivePadding(top: 8, bottom: 16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildCommunityCardSkeleton(responsive),
    );
  }

  Widget _buildTabletSkeleton(ResponsiveController responsive) {
    return GridView.builder(
      padding: responsive.responsivePadding(all: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildCommunityCardSkeleton(responsive),
    );
  }

  Widget _buildCommunityCardSkeleton(ResponsiveController responsive) {
    return Card(
      margin: responsive.responsivePadding(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image skeleton
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),

            // Title skeleton
            Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),

            // Description skeleton
            Container(
              width: double.infinity,
              height: 16,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: 180,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),

            // Stats skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatSkeleton(),
                _buildStatSkeleton(),
                _buildStatSkeleton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSkeleton() {
    return Container(
      width: 60,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

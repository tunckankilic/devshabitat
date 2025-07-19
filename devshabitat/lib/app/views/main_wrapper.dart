import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/responsive_controller.dart';
import 'home/home_view.dart';
import 'discovery/discovery_screen.dart';
import 'messaging/message_view.dart';
import 'profile/profile_view.dart';

class MainWrapper extends StatelessWidget {
  final NavigationController navigationController = Get.find();
  final ResponsiveController responsiveController = Get.find();

  MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (responsiveController.isTablet) {
        return _buildTabletLayout();
      } else {
        return _buildMobileLayout();
      }
    });
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Navigation Rail for tablet
            Obx(() => NavigationRail(
                  selectedIndex: navigationController.currentIndex.value,
                  onDestinationSelected: navigationController.changePage,
                  labelType: NavigationRailLabelType.selected,
                  useIndicator: true,
                  indicatorColor: Get.theme.colorScheme.primaryContainer,
                  backgroundColor: Get.theme.colorScheme.surface,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined,
                          size: responsiveController.minTouchTarget.w),
                      selectedIcon: Icon(Icons.home,
                          size: responsiveController.minTouchTarget.w),
                      label:
                          Text('Ana Sayfa', style: TextStyle(fontSize: 12.sp)),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined,
                          size: responsiveController.minTouchTarget.w),
                      selectedIcon: Icon(Icons.explore,
                          size: responsiveController.minTouchTarget.w),
                      label: Text('Keşfet', style: TextStyle(fontSize: 12.sp)),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.message_outlined,
                          size: responsiveController.minTouchTarget.w),
                      selectedIcon: Icon(Icons.message,
                          size: responsiveController.minTouchTarget.w),
                      label:
                          Text('Mesajlar', style: TextStyle(fontSize: 12.sp)),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline,
                          size: responsiveController.minTouchTarget.w),
                      selectedIcon: Icon(Icons.person,
                          size: responsiveController.minTouchTarget.w),
                      label: Text('Profil', style: TextStyle(fontSize: 12.sp)),
                    ),
                  ],
                )),
            // Main content area
            Expanded(
              child: _buildCurrentPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: navigationController.currentIndex.value,
            onDestinationSelected: navigationController.changePage,
            height: responsiveController.responsiveValue(
              mobile: 80.h,
              tablet: 90.h,
            ),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, size: 24.sp),
                selectedIcon: Icon(Icons.home, size: 24.sp),
                label: 'Ana Sayfa',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined, size: 24.sp),
                selectedIcon: Icon(Icons.explore, size: 24.sp),
                label: 'Keşfet',
              ),
              NavigationDestination(
                icon: Icon(Icons.message_outlined, size: 24.sp),
                selectedIcon: Icon(Icons.message, size: 24.sp),
                label: 'Mesajlar',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, size: 24.sp),
                selectedIcon: Icon(Icons.person, size: 24.sp),
                label: 'Profil',
              ),
            ],
          )),
    );
  }

  Widget _buildCurrentPage() {
    return Obx(() {
      switch (navigationController.currentIndex.value) {
        case 0:
          return const HomeView();
        case 1:
          return const DiscoveryScreen();
        case 2:
          return MessageView();
        case 3:
          return const ProfileView();
        default:
          return const HomeView();
      }
    });
  }
}

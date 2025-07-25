import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                          size: responsiveController.minTouchTarget),
                      selectedIcon: Icon(Icons.home,
                          size: responsiveController.minTouchTarget),
                      label: Text(AppStrings.home,
                          style: TextStyle(
                              fontSize: responsiveController.responsiveValue(
                                  mobile: 12, tablet: 14))),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined,
                          size: responsiveController.minTouchTarget),
                      selectedIcon: Icon(Icons.explore,
                          size: responsiveController.minTouchTarget),
                      label: Text(AppStrings.discover,
                          style: TextStyle(
                              fontSize: responsiveController.responsiveValue(
                                  mobile: 12, tablet: 14))),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.message_outlined,
                          size: responsiveController.minTouchTarget),
                      selectedIcon: Icon(Icons.message,
                          size: responsiveController.minTouchTarget),
                      label: Text(AppStrings.messages,
                          style: TextStyle(
                              fontSize: responsiveController.responsiveValue(
                                  mobile: 12, tablet: 14))),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline,
                          size: responsiveController.minTouchTarget),
                      selectedIcon: Icon(Icons.person,
                          size: responsiveController.minTouchTarget),
                      label: Text(AppStrings.profile,
                          style: TextStyle(
                              fontSize: responsiveController.responsiveValue(
                                  mobile: 12, tablet: 14))),
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
              mobile: 80,
              tablet: 90,
            ),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined,
                    size: responsiveController.responsiveValue(
                        mobile: 24, tablet: 28)),
                selectedIcon: Icon(Icons.home,
                    size: responsiveController.responsiveValue(
                        mobile: 24, tablet: 28)),
                label: 'Ana Sayfa',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined,
                    size: responsiveController.responsiveValue(
                        mobile: 24, tablet: 28)),
                selectedIcon: Icon(Icons.explore,
                    size: responsiveController.responsiveValue(
                        mobile: 24, tablet: 28)),
                label: 'Keşfet',
              ),
              NavigationDestination(
                icon: Icon(Icons.message_outlined,
                    size: responsiveController.responsiveValue(
                        mobile: 24, tablet: 28)),
                selectedIcon: Icon(Icons.message,
                    size: responsiveController.responsiveValue(
                        mobile: 24, tablet: 28)),
                label: 'Mesajlar',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline,
                    size: responsiveController.responsiveValue(
                        mobile: 24, tablet: 28)),
                selectedIcon: Icon(Icons.person,
                    size: responsiveController.responsiveValue(
                        mobile: 24, tablet: 28)),
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

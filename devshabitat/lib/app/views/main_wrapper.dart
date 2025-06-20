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
    return Scaffold(
      body: Obx(() {
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
      }),
      bottomNavigationBar: Obx(() {
        if (responsiveController.isTablet) {
          return NavigationRail(
            selectedIndex: navigationController.currentIndex.value,
            onDestinationSelected: navigationController.changePage,
            labelType: NavigationRailLabelType.selected,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined, size: 24.sp),
                selectedIcon: Icon(Icons.home, size: 24.sp),
                label: Text('Ana Sayfa', style: TextStyle(fontSize: 12.sp)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.explore_outlined, size: 24.sp),
                selectedIcon: Icon(Icons.explore, size: 24.sp),
                label: Text('Keşfet', style: TextStyle(fontSize: 12.sp)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.message_outlined, size: 24.sp),
                selectedIcon: Icon(Icons.message, size: 24.sp),
                label: Text('Mesajlar', style: TextStyle(fontSize: 12.sp)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline, size: 24.sp),
                selectedIcon: Icon(Icons.person, size: 24.sp),
                label: Text('Profil', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          );
        }

        return NavigationBar(
          selectedIndex: navigationController.currentIndex.value,
          onDestinationSelected: navigationController.changePage,
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
        );
      }),
    );
  }
}

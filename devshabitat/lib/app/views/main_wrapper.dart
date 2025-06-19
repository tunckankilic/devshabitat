import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'home/home_view.dart';
import 'profile/profile_view.dart';
import 'search/search_view.dart';
import 'settings/settings_view.dart';

class MainWrapper extends GetView<NavigationController> {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (controller.selectedIndex.value) {
          case 0:
            return const HomeView();
          case 1:
            return const SearchView();
          case 2:
            return const ProfileView();
          case 3:
            return const SettingsView();
          default:
            return const HomeView();
        }
      }),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: controller.changePage,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Ana Sayfa',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Arama',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Ayarlar',
              ),
            ],
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Mevcut seçili index
  final RxInt selectedIndex = 0.obs;

  // NavigationDestination listesi
  final List<NavigationDestination> destinations = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Ana Sayfa',
    ),
    const NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: 'Keşfet',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  // Ekran boyutuna göre navigasyon tipini belirle
  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  // Index değiştirme metodu
  void changePage(int index) {
    selectedIndex.value = index;
  }

  // Responsive navigasyon widget'ı oluşturma
  Widget buildResponsiveNavigation(BuildContext context) {
    if (isTablet(context)) {
      return NavigationRail(
        selectedIndex: selectedIndex.value,
        onDestinationSelected: changePage,
        destinations: destinations
            .map((dest) => NavigationRailDestination(
                  icon: dest.icon,
                  selectedIcon: dest.selectedIcon,
                  label: Text(dest.label),
                ))
            .toList(),
      );
    } else {
      return NavigationBar(
        selectedIndex: selectedIndex.value,
        onDestinationSelected: changePage,
        destinations: destinations,
      );
    }
  }
}

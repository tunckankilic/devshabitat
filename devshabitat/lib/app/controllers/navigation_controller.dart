import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Mevcut seçili index
  final RxInt currentIndex = 0.obs;

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
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  // Responsive navigasyon widget'ı oluşturma
  Widget buildResponsiveNavigation(BuildContext context) {
    if (isTablet(context)) {
      return NavigationRail(
        selectedIndex: currentIndex.value,
        onDestinationSelected: changeIndex,
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
        selectedIndex: currentIndex.value,
        onDestinationSelected: changeIndex,
        destinations: destinations,
      );
    }
  }
}

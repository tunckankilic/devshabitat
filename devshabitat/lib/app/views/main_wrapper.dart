import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/responsive_controller.dart';
import '../services/feature_gate_service.dart';
import '../services/progressive_onboarding_service.dart';
import '../services/user_service.dart';
import '../models/enhanced_user_model.dart';
import 'home/home_view.dart';
import 'discovery/discovery_screen.dart';
import 'messaging/message_view.dart';
import 'profile/profile_view.dart';
import 'networking/developer_matching_view.dart';
import '../controllers/auth_controller.dart';

// Feature'a özel onboarding prompts
class FeaturePromptService {
  static void showGitHubPrompt() {
    if (!_hasGitHub()) {
      Get.dialog(
        AlertDialog(
          title: Text('GitHub Hesabını Bağla'),
          content: Text(
            'Projelini paylaşmak için GitHub hesabını bağlaman gerekiyor. '
            'Bu işlem 30 saniye sürüyor.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Daha Sonra'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/onboarding/github');
              },
              child: Text('Şimdi Bağla'),
            ),
          ],
        ),
      );
    }
  }

  static void showSkillsPrompt() {
    if (!_hasSkills()) {
      Get.bottomSheet(
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎯 Yeteneklerini Ekle', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text(
                  'Sana uygun toplulukları bulmak için yeteneklerini belirtir misin?'),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Geç'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed('/onboarding/skills');
                      },
                      child: Text('Ekle'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      );
    }
  }

  static bool _hasGitHub() {
    final profile = Get.find<AuthController>().userProfile;
    return profile['githubUsername']?.isNotEmpty ?? false;
  }

  static bool _hasSkills() {
    final profile = Get.find<AuthController>().userProfile;
    final skills = profile['skills'] as List?;
    return skills?.isNotEmpty ?? false;
  }
}

class MainWrapper extends StatelessWidget {
  final NavigationController navigationController = Get.find();
  final ResponsiveController responsiveController = Get.find();
  final FeatureGateService featureGateService = FeatureGateService.to;
  final UserService userService = Get.find<UserService>();

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
                      icon: Icon(Icons.favorite_outline,
                          size: responsiveController.minTouchTarget),
                      selectedIcon: Icon(Icons.favorite,
                          size: responsiveController.minTouchTarget),
                      label: Text('Eşleştirme',
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
                icon: Icon(Icons.favorite_outline,
                    size: responsiveController.responsiveValue(
                        mobile: 24, tablet: 28)),
                selectedIcon: Icon(Icons.favorite,
                    size: responsiveController.responsiveValue(
                        mobile: 24, tablet: 28)),
                label: 'Eşleştirme',
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
      final currentUser = userService.currentUser;

      switch (navigationController.currentIndex.value) {
        case 0:
          return const HomeView();
        case 1:
          return const DiscoveryScreen();
        case 2:
          return _buildFeatureGatedPage(
            'networking',
            const DeveloperMatchingView(),
            currentUser,
          );
        case 3:
          return _buildFeatureGatedPage(
            'messaging',
            MessageView(),
            currentUser,
          );
        case 4:
          return const ProfileView();
        default:
          return const HomeView();
      }
    });
  }

  // Feature-gated page wrapper
  Widget _buildFeatureGatedPage(
    String feature,
    Widget page,
    EnhancedUserModel? user,
  ) {
    if (user == null) {
      return page; // Let auth middleware handle
    }

    return featureGateService.gateFeature(
      feature: feature,
      child: page,
      onUpgrade: () => _showUpgradePrompt(feature, user),
      showUpgradePrompt: true,
    );
  }

  // Show upgrade prompt for locked features
  Future<void> _showUpgradePrompt(
      String feature, EnhancedUserModel user) async {
    final result = await ProgressiveOnboardingService.showUpgradePrompt(
      feature,
      user,
    );

    if (result == true) {
      // User completed upgrade, refresh current user
      final authController = Get.find<AuthController>();
      await authController.refreshUserProfile();
    }
  }
}

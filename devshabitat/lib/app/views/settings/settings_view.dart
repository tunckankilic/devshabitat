import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/settings_controller.dart';
import '../../routes/app_pages.dart';
import 'widgets/settings_list_tile.dart';
import '../base/base_view.dart';

import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveText, ResponsiveSafeArea;
import '../../widgets/responsive/animated_responsive_layout.dart';
import '../../services/responsive_performance_service.dart';

class SettingsView extends BaseView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Ayarlar',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 20.sp,
              tablet: 24.sp,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: ResponsiveSafeArea(
        child: ResponsiveOverflowHandler(
          child: AnimatedResponsiveLayout(
            mobile: _buildMobileSettings(context),
            tablet: _buildTabletSettings(context),
            animationDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileSettings(BuildContext context) {
    return ListView(
      padding: responsive.responsivePadding(all: 16),
      children: [
        _buildAppearanceSection(),
        _buildNotificationsSection(),
        _buildLanguageSection(),
        _buildAccountSection(),
      ],
    );
  }

  Widget _buildTabletSettings(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
            maxWidth: responsive.responsiveValue(mobile: 600.w, tablet: 800.w)),
        padding: responsive.responsivePadding(all: 24),
        child: ListView(
          children: [
            SizedBox(
                height: responsive.responsiveValue(mobile: 16.h, tablet: 20.h)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildAppearanceSection(),
                      _buildNotificationsSection(),
                    ],
                  ),
                ),
                SizedBox(
                    width:
                        responsive.responsiveValue(mobile: 24.w, tablet: 32.w)),
                Expanded(
                  child: Column(
                    children: [
                      _buildLanguageSection(),
                      _buildAccountSection(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      'Görünüm',
      [
        Obx(
          () => SettingsListTile(
            title: 'Karanlık Mod',
            icon: Icons.dark_mode,
            trailing: Switch(
              value: controller.isDarkMode.value,
              onChanged: (_) => controller.toggleTheme(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildSection(
      'Bildirimler',
      [
        SettingsListTile(
          title: 'Bildirim Ayarları',
          icon: Icons.notifications_active,
          onTap: () => Get.toNamed(AppRoutes.notificationSettings),
        ),
        Obx(
          () => SettingsListTile(
            title: 'Bildirimleri Etkinleştir',
            icon: Icons.notifications,
            trailing: Switch(
              value: controller.isNotificationsEnabled.value,
              onChanged: (_) => controller.toggleNotifications(),
            ),
          ),
        ),
        Obx(
          () => SettingsListTile(
            title: 'Ses',
            icon: Icons.volume_up,
            trailing: Switch(
              value: controller.isSoundEnabled.value,
              onChanged: (_) => controller.toggleSound(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return _buildSection(
      'Dil',
      [
        Obx(
          () => SettingsListTile(
            title: 'Uygulama Dili',
            subtitle: controller.selectedLanguage.value,
            icon: Icons.language,
            onTap: () => _showLanguageDialog(Get.context!),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      'Hesap',
      [
        SettingsListTile(
          title: 'Çıkış Yap',
          icon: Icons.exit_to_app,
          onTap: () => controller.signOut(),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: performanceService.getOptimizedPadding(
            cacheKey: 'section_padding_$title',
            left: 16,
            top: 16,
            right: 16,
            bottom: 16,
          ),
          child: ResponsiveText(
            title,
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'section_title_$title',
                mobileSize: 14.sp,
                tabletSize: 16.sp,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        Divider(height: responsive.responsiveValue(mobile: 1.h, tablet: 2.h)),
        SizedBox(
            height: responsive.responsiveValue(mobile: 16.h, tablet: 24.h)),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText(
          'Dil Seçin',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18.sp,
              tablet: 20.sp,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.availableLanguages
              .map(
                (language) => ListTile(
                  title: ResponsiveText(
                    language,
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                        mobile: 16.sp,
                        tablet: 18.sp,
                      ),
                    ),
                  ),
                  onTap: () {
                    controller.changeLanguage(language);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
        contentPadding: responsive.responsivePadding(all: 16),
      ),
    );
  }
}

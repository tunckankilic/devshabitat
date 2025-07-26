import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../routes/app_pages.dart';
import '../base/base_view.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/animated_responsive_layout.dart';

class SettingsView extends BaseView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      body: AnimatedResponsiveLayout(
        mobile: _buildMobileSettings(context),
        tablet: _buildTabletSettings(context),
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildMobileSettings(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildModernAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAppearanceCard(context),
                SizedBox(height: 16),
                _buildNotificationsCard(context),
                SizedBox(height: 16),
                _buildLanguageCard(context),
                SizedBox(height: 16),
                _buildAccountCard(context),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletSettings(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildModernAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildAppearanceCard(context),
                      SizedBox(height: 24),
                      _buildNotificationsCard(context),
                    ],
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildLanguageCard(context),
                      SizedBox(height: 24),
                      _buildAccountCard(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: ResponsiveText(
            AppStrings.settings,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required BuildContext context,
    Color? color,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (color ?? Theme.of(context).primaryColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color ?? Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ResponsiveText(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(BuildContext context) {
    return _buildModernCard(
      title: AppStrings.appearance,
      icon: Icons.palette_outlined,
      color: Colors.purple,
      context: context,
      children: [
        Obx(
          () => _buildModernSettingsTile(
            title: AppStrings.darkMode,
            icon: Icons.dark_mode_outlined,
            trailing: Switch.adaptive(
              value: controller.isDarkMode.value,
              onChanged: (_) => controller.toggleTheme(),
              activeColor: Colors.purple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsCard(BuildContext context) {
    return _buildModernCard(
      title: AppStrings.notifications,
      icon: Icons.notifications_outlined,
      color: Colors.orange,
      context: context,
      children: [
        _buildModernSettingsTile(
          title: AppStrings.notificationSettings,
          icon: Icons.settings_outlined,
          subtitle: 'Bildirim ayarlarını yönet',
          onTap: () => Get.toNamed(AppRoutes.notificationSettings),
          showArrow: true,
        ),
        SizedBox(height: 8),
        Obx(
          () => _buildModernSettingsTile(
            title: AppStrings.enableNotifications,
            icon: Icons.notifications_active_outlined,
            trailing: Switch.adaptive(
              value: controller.isNotificationsEnabled.value,
              onChanged: (_) => controller.toggleNotifications(),
              activeColor: Colors.orange,
            ),
          ),
        ),
        SizedBox(height: 8),
        Obx(
          () => _buildModernSettingsTile(
            title: AppStrings.sound,
            icon: Icons.volume_up_outlined,
            trailing: Switch.adaptive(
              value: controller.isSoundEnabled.value,
              onChanged: (_) => controller.toggleSound(),
              activeColor: Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    return _buildModernCard(
      title: AppStrings.language,
      icon: Icons.language_outlined,
      color: Colors.blue,
      context: context,
      children: [
        Obx(
          () => _buildModernSettingsTile(
            title: AppStrings.appLanguage,
            icon: Icons.translate_outlined,
            subtitle: controller.selectedLanguage.value,
            onTap: () => _showLanguageDialog(context),
            showArrow: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return _buildModernCard(
      title: AppStrings.account,
      icon: Icons.person_outline,
      color: Colors.red,
      context: context,
      children: [
        _buildModernSettingsTile(
          title: AppStrings.signOut,
          icon: Icons.exit_to_app_outlined,
          subtitle: 'Hesabınızdan çıkış yapın',
          onTap: () => _showSignOutDialog(context),
          showArrow: true,
          textColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildModernSettingsTile({
    required String title,
    required IconData icon,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showArrow = false,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (textColor ?? Colors.grey[600])!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: textColor ?? Colors.grey[700],
          ),
        ),
        title: ResponsiveText(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.grey[800],
          ),
        ),
        subtitle: subtitle != null
            ? ResponsiveText(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: trailing ??
            (showArrow
                ? Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  )
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.language,
                color: Colors.blue,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            ResponsiveText(
              AppStrings.selectLanguage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.availableLanguages
              .map(
                (language) => Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ListTile(
                    title: ResponsiveText(
                      language,
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: controller.selectedLanguage.value == language
                        ? Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      controller.changeLanguage(language);
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        contentPadding: EdgeInsets.all(20),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_outlined,
                color: Colors.red,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            ResponsiveText(
              'Çıkış Yap',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: ResponsiveText(
          'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ResponsiveText(
              'İptal',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: ResponsiveText(
              'Çıkış Yap',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        contentPadding: EdgeInsets.all(20),
        actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }
}

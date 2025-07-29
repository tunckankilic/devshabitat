import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/device_performance_controller.dart';
import '../../controllers/network_controller.dart';
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
                _buildAppInfoCard(context),
                SizedBox(height: 16),
                _buildDeveloperCard(context),
                SizedBox(height: 16),
                _buildNetworkStatusCard(context),
                SizedBox(height: 16),
                _buildIntegrationsCard(context),
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
                      _buildAppInfoCard(context),
                      SizedBox(height: 24),
                      _buildDeveloperCard(context),
                      SizedBox(height: 24),
                      _buildNetworkStatusCard(context),
                      SizedBox(height: 24),
                      _buildIntegrationsCard(context),
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

  Widget _buildAppInfoCard(BuildContext context) {
    return _buildModernCard(
      title: AppStrings.appInfo,
      icon: Icons.info_outline,
      color: Colors.green,
      context: context,
      children: [
        _buildModernSettingsTile(
          title: AppStrings.appInfo,
          icon: Icons.info_outline,
          subtitle: 'Uygulama ve sistem bilgilerini görüntüle',
          onTap: () => Get.toNamed(AppRoutes.appInfo),
          showArrow: true,
        ),
      ],
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    return _buildModernCard(
      title: 'Geliştirici Seçenekleri',
      icon: Icons.developer_mode,
      color: Colors.purple,
      context: context,
      children: [
        _buildModernSettingsTile(
          title: 'Performance Monitor',
          icon: Icons.speed,
          subtitle: 'Cihaz performansını izle ve optimize et',
          onTap: () => Get.toNamed(AppRoutes.performanceMonitor),
          showArrow: true,
        ),
        SizedBox(height: 8),
        _buildModernSettingsTile(
          title: 'Debug Tools',
          icon: Icons.bug_report,
          subtitle: 'Memory ve performance debug araçları',
          onTap: () => Get.toNamed(AppRoutes.memoryDebug),
          showArrow: true,
        ),
        SizedBox(height: 8),
        _buildModernSettingsTile(
          title: 'Device Performance',
          icon: Icons.device_hub,
          subtitle: 'Detaylı cihaz performans analizi',
          onTap: () => _showDevicePerformanceDialog(context),
          showArrow: true,
        ),
      ],
    );
  }

  Widget _buildIntegrationsCard(BuildContext context) {
    return _buildModernCard(
      title: 'Entegrasyonlar',
      icon: Icons.integration_instructions_outlined,
      color: Colors.indigo,
      context: context,
      children: [
        _buildModernSettingsTile(
          title: 'Entegrasyon Yönetimi',
          icon: Icons.settings_outlined,
          subtitle: 'Third-party servisler ve API bağlantıları',
          onTap: () => Get.toNamed(AppRoutes.integrations),
          showArrow: true,
        ),
        SizedBox(height: 8),
        _buildModernSettingsTile(
          title: 'Servis Durumu',
          icon: Icons.monitor_heart_outlined,
          subtitle: 'Entegrasyon servislerinin durumunu izle',
          onTap: () => _showServiceStatusDialog(context),
          showArrow: true,
        ),
        SizedBox(height: 8),
        _buildModernSettingsTile(
          title: 'Webhook Yönetimi',
          icon: Icons.webhook_outlined,
          subtitle: 'Webhook bağlantılarını yönet',
          onTap: () => _showWebhookManagementDialog(context),
          showArrow: true,
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
          title: AppStrings.security,
          icon: Icons.security_outlined,
          subtitle: 'Güvenlik ayarlarını yönet',
          onTap: () => Get.toNamed(AppRoutes.authSecurity),
          showArrow: true,
        ),
        SizedBox(height: 8),
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

  void _showDevicePerformanceDialog(BuildContext context) {
    try {
      final deviceController = Get.find<DevicePerformanceController>();
      final status = deviceController.getDeviceStatus();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.device_hub,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              ResponsiveText(
                'Cihaz Performansı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: status.entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ResponsiveText(
                              entry.key.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                          ResponsiveText(
                            entry.value.toString(),
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: ResponsiveText(
                'Kapat',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                deviceController.optimizePerformance();
                Get.snackbar(
                  'Optimizasyon',
                  'Performans optimizasyonu başlatıldı',
                  backgroundColor: Colors.green.withOpacity(0.8),
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: ResponsiveText(
                'Optimize Et',
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
    } catch (e) {
      Get.snackbar(
        'Hata',
        'DevicePerformanceController bulunamadı',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _showServiceStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.monitor_heart,
                color: Colors.indigo,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            ResponsiveText(
              'Servis Durumu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildServiceStatusItem('Video-Etkinlik Entegrasyonu', 'Aktif',
                Icons.video_call, Colors.green),
            SizedBox(height: 8),
            _buildServiceStatusItem('Topluluk-Etkinlik Entegrasyonu', 'Aktif',
                Icons.group, Colors.blue),
            SizedBox(height: 8),
            _buildServiceStatusItem('Konum-Etkinlik Entegrasyonu', 'Aktif',
                Icons.location_on, Colors.orange),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ResponsiveText(
              'Kapat',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        ],
        contentPadding: EdgeInsets.all(20),
        actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  void _showWebhookManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.webhook,
                color: Colors.teal,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            ResponsiveText(
              'Webhook Yönetimi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWebhookItem('Etkinlik Webhook',
                'https://api.example.com/events', Icons.event, true),
            SizedBox(height: 8),
            _buildWebhookItem('Topluluk Webhook',
                'https://api.example.com/communities', Icons.group, true),
            SizedBox(height: 8),
            _buildWebhookItem('Kullanıcı Webhook',
                'https://api.example.com/users', Icons.person, false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ResponsiveText(
              'Kapat',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.integrations);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: ResponsiveText(
              'Yönet',
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

  Widget _buildServiceStatusItem(
    String name,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: ResponsiveText(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ResponsiveText(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebhookItem(
    String name,
    String url,
    IconData icon,
    bool isActive,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ResponsiveText(
                  url,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isActive,
            onChanged: (value) {
              Get.snackbar(
                'Webhook Durumu',
                '$name webhook\'u ${value ? 'aktif' : 'pasif'} yapıldı',
                backgroundColor: value
                    ? Colors.green.withOpacity(0.8)
                    : Colors.orange.withOpacity(0.8),
                colorText: Colors.white,
              );
            },
            activeColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusCard(BuildContext context) {
    return _buildModernCard(
      title: 'Bağlantı Durumu',
      icon: Icons.wifi,
      color: Colors.blue,
      context: context,
      children: [
        _buildModernSettingsTile(
          title: 'Ağ Durumu',
          icon: Icons.network_check,
          subtitle: 'Bağlantı durumunu izle ve yönet',
          onTap: () => Get.toNamed(AppRoutes.networkStatus),
          showArrow: true,
        ),
        SizedBox(height: 8),
        Obx(() {
          final networkController = Get.find<NetworkController>();
          final isConnected = networkController.isConnected;
          return _buildModernSettingsTile(
            title: 'Bağlantı Durumu',
            icon: Icons.wifi,
            subtitle: isConnected ? 'Bağlı' : 'Bağlantı Yok',
            trailing: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isConnected ? Colors.green : Colors.red,
              ),
            ),
          );
        }),
        SizedBox(height: 8),
        Obx(() {
          final networkController = Get.find<NetworkController>();
          final connectionType = networkController.connectionType;
          return _buildModernSettingsTile(
            title: 'Bağlantı Tipi',
            icon: Icons.network_wifi,
            subtitle: _getConnectionTypeText(connectionType),
            trailing: Icon(
              _getConnectionTypeIcon(connectionType),
              color: _getConnectionTypeColor(connectionType),
              size: 20,
            ),
          );
        }),
      ],
    );
  }

  String _getConnectionTypeText(dynamic connectionType) {
    switch (connectionType) {
      case 'wifi':
        return 'Wi-Fi';
      case 'mobile':
        return 'Mobil Veri';
      case 'ethernet':
        return 'Ethernet';
      case 'none':
        return 'Bağlantı Yok';
      default:
        return 'Bilinmiyor';
    }
  }

  IconData _getConnectionTypeIcon(dynamic connectionType) {
    switch (connectionType) {
      case 'wifi':
        return Icons.wifi;
      case 'mobile':
        return Icons.cell_tower;
      case 'ethernet':
        return Icons.router;
      case 'none':
        return Icons.signal_wifi_off;
      default:
        return Icons.help_outline;
    }
  }

  Color _getConnectionTypeColor(dynamic connectionType) {
    switch (connectionType) {
      case 'wifi':
        return Colors.blue;
      case 'mobile':
        return Colors.green;
      case 'ethernet':
        return Colors.purple;
      case 'none':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import 'widgets/settings_list_tile.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: TextStyle(
            fontSize: isLargeScreen ? 24.0 : 20.0,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 800 : double.infinity,
              ),
              child: ListView(
                children: [
                  if (isLargeScreen) const SizedBox(height: 20),
                  _buildSection(
                    'Görünüm',
                    [
                      Obx(
                        () => SettingsListTile(
                          title: 'Karanlık Mod',
                          icon: Icons.dark_mode,
                          isLargeScreen: isLargeScreen,
                          trailing: Switch(
                            value: controller.isDarkMode.value,
                            onChanged: (_) => controller.toggleTheme(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildSection(
                    'Bildirimler',
                    [
                      Obx(
                        () => SettingsListTile(
                          title: 'Bildirimleri Etkinleştir',
                          icon: Icons.notifications,
                          isLargeScreen: isLargeScreen,
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
                          isLargeScreen: isLargeScreen,
                          trailing: Switch(
                            value: controller.isSoundEnabled.value,
                            onChanged: (_) => controller.toggleSound(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildSection(
                    'Dil',
                    [
                      Obx(
                        () => SettingsListTile(
                          title: 'Uygulama Dili',
                          subtitle: controller.selectedLanguage.value,
                          icon: Icons.language,
                          isLargeScreen: isLargeScreen,
                          onTap: () => _showLanguageDialog(context),
                        ),
                      ),
                    ],
                  ),
                  _buildSection(
                    'Hesap',
                    [
                      SettingsListTile(
                        title: 'Çıkış Yap',
                        icon: Icons.exit_to_app,
                        isLargeScreen: isLargeScreen,
                        onTap: () => controller.signOut(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.availableLanguages
              .map(
                (language) => ListTile(
                  title: Text(language),
                  onTap: () {
                    controller.changeLanguage(language);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

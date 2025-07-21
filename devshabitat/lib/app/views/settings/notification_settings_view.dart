import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/notification_service.dart';

class NotificationSettingsView extends GetView<NotificationService> {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Genel Ayarlar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildGeneralSettings(),
              const SizedBox(height: 24),
              const Text(
                'Bildirim Kategorileri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildCategorySettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Column(
        children: [
          Obx(
            () => SwitchListTile(
              title: const Text('Push Bildirimleri'),
              subtitle: const Text('Uygulama kapalıyken bildirim al'),
              value: controller.isPushEnabled.value,
              onChanged: (value) => controller.updatePushPreference(value),
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: const Text('Uygulama İçi Bildirimler'),
              subtitle: const Text('Uygulama açıkken bildirim al'),
              value: controller.isInAppEnabled.value,
              onChanged: (value) => controller.updateInAppPreference(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySettings() {
    return Card(
      child: Column(
        children: [
          Obx(
            () => SwitchListTile(
              title: const Text('Etkinlik Bildirimleri'),
              subtitle: const Text('Yeni etkinlikler ve güncellemeler'),
              value: controller.categoryPreferences['events']?.value ?? true,
              onChanged: (value) =>
                  controller.updateCategoryPreference('events', value),
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: const Text('Mesaj Bildirimleri'),
              subtitle: const Text('Yeni mesajlar ve yanıtlar'),
              value: controller.categoryPreferences['messages']?.value ?? true,
              onChanged: (value) =>
                  controller.updateCategoryPreference('messages', value),
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: const Text('Topluluk Bildirimleri'),
              subtitle: const Text('Topluluk etkinlikleri ve duyurular'),
              value: controller.categoryPreferences['community']?.value ?? true,
              onChanged: (value) =>
                  controller.updateCategoryPreference('community', value),
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: const Text('Bağlantı Bildirimleri'),
              subtitle: const Text('Yeni bağlantı istekleri ve güncellemeler'),
              value:
                  controller.categoryPreferences['connections']?.value ?? true,
              onChanged: (value) =>
                  controller.updateCategoryPreference('connections', value),
            ),
          ),
        ],
      ),
    );
  }
}

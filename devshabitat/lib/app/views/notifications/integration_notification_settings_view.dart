import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/integration/notification_controller.dart';

class IntegrationNotificationSettingsView
    extends GetView<IntegrationNotificationController> {
  const IntegrationNotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entegrasyon Bildirim Ayarları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () => _showTestNotificationDialog(context),
            tooltip: 'Test Bildirimi Gönder',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Genel Ayarlar'),
            _buildGeneralSettings(),
            const SizedBox(height: 24),
            _buildSectionHeader('Entegrasyon Durumu'),
            _buildIntegrationStatus(),
            const SizedBox(height: 24),
            _buildSectionHeader('Özel Kurallar'),
            _buildCustomRules(),
            const SizedBox(height: 24),
            _buildSectionHeader('Bildirim İstatistikleri'),
            _buildNotificationStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingTile(
              title: 'Entegrasyon Bildirimleri',
              subtitle: 'Entegrasyon ile ilgili bildirimleri al',
              value: controller.isIntegrationNotificationsEnabled,
              onChanged: controller.updateIntegrationNotificationSetting,
              icon: Icons.integration_instructions,
            ),
            const Divider(),
            _buildSettingTile(
              title: 'Webhook Bildirimleri',
              subtitle: 'Webhook olayları hakkında bildirim al',
              value: controller.isWebhookNotificationsEnabled,
              onChanged: controller.updateWebhookNotificationSetting,
              icon: Icons.webhook,
            ),
            const Divider(),
            _buildSettingTile(
              title: 'Servis Uyarıları',
              subtitle: 'Sistem ve servis uyarılarını al',
              value: controller.isServiceAlertsEnabled,
              onChanged: controller.updateServiceAlertSetting,
              icon: Icons.warning,
            ),
            const Divider(),
            _buildSettingTile(
              title: 'Özel Kurallar',
              subtitle: 'Özel bildirim kurallarını etkinleştir',
              value: controller.isCustomRulesEnabled,
              onChanged: controller.updateCustomRulesSetting,
              icon: Icons.rule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required RxBool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Obx(
      () => ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value.value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildIntegrationStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildIntegrationStatusTile(
              'GitHub',
              controller.isGitHubConnected,
              Icons.code,
              Colors.black,
            ),
            const Divider(),
            _buildIntegrationStatusTile(
              'Slack',
              controller.isSlackConnected,
              Icons.chat,
              Colors.purple,
            ),
            const Divider(),
            _buildIntegrationStatusTile(
              'Discord',
              controller.isDiscordConnected,
              Icons.discord,
              Colors.indigo,
            ),
            const Divider(),
            _buildIntegrationStatusTile(
              'Email',
              controller.isEmailConnected,
              Icons.email,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationStatusTile(
    String name,
    RxBool isConnected,
    IconData icon,
    Color color,
  ) {
    return Obx(
      () => ListTile(
        leading: Icon(icon, color: color),
        title: Text(name),
        subtitle: Text(
          isConnected.value ? 'Bağlı' : 'Bağlı Değil',
          style: TextStyle(
            color: isConnected.value ? Colors.green : Colors.red,
          ),
        ),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isConnected.value ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRules() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Özel Bildirim Kuralları',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextButton.icon(
                  onPressed: () => _showAddRuleDialog(Get.context!),
                  icon: const Icon(Icons.add),
                  label: const Text('Kural Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(
              () => controller.customRules.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Henüz özel kural eklenmemiş',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.customRules.length,
                      itemBuilder: (context, index) {
                        final rule = controller.customRules[index];
                        return ListTile(
                          title: Text(rule['name'] ?? 'Kural ${index + 1}'),
                          subtitle: Text(rule['description'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => controller.removeCustomRule(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Toplam',
                      controller
                          .getAllIntegrationNotifications()
                          .length
                          .toString(),
                      Icons.notifications,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Okunmamış',
                      controller.getUnreadIntegrationCount().toString(),
                      Icons.mark_email_unread,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _buildStatCard(
                      'Entegrasyon',
                      controller.integrationNotifications.length.toString(),
                      Icons.integration_instructions,
                      Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => _buildStatCard(
                      'Webhook',
                      controller.webhookNotifications.length.toString(),
                      Icons.webhook,
                      Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _buildStatCard(
                      'Servis Uyarıları',
                      controller.serviceAlerts.length.toString(),
                      Icons.warning,
                      Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.markAllIntegrationNotificationsAsRead,
                    icon: const Icon(Icons.done_all),
                    label: const Text('Tümünü Okundu İşaretle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showTestNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Bildirimi Gönder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.integration_instructions,
                  color: Colors.blue),
              title: const Text('GitHub Entegrasyonu'),
              onTap: () {
                controller.sendTestIntegrationNotification(
                  title: 'GitHub Entegrasyon Testi',
                  body: 'GitHub entegrasyonu başarıyla test edildi',
                  integrationType: 'github',
                );
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.webhook, color: Colors.orange),
              title: const Text('Webhook Testi'),
              onTap: () {
                controller.sendTestIntegrationNotification(
                  title: 'Webhook Testi',
                  body: 'Yeni webhook olayı alındı',
                  integrationType: 'webhook',
                  additionalData: {'webhookId': 'test-123'},
                );
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('Servis Uyarısı'),
              onTap: () {
                controller.sendTestIntegrationNotification(
                  title: 'Servis Uyarısı',
                  body: 'Sistem bakımı planlanıyor',
                  integrationType: 'service_alert',
                  additionalData: {
                    'serviceName': 'API Gateway',
                    'alertType': 'maintenance',
                  },
                );
                Get.back();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _showAddRuleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kural Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Kural Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.addCustomRule({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'createdAt': DateTime.now().toIso8601String(),
                });
                Get.back();
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
}

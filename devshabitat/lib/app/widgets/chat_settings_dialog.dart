import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/services/chat_export_service.dart';
import 'package:devshabitat/app/controllers/chat_management_controller.dart';
import 'package:devshabitat/app/models/message_model.dart';

class ChatSettingsDialog extends StatelessWidget {
  final String conversationId;
  final String conversationTitle;
  final List<MessageModel> messages;
  final bool isArchived;
  final bool notificationsEnabled;
  final VoidCallback? onNotificationToggle;
  final VoidCallback? onArchiveToggle;
  final VoidCallback? onBlock;
  final VoidCallback? onReport;

  const ChatSettingsDialog({
    super.key,
    required this.conversationId,
    required this.conversationTitle,
    required this.messages,
    this.isArchived = false,
    this.notificationsEnabled = true,
    this.onNotificationToggle,
    this.onArchiveToggle,
    this.onBlock,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final exportService = Get.find<ChatExportService>();
    final chatController = Get.find<ChatManagementController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sohbet Ayarları',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Dışa Aktarma Seçenekleri
            _buildSectionTitle(context, 'Dışa Aktarma'),
            const SizedBox(height: 8),

            Obx(() => exportService.isExporting
                ? _buildExportProgress(exportService.exportProgress)
                : Column(
                    children: [
                      _buildExportOption(
                        icon: Icons.code,
                        title: 'JSON olarak dışa aktar',
                        subtitle: 'Teknik format, veri analizi için uygun',
                        onTap: () => _exportToJson(exportService),
                      ),
                      _buildExportOption(
                        icon: Icons.table_chart,
                        title: 'CSV olarak dışa aktar',
                        subtitle: 'Excel\'de açılabilir tablo formatı',
                        onTap: () => _exportToCsv(exportService),
                      ),
                    ],
                  )),

            const Divider(height: 32),

            // Sohbet Yönetimi
            _buildSectionTitle(context, 'Sohbet Yönetimi'),
            const SizedBox(height: 8),

            _buildSettingsTile(
              icon: isArchived ? Icons.unarchive : Icons.archive,
              title: isArchived ? 'Arşivden çıkar' : 'Arşivle',
              subtitle: isArchived
                  ? 'Sohbeti ana listeye geri getir'
                  : 'Sohbeti arşive taşı',
              onTap: onArchiveToggle,
            ),

            _buildSettingsTile(
              icon: notificationsEnabled
                  ? Icons.notifications_off
                  : Icons.notifications,
              title: notificationsEnabled
                  ? 'Bildirimleri kapat'
                  : 'Bildirimleri aç',
              subtitle: notificationsEnabled
                  ? 'Bu sohbet için bildirimleri devre dışı bırak'
                  : 'Bu sohbet için bildirimleri etkinleştir',
              onTap: onNotificationToggle,
            ),

            const Divider(height: 32),

            // Gizlilik Kontrolleri
            _buildSectionTitle(context, 'Gizlilik'),
            const SizedBox(height: 8),

            _buildSettingsTile(
              icon: Icons.block,
              title: 'Engelle',
              subtitle: 'Bu kullanıcıyı engelle',
              textColor: Colors.orange,
              onTap: onBlock,
            ),

            _buildSettingsTile(
              icon: Icons.report,
              title: 'Şikayet et',
              subtitle: 'Bu sohbeti uygunsuz içerik için bildir',
              textColor: Colors.red,
              onTap: onReport,
            ),

            const Divider(height: 32),

            // Tehlikeli İşlemler
            _buildSectionTitle(context, 'Tehlikeli İşlemler'),
            const SizedBox(height: 8),

            _buildSettingsTile(
              icon: Icons.delete_forever,
              title: 'Sohbeti sil',
              subtitle: 'Bu işlem geri alınamaz',
              textColor: Colors.red,
              onTap: () => _showDeleteConfirmation(chatController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.download),
        onTap: onTap,
      ),
    );
  }

  Widget _buildExportProgress(double progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Dışa aktarılıyor...'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('${(progress * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  Future<void> _exportToJson(ChatExportService exportService) async {
    Get.back();
    await exportService.exportToJson(
      conversationId: conversationId,
      messages: messages,
      title: conversationTitle,
    );
  }

  Future<void> _exportToCsv(ChatExportService exportService) async {
    Get.back();
    await exportService.exportToCsv(
      conversationId: conversationId,
      messages: messages,
      title: conversationTitle,
    );
  }

  void _showDeleteConfirmation(ChatManagementController chatController) {
    Get.back();
    Get.dialog(
      AlertDialog(
        title: const Text('Sohbeti Sil'),
        content: const Text(
          'Bu sohbeti kalıcı olarak silmek istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await chatController.deleteChat(conversationId);
              Get.back(); // Ana sayfaya geri dön
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Statik metodlar kullanım kolaylığı için
  static void show({
    required String conversationId,
    required String conversationTitle,
    required List<MessageModel> messages,
    bool isArchived = false,
    bool notificationsEnabled = true,
    VoidCallback? onNotificationToggle,
    VoidCallback? onArchiveToggle,
    VoidCallback? onBlock,
    VoidCallback? onReport,
  }) {
    Get.dialog(
      ChatSettingsDialog(
        conversationId: conversationId,
        conversationTitle: conversationTitle,
        messages: messages,
        isArchived: isArchived,
        notificationsEnabled: notificationsEnabled,
        onNotificationToggle: onNotificationToggle,
        onArchiveToggle: onArchiveToggle,
        onBlock: onBlock,
        onReport: onReport,
      ),
    );
  }
}

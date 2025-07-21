import 'package:devshabitat/app/constants/app_strings.dart';
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
                    AppStrings.chatSettings,
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
            _buildSectionTitle(context, AppStrings.export),
            const SizedBox(height: 8),

            Obx(() => exportService.isExporting
                ? _buildExportProgress(exportService.exportProgress)
                : Column(
                    children: [
                      _buildExportOption(
                        icon: Icons.code,
                        title: AppStrings.exportJson,
                        subtitle: AppStrings.exportJsonSubtitle,
                        onTap: () => _exportToJson(exportService),
                      ),
                      _buildExportOption(
                        icon: Icons.table_chart,
                        title: AppStrings.exportCsv,
                        subtitle: AppStrings.exportCsvSubtitle,
                        onTap: () => _exportToCsv(exportService),
                      ),
                    ],
                  )),

            const Divider(height: 32),

            // Sohbet Yönetimi
            _buildSectionTitle(context, AppStrings.chatManagement),
            const SizedBox(height: 8),

            _buildSettingsTile(
              icon: isArchived ? Icons.unarchive : Icons.archive,
              title: isArchived ? AppStrings.unarchive : AppStrings.archive,
              subtitle:
                  isArchived ? AppStrings.returnToMainList : AppStrings.archive,
              onTap: onArchiveToggle,
            ),

            _buildSettingsTile(
              icon: notificationsEnabled
                  ? Icons.notifications_off
                  : Icons.notifications,
              title: notificationsEnabled
                  ? AppStrings.disableNotifications
                  : AppStrings.enableNotifications,
              subtitle: notificationsEnabled
                  ? AppStrings.disableNotificationsSubtitle
                  : AppStrings.enableNotificationsSubtitle,
              onTap: onNotificationToggle,
            ),

            const Divider(height: 32),

            // Gizlilik Kontrolleri
            _buildSectionTitle(context, AppStrings.privacy),
            const SizedBox(height: 8),

            _buildSettingsTile(
              icon: Icons.block,
              title: AppStrings.block,
              subtitle: AppStrings.blockSubtitle,
              textColor: Colors.orange,
              onTap: onBlock,
            ),

            _buildSettingsTile(
              icon: Icons.report,
              title: AppStrings.report,
              subtitle: AppStrings.reportSubtitle,
              textColor: Colors.red,
              onTap: onReport,
            ),

            const Divider(height: 32),

            // Tehlikeli İşlemler
            _buildSectionTitle(context, AppStrings.dangerousOperations),
            const SizedBox(height: 8),

            _buildSettingsTile(
              icon: Icons.delete_forever,
              title: AppStrings.deleteChat,
              subtitle: AppStrings.deleteChatSubtitle,
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
            const Text(AppStrings.exporting),
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
        title: const Text(AppStrings.deleteChat),
        content: const Text(
          AppStrings.deleteChatSubtitle,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await chatController.deleteChat(conversationId);
              Get.back(); // Ana sayfaya geri dön
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppStrings.delete,
                style: TextStyle(color: Colors.white)),
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

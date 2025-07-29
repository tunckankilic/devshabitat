import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_strings.dart';
import '../../controllers/chat_management_controller.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../base/base_view.dart';

class ChatManagementView extends BaseView<ChatManagementController> {
  const ChatManagementView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          AppStrings.chatManagement,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
      ),
      body: ResponsiveSafeArea(
        child: Obx(() {
          return Column(
            children: [
              _buildMemoryUsageCard(),
              Expanded(
                child: _buildManagementOptions(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMemoryUsageCard() {
    return Card(
      margin: responsive.responsivePadding(all: 16),
      child: Padding(
        padding: responsive.responsivePadding(all: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              AppStrings.memoryUsage,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: controller.memoryUsage / 100, // Normalize to 0-1
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                controller.memoryUsage > 80 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            ResponsiveText(
              '${controller.memoryUsage.toStringAsFixed(2)} MB',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOptions() {
    return ListView(
      padding: responsive.responsivePadding(all: 16),
      children: [
        _buildManagementTile(
          icon: Icons.archive,
          title: AppStrings.archiveChats,
          subtitle: AppStrings.archiveChatsDesc,
          onTap: () => _showArchiveDialog(),
        ),
        _buildManagementTile(
          icon: Icons.import_export,
          title: AppStrings.exportChats,
          subtitle: AppStrings.exportChatsDesc,
          onTap: () => _showExportDialog(),
        ),
        _buildManagementTile(
          icon: Icons.delete_forever,
          title: AppStrings.deleteChats,
          subtitle: AppStrings.deleteChatsDesc,
          onTap: () => _showDeleteDialog(),
        ),
      ],
    );
  }

  Widget _buildManagementTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: responsive.responsivePadding(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          size: responsive.responsiveValue(mobile: 24, tablet: 32),
          color: Theme.of(Get.context!).primaryColor,
        ),
        title: ResponsiveText(
          title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
          ),
        ),
        subtitle: ResponsiveText(
          subtitle,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 14,
              tablet: 16,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showArchiveDialog() {
    // Arşivleme dialog'u implementasyonu
  }

  void _showExportDialog() {
    // Dışa aktarma dialog'u implementasyonu
  }

  void _showDeleteDialog() {
    // Silme dialog'u implementasyonu
  }
}

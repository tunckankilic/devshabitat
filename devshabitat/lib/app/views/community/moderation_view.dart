import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/views/auth/widgets/adaptive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/moderation_controller.dart';
import '../../models/community/moderation_model.dart';

class ModerationView extends GetView<ModerationController> {
  const ModerationView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.moderation),
          bottom: const TabBar(
            tabs: [
              Tab(text: AppStrings.pending),
              Tab(text: AppStrings.completed),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPendingModerations(),
            _buildResolvedModerations(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingModerations() {
    return Obx(
      () => controller.isLoading.value
          ? Center(child: AdaptiveLoadingIndicator())
          : ListView.builder(
              itemCount: controller.pendingModerations.length,
              itemBuilder: (context, index) {
                final moderation = controller.pendingModerations[index];
                return _buildModerationCard(moderation);
              },
            ),
    );
  }

  Widget _buildResolvedModerations() {
    return Obx(
      () => controller.isLoading.value
          ? Center(child: AdaptiveLoadingIndicator())
          : ListView.builder(
              itemCount: controller.resolvedModerations.length,
              itemBuilder: (context, index) {
                final moderation = controller.resolvedModerations[index];
                return _buildModerationCard(moderation);
              },
            ),
    );
  }

  Widget _buildModerationCard(ModerationModel moderation) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusChip(moderation.status),
                const Spacer(),
                Text(
                  moderation.createdAt.toString(),
                  style: Get.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.contentType}: ${_getContentTypeText(moderation.contentType)}',
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${AppStrings.reason}: ${controller.getModerationReasonText(moderation.reason)}',
              style: Get.textTheme.bodyMedium,
            ),
            if (moderation.customReason != null) ...[
              const SizedBox(height: 4),
              Text(
                '${AppStrings.description}: ${moderation.customReason}',
                style: Get.textTheme.bodyMedium,
              ),
            ],
            if (moderation.note != null) ...[
              const SizedBox(height: 4),
              Text(
                '${AppStrings.note}: ${moderation.note}',
                style: Get.textTheme.bodyMedium,
              ),
            ],
            if (moderation.status == ModerationStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showModerationDialog(moderation),
                    child: Text(AppStrings.process),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ModerationStatus status) {
    Color color;
    switch (status) {
      case ModerationStatus.pending:
        color = Colors.orange;
        break;
      case ModerationStatus.approved:
        color = Colors.green;
        break;
      case ModerationStatus.rejected:
        color = Colors.red;
        break;
      case ModerationStatus.deleted:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        controller.getModerationStatusText(status),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  void _showModerationDialog(ModerationModel moderation) {
    final noteController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.moderationProcess,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: AppStrings.note,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    label: AppStrings.warn,
                    icon: Icons.warning,
                    color: Colors.orange,
                    onPressed: () => _handleModeration(
                      moderation,
                      ModerationAction.warn,
                      noteController.text,
                    ),
                  ),
                  _buildActionButton(
                    label: AppStrings.delete,
                    icon: Icons.delete,
                    color: Colors.red,
                    onPressed: () => _handleModeration(
                      moderation,
                      ModerationAction.delete,
                      noteController.text,
                    ),
                  ),
                  _buildActionButton(
                    label: AppStrings.ban,
                    icon: Icons.block,
                    color: Colors.purple,
                    onPressed: () => _handleModeration(
                      moderation,
                      ModerationAction.ban,
                      noteController.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    label: AppStrings.mute,
                    icon: Icons.volume_off,
                    color: Colors.blue,
                    onPressed: () => _handleModeration(
                      moderation,
                      ModerationAction.mute,
                      noteController.text,
                    ),
                  ),
                  _buildActionButton(
                    label: AppStrings.approve,
                    icon: Icons.check_circle,
                    color: Colors.green,
                    onPressed: () => _handleModeration(
                      moderation,
                      ModerationAction.approve,
                      noteController.text,
                    ),
                  ),
                  _buildActionButton(
                    label: AppStrings.reject,
                    icon: Icons.cancel,
                    color: Colors.red,
                    onPressed: () => _handleModeration(
                      moderation,
                      ModerationAction.reject,
                      noteController.text,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          color: color,
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _handleModeration(
    ModerationModel moderation,
    ModerationAction action,
    String? note,
  ) {
    Get.back();
    controller.moderateContent(
      moderationId: moderation.id,
      action: action,
      note: note,
    );
  }

  String _getContentTypeText(ContentType type) {
    switch (type) {
      case ContentType.post:
        return AppStrings.post;
      case ContentType.comment:
        return AppStrings.comment;
      case ContentType.event:
        return AppStrings.event;
      case ContentType.resource:
        return AppStrings.resource;
      case ContentType.profile:
        return AppStrings.profile;
    }
  }
}

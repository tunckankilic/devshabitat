import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../widgets/in_app_notification_widget.dart';

class NotificationCenterView extends GetView<NotificationController> {
  const NotificationCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: controller.markAllAsRead,
            tooltip: AppStrings.markAllAsRead,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'filter':
                  _showFilterDialog(context);
                  break;
                case 'settings':
                  Get.toNamed('/notification-settings');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: ListTile(
                  leading: Icon(Icons.filter_list),
                  title: Text(AppStrings.filter),
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(AppStrings.settings),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: controller.refreshNotifications,
                    child: ListView.builder(
                      itemCount: controller.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = controller.notifications[index];
                        return InAppNotificationWidget(
                          notification: notification,
                          onTap: () {
                            controller.handleNotificationTap(notification);
                          },
                          onDismiss: () {
                            controller.deleteNotification(notification.id);
                          },
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noNotifications,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.newNotificationsWillAppearHere,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.filterNotifications),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(AppStrings.all, 'all'),
            _buildFilterOption(AppStrings.unread, 'unread'),
            _buildFilterOption(AppStrings.messages, 'message'),
            _buildFilterOption(AppStrings.events, 'event'),
            _buildFilterOption(AppStrings.communities, 'community'),
            _buildFilterOption(AppStrings.connections, 'connection'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, String value) {
    return Obx(
      () => RadioListTile<String>(
        title: Text(title),
        value: value,
        groupValue: controller.currentFilter.value,
        onChanged: (value) {
          controller.updateFilter(value!);
          Get.back();
        },
      ),
    );
  }
}

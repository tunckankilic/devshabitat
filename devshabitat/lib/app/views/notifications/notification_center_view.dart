import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../widgets/in_app_notification_widget.dart';

class NotificationCenterView extends GetView<NotificationController> {
  const NotificationCenterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: controller.markAllAsRead,
            tooltip: 'Tümünü okundu işaretle',
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
                  title: Text('Filtrele'),
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Ayarlar'),
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
            'Henüz bildiriminiz yok',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bildirimler burada görünecek',
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
        title: const Text('Bildirimleri Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('Tümü', 'all'),
            _buildFilterOption('Okunmamış', 'unread'),
            _buildFilterOption('Mesajlar', 'message'),
            _buildFilterOption('Etkinlikler', 'event'),
            _buildFilterOption('Topluluk', 'community'),
            _buildFilterOption('Bağlantılar', 'connection'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Kapat'),
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

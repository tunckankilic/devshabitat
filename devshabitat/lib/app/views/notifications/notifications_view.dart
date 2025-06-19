import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class NotificationsView extends GetView<HomeController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              controller.markAllNotificationsAsRead();
            },
          ),
        ],
      ),
      body: Obx(() => ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.notifications),
                ),
                title: Text(notification.title),
                subtitle: Text(notification.body),
                trailing: Text(
                    '${notification.createdAt.difference(DateTime.now()).inHours.abs()} saat önce'),
              );
            },
          )),
    );
  }
}

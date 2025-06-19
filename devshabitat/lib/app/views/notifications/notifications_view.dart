import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class NotificationsView extends GetView<HomeController> {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              // TODO: Tüm bildirimleri okundu olarak işaretle
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 0, // TODO: Bildirim listesi eklenecek
        itemBuilder: (context, index) {
          return const ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.notifications),
            ),
            title: Text('Bildirim Başlığı'),
            subtitle: Text('Bildirim Açıklaması'),
            trailing: Text('2 saat önce'),
          );
        },
      ),
    );
  }
}

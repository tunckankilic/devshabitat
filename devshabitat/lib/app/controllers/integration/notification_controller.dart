// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../routes/app_pages.dart';

class NotificationController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Bildirim izinlerini iste
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Foreground mesajları için
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Background/terminated mesajları için
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Initial message kontrolü
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleInitialMessage(initialMessage);
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      Get.snackbar(
        message.notification!.title ?? 'Yeni Bildirim',
        message.notification!.body ?? '',
        duration: Duration(seconds: 5),
        onTap: (_) => _handleNotificationTap(message.data),
      );
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    _handleNotificationTap(message.data);
  }

  void _handleInitialMessage(RemoteMessage message) {
    _handleNotificationTap(message.data);
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    if (data['route'] != null) {
      String route = data['route'];

      // Deep linking yönetimi
      switch (data['type']) {
        case 'community_event':
          Get.toNamed(
            AppRoutes.EVENT_DETAIL,
            arguments: {
              'eventId': data['eventId'],
              'communityId': data['communityId'],
            },
          );
          break;

        case 'nearby_event':
          Get.toNamed(
            AppRoutes.EVENT_DETAIL,
            arguments: {'eventId': data['eventId']},
          );
          break;

        default:
          if (Get.currentRoute != route) {
            Get.toNamed(route);
          }
      }
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }
}

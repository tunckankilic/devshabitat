import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Logger _logger = Logger();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Bildirim izinleri
  final RxBool hasPermission = false.obs;
  // Kullanıcının bildirimleri
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // FCM için izinleri al
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      hasPermission.value =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      // FCM token'ı al ve Firestore'a kaydet
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      // Token yenilendiğinde
      _fcm.onTokenRefresh.listen(_saveTokenToFirestore);

      // Yerel bildirimler için initialize
      await _initializeLocalNotifications();

      // Arka planda bildirim geldiğinde
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Uygulama açıkken bildirim geldiğinde
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Bildirime tıklandığında
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    } catch (e) {
      _logger.e('Bildirim servisi başlatılırken hata: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleLocalNotificationTap(details.payload);
      },
    );
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final String? userId = Get.find<AuthRepository>().currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        _logger.i('FCM token başarıyla kaydedildi');
      }
    } catch (e) {
      _logger.e('FCM token kaydedilirken hata: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _showLocalNotification(
      title: message.notification?.title ?? 'Yeni Bildirim',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Varsayılan Kanal',
      channelDescription: 'Genel bildirimler için kanal',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _handleLocalNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = Map<String, dynamic>.from(
          Map.from(payload as Map<String, dynamic>),
        );
        _handleNotificationData(data);
      } catch (e) {
        _logger.e('Bildirim verisi işlenirken hata: $e');
      }
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    _handleNotificationData(message.data);
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    // Bildirim tipine göre yönlendirme
    final String? type = data['type'] as String?;
    final String? targetId = data['targetId'] as String?;

    switch (type) {
      case 'message':
        if (targetId != null) {
          Get.toNamed('/messages/$targetId');
        }
        break;
      case 'post':
        if (targetId != null) {
          Get.toNamed('/posts/$targetId');
        }
        break;
      case 'profile':
        if (targetId != null) {
          Get.toNamed('/profile/$targetId');
        }
        break;
      default:
        Get.toNamed('/notifications');
    }
  }

  Future<void> saveNotification(RemoteMessage message) async {
    try {
      final String? userId = Get.find<AuthRepository>().currentUser?.uid;
      if (userId != null) {
        final notification = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          imageUrl: message.notification?.android?.imageUrl,
          data: message.data,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notification.id)
            .set(notification.toMap());

        notifications.insert(0, notification);
      }
    } catch (e) {
      _logger.e('Bildirim kaydedilirken hata: $e');
    }
  }

  Future<void> loadNotifications() async {
    try {
      final String? userId = Get.find<AuthRepository>().currentUser?.uid;
      if (userId != null) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get();

        notifications.value = querySnapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      _logger.e('Bildirimler yüklenirken hata: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final String? userId = Get.find<AuthRepository>().currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notificationId)
            .update({'isRead': true});

        final index =
            notifications.indexWhere((element) => element.id == notificationId);
        if (index != -1) {
          final updatedNotification = NotificationModel(
            id: notifications[index].id,
            title: notifications[index].title,
            body: notifications[index].body,
            imageUrl: notifications[index].imageUrl,
            data: notifications[index].data,
            createdAt: notifications[index].createdAt,
            isRead: true,
          );
          notifications[index] = updatedNotification;
        }
      }
    } catch (e) {
      _logger.e('Bildirim okundu olarak işaretlenirken hata: $e');
    }
  }
}

// Top-level handler for background messages
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  final notificationService = Get.put(NotificationService());
  await notificationService.saveNotification(message);
}

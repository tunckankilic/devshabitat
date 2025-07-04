import 'dart:convert';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final SharedPreferences _prefs;

  // Bildirim izinleri için RxBool değişkenler
  final RxBool isPushEnabled = true.obs;
  final RxBool isInAppEnabled = true.obs;

  // Bildirim kategorileri için map
  final Map<String, RxBool> categoryPreferences = {
    'events': true.obs,
    'messages': true.obs,
    'community': true.obs,
    'connections': true.obs,
  };

  NotificationService(this._prefs);

  Future<void> init() async {
    // FCM izinlerini iste
    await _requestPermissions();

    // Local notifications için initialize
    await _initializeLocalNotifications();

    // FCM token al ve sakla
    await _getFCMToken();

    // Tercihleri yükle
    _loadPreferences();

    // Bildirim dinleyicilerini ayarla
    _setupNotificationListeners();
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    isPushEnabled.value =
        settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
  }

  void _onSelectNotification(NotificationResponse response) {
    if (response.payload != null) {
      final Map<String, dynamic> payload = json.decode(response.payload!);
      // Bildirime tıklandığında yönlendirme işlemleri burada yapılacak
      _handleNotificationNavigation(payload);
    }
  }

  Future<void> _getFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _prefs.setString('fcm_token', token);
      // TODO: Token'ı backend'e gönder
    }
  }

  void _loadPreferences() {
    isPushEnabled.value = _prefs.getBool('push_enabled') ?? true;
    isInAppEnabled.value = _prefs.getBool('in_app_enabled') ?? true;

    for (var category in categoryPreferences.keys) {
      categoryPreferences[category]?.value =
          _prefs.getBool('category_$category') ?? true;
    }
  }

  void _setupNotificationListeners() {
    // Uygulama açıkken gelen bildirimler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Uygulama arka plandayken tıklanan bildirimler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Uygulama kapalıyken gelen bildirimler için
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleTerminatedMessage(message);
      }
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (!isPushEnabled.value) return;

    final category = message.data['category'] as String?;
    if (category != null && !(categoryPreferences[category]?.value ?? true))
      return;

    // In-app bildirim göster
    if (isInAppEnabled.value) {
      _showInAppNotification(message);
    }

    // Local notification göster
    await _showLocalNotification(message);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    _handleNotificationNavigation(message.data);
  }

  void _handleTerminatedMessage(RemoteMessage message) {
    _handleNotificationNavigation(message.data);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
      payload: json.encode(message.data),
    );
  }

  void _showInAppNotification(RemoteMessage message) {
    Get.snackbar(
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final String? route = data['route'];
    final String? id = data['id'];

    if (route != null && id != null) {
      switch (route) {
        case 'event':
          Get.toNamed('/event/$id');
          break;
        case 'community':
          Get.toNamed('/community/$id');
          break;
        case 'message':
          Get.toNamed('/messages/$id');
          break;
        case 'connection':
          Get.toNamed('/connections/$id');
          break;
      }
    }
  }

  // Bildirim tercihlerini güncelleme metodları
  Future<void> updatePushPreference(bool value) async {
    isPushEnabled.value = value;
    await _prefs.setBool('push_enabled', value);
  }

  Future<void> updateInAppPreference(bool value) async {
    isInAppEnabled.value = value;
    await _prefs.setBool('in_app_enabled', value);
  }

  Future<void> updateCategoryPreference(String category, bool value) async {
    categoryPreferences[category]?.value = value;
    await _prefs.setBool('category_$category', value);
  }

  // Test için bildirim gönderme fonksiyonu
  Future<void> sendTestNotification({
    required String title,
    required String body,
    required String category,
    String? route,
    String? id,
  }) async {
    final message = RemoteMessage(
      notification: RemoteNotification(
        title: title,
        body: body,
      ),
      data: {
        'category': category,
        if (route != null) 'route': route,
        if (id != null) 'id': id,
      },
    );

    await _handleForegroundMessage(message);
  }

  // Bildirimi Firestore'a kaydet
  Future<void> saveNotification(RemoteMessage message) async {
    final String? userId = Get.find<AuthRepository>().currentUser?.uid;
    if (userId != null) {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        data: message.data,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final String? userId = Get.find<AuthRepository>().currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    }
  }
}

// Top-level handler for background messages
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final notificationService = Get.put(NotificationService(prefs));
  await notificationService.saveNotification(message);
}

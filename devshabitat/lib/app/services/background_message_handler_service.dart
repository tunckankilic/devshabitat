import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final logger = Logger();

  try {
    // Bildirim verilerini Firestore'a kaydet
    await _saveNotificationToFirestore(message);

    // Local bildirim göster
    await _showBackgroundNotification(message);

    // Bildirim sayacını güncelle
    await _updateUnreadNotificationCount(prefs);

    logger.i('Background message handled successfully: ${message.messageId}');
  } catch (e) {
    logger.e('Error handling background message: $e');
  }
}

Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
  final firestore = FirebaseFirestore.instance;

  // Kullanıcı ID'sini shared preferences'dan al
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

  if (userId != null) {
    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: message.data,
      createdAt: DateTime.now(),
      isRead: false,
    );

    await firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }
}

Future<void> _showBackgroundNotification(RemoteMessage message) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Bildirim kanalını belirle
  String channelId = 'default_channel';
  String channelName = 'Genel Bildirimler';
  Importance importance = Importance.defaultImportance;

  // Bildirim tipine göre kanal ayarlarını güncelle
  if (message.data['priority'] == 'high') {
    channelId = 'high_importance_channel';
    channelName = 'Önemli Bildirimler';
    importance = Importance.high;
  } else if (message.data['silent'] == 'true') {
    channelId = 'silent_channel';
    channelName = 'Sessiz Bildirimler';
    importance = Importance.low;
  }

  final androidDetails = AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: 'Channel for ${channelName.toLowerCase()}',
    importance: importance,
    priority: Priority.high,
    showWhen: true,
  );

  final iosDetails = const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  final details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title,
    message.notification?.body,
    details,
    payload: json.encode(message.data),
  );
}

Future<void> _updateUnreadNotificationCount(SharedPreferences prefs) async {
  int currentCount = prefs.getInt('unread_notifications') ?? 0;
  await prefs.setInt('unread_notifications', currentCount + 1);
}

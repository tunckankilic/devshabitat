import 'dart:convert';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs;
  final Logger _logger = Logger();

  // Platform özel bildirim ayarları
  final Map<String, dynamic> _platformSettings = {
    'ios': {
      'sound': true,
      'badge': true,
      'alert': true,
      'provisional': false,
      'criticalAlert': false,
    },
    'android': {
      'channelId': 'high_importance_channel',
      'channelName': 'Önemli Bildirimler',
      'channelDescription': 'Bu kanal önemli bildirimleri içerir',
      'importance': Importance.high,
      'priority': Priority.high,
      'enableVibration': true,
      'playSound': true,
    },
  };

  // Bildirim izinleri için RxBool değişkenler
  final RxBool isPushEnabled = true.obs;
  final RxBool isInAppEnabled = true.obs;
  final RxString fcmToken = ''.obs;
  final RxBool isTokenRefreshing = false.obs;

  // Bildirim kategorileri için map
  final Map<String, RxBool> categoryPreferences = {
    'events': true.obs,
    'messages': true.obs,
    'community': true.obs,
    'connections': true.obs,
    'integration': true.obs,
    'webhook': true.obs,
    'service_alert': true.obs,
  };

  NotificationService(this._prefs);

  Future<void> init() async {
    try {
      await _initializePlatformSpecifics();
      await _requestPermissions();
      await _configureFCM();
      await _setupNotificationChannels();
      await _loadPreferences();
    } catch (e) {
      _logger.e('Bildirim servisi başlatılamadı: $e');
    }
  }

  Future<void> _initializePlatformSpecifics() async {
    if (Platform.isIOS) {
      await _initializeIOS();
    } else if (Platform.isAndroid) {
      await _initializeAndroid();
    }
  }

  Future<void> _initializeIOS() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: _platformSettings['ios']['alert'],
      badge: _platformSettings['ios']['badge'],
      sound: _platformSettings['ios']['sound'],
    );
  }

  Future<void> _initializeAndroid() async {
    const androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(initializationSettings);
  }

  Future<void> _setupNotificationChannels() async {
    if (Platform.isAndroid) {
      final androidSettings = _platformSettings['android'];
      final channel = AndroidNotificationChannel(
        androidSettings['channelId'],
        androidSettings['channelName'],
        description: androidSettings['channelDescription'],
        importance: androidSettings['importance'],
        playSound: androidSettings['playSound'],
        enableVibration: androidSettings['enableVibration'],
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _requestPermissions() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
            announcement: true,
            carPlay: true,
            criticalAlert: true,
          );

      isPushEnabled.value =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      // iOS için ek izinler
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      _logger.e('Error requesting notification permissions: $e');
    }
  }

  Future<void> _configureFCM() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        await _saveFCMToken(token);
      }

      // Token yenileme dinleyicisi
      _firebaseMessaging.onTokenRefresh.listen((token) async {
        isTokenRefreshing.value = true;
        try {
          fcmToken.value = token;
          await _saveFCMToken(token);
        } catch (e) {
          _logger.e('Token yenileme hatası: $e');
        } finally {
          isTokenRefreshing.value = false;
        }
      });

      // Bildirim dinleyicileri
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
    } catch (e) {
      _logger.e('FCM yapılandırma hatası: $e');
    }
  }

  Future<void> _saveFCMToken(String token) async {
    try {
      final userId = Get.find<AuthRepository>().currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'platform': Platform.isIOS ? 'ios' : 'android',
          'appVersion': (await PackageInfo.fromPlatform()).version,
        });
      }
    } catch (e) {
      _logger.e('Token kaydetme hatası: $e');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final userId = Get.find<AuthRepository>().currentUser?.uid;
      if (userId != null) {
        // Firestore'dan tercihleri yükle
        final doc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('preferences')
            .doc('notifications')
            .get();

        if (doc.exists) {
          final data = doc.data()!;

          // Genel bildirim ayarları
          isPushEnabled.value = data['isPushEnabled'] ?? true;
          isInAppEnabled.value = data['isInAppEnabled'] ?? true;

          // Kategori tercihleri
          final categories = data['categories'] as Map<String, dynamic>?;
          if (categories != null) {
            categories.forEach((key, value) {
              if (categoryPreferences.containsKey(key)) {
                categoryPreferences[key]?.value = value as bool;
              }
            });
          }

          // Local'e kaydet
          await _savePreferencesToLocal(data);
        } else {
          // Varsayılan tercihleri oluştur ve kaydet
          await _savePreferencesToFirestore();
        }

        // Firestore'daki değişiklikleri dinle
        _setupPreferencesListener(userId);
      }
    } catch (e) {
      _logger.e('Error loading notification preferences: $e');
    }
  }

  Future<void> _savePreferencesToFirestore() async {
    try {
      final userId = Get.find<AuthRepository>().currentUser?.uid;
      if (userId != null) {
        final preferences = {
          'isPushEnabled': isPushEnabled.value,
          'isInAppEnabled': isInAppEnabled.value,
          'categories': categoryPreferences.map(
            (key, value) => MapEntry(key, value.value),
          ),
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('preferences')
            .doc('notifications')
            .set(preferences, SetOptions(merge: true));

        await _savePreferencesToLocal(preferences);
      }
    } catch (e) {
      _logger.e('Error saving notification preferences to Firestore: $e');
    }
  }

  Future<void> _savePreferencesToLocal(Map<String, dynamic> preferences) async {
    try {
      await _prefs.setBool(
        'push_enabled',
        preferences['isPushEnabled'] ?? true,
      );
      await _prefs.setBool(
        'in_app_enabled',
        preferences['isInAppEnabled'] ?? true,
      );

      final categories = preferences['categories'] as Map<String, dynamic>?;
      if (categories != null) {
        for (var entry in categories.entries) {
          await _prefs.setBool('category_${entry.key}', entry.value as bool);
        }
      }
    } catch (e) {
      _logger.e('Error saving notification preferences to local storage: $e');
    }
  }

  void _setupPreferencesListener(String userId) {
    _firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('notifications')
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists) {
              final data = doc.data()!;

              // Genel ayarları güncelle
              isPushEnabled.value = data['isPushEnabled'] ?? true;
              isInAppEnabled.value = data['isInAppEnabled'] ?? true;

              // Kategori tercihlerini güncelle
              final categories = data['categories'] as Map<String, dynamic>?;
              if (categories != null) {
                categories.forEach((key, value) {
                  if (categoryPreferences.containsKey(key)) {
                    categoryPreferences[key]?.value = value as bool;
                  }
                });
              }

              // Local'e kaydet
              _savePreferencesToLocal(data);
            }
          },
          onError: (error) {
            _logger.e('Error in preferences listener: $error');
          },
        );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      if (!isPushEnabled.value) return;

      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        final platformChannelSpecifics = await _getPlatformChannelSpecifics(
          data,
        );

        // Bildirim göster
        await _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          platformChannelSpecifics,
          payload: json.encode(data),
        );

        // In-app bildirim göster
        if (isInAppEnabled.value) {
          Get.snackbar(
            notification.title ?? '',
            notification.body ?? '',
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
          );
        }

        // Bildirimi Firestore'a kaydet
        await saveNotification(message);
      }
    } catch (e) {
      _logger.e('Bildirim işleme hatası: $e');
    }
  }

  Future<NotificationDetails> _getPlatformChannelSpecifics(
    Map<String, dynamic> data,
  ) async {
    if (Platform.isIOS) {
      return NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: _platformSettings['ios']['alert'],
          presentBadge: _platformSettings['ios']['badge'],
          presentSound: _platformSettings['ios']['sound'],
        ),
      );
    } else {
      final androidSettings = _platformSettings['android'];
      return NotificationDetails(
        android: AndroidNotificationDetails(
          androidSettings['channelId'],
          androidSettings['channelName'],
          channelDescription: androidSettings['channelDescription'],
          importance: androidSettings['importance'],
          priority: androidSettings['priority'],
          enableVibration: androidSettings['enableVibration'],
          playSound: androidSettings['playSound'],
        ),
      );
    }
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    await handleNotificationNavigation(message.data);
  }

  Future<void> handleNotificationNavigation(Map<String, dynamic> data) async {
    try {
      final String? route = data['route'];
      final String? type = data['type'];
      final String? id = data['id'];

      if (route != null) {
        switch (type) {
          case 'message':
            Get.toNamed('/messages/$id');
            break;
          case 'event':
            Get.toNamed('/events/$id');
            break;
          case 'community':
            Get.toNamed('/communities/$id');
            break;
          case 'connection':
            Get.toNamed('/connections/$id');
            break;
          default:
            Get.toNamed(route);
        }
      }
    } catch (e) {
      _logger.e('Error handling notification navigation: $e');
    }
  }

  // Tercih güncelleme metodları
  Future<void> updatePushPreference(bool value) async {
    isPushEnabled.value = value;
    await _savePreferencesToFirestore();
  }

  Future<void> updateInAppPreference(bool value) async {
    isInAppEnabled.value = value;
    await _savePreferencesToFirestore();
  }

  Future<void> updateCategoryPreference(String category, bool value) async {
    if (categoryPreferences.containsKey(category)) {
      categoryPreferences[category]?.value = value;
      await _savePreferencesToFirestore();
    }
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
      notification: RemoteNotification(title: title, body: body),
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
        isRead: false,
        type: NotificationType.values.firstWhere(
          (e) =>
              e.toString() ==
              'NotificationType.${message.data['type'] ?? 'system'}',
          orElse: () => NotificationType.system,
        ),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notification.id)
          .set({
            'id': notification.id,
            'title': notification.title,
            'body': notification.body,
            'data': notification.data,
            'createdAt': notification.createdAt,
            'isRead': notification.isRead,
            'type': notification.type.toString().split('.').last,
          });
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final String? userId = Get.find<AuthRepository>().currentUser?.uid;
    if (userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    }
  }

  Future<List<NotificationModel>> getNotifications({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      var query = _firestore
          .collection('notifications')
          .where(
            'userId',
            isEqualTo: Get.find<AuthRepository>().currentUser?.uid,
          )
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => NotificationModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }
}

// Top-level handler for background messages
@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  // Background message handler must be a top-level function
  await Firebase.initializeApp();
  final notificationService = Get.put(
    NotificationService(await SharedPreferences.getInstance()),
  );
  await notificationService.handleNotificationNavigation(message.data);
}

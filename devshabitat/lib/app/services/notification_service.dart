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
import 'package:package_info_plus/package_info_plus.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs;
  final Logger _logger = Logger();

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
  };

  NotificationService(this._prefs);

  Future<void> init() async {
    try {
      // FCM izinlerini iste
      await _requestPermissions();

      // Local notifications için initialize
      await _initializeLocalNotifications();

      // FCM token al ve sakla
      await _initializeFCMToken();

      // Tercihleri yükle
      await _loadPreferences();

      // Bildirim dinleyicilerini ayarla
      _setupNotificationListeners();

      // Token yenileme dinleyicisini ayarla
      _setupTokenRefreshListener();
    } catch (e) {
      _logger.e('Notification service initialization error: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
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

  Future<void> _initializeLocalNotifications() async {
    try {
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

      // Android için bildirim kanalları oluştur
      await _createNotificationChannels();
    } catch (e) {
      _logger.e('Error initializing local notifications: $e');
    }
  }

  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'high_importance_channel',
        'Önemli Bildirimler',
        description: 'Acil ve önemli bildirimler için kanal',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        showBadge: true,
        enableLights: true,
      ),
      AndroidNotificationChannel(
        'default_channel',
        'Genel Bildirimler',
        description: 'Genel bildirimler için varsayılan kanal',
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      ),
      AndroidNotificationChannel(
        'silent_channel',
        'Sessiz Bildirimler',
        description: 'Sessiz bildirimler için kanal',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
      AndroidNotificationChannel(
        'messages_channel',
        'Mesaj Bildirimleri',
        description: 'Mesaj bildirimleri için özel kanal',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      ),
      AndroidNotificationChannel(
        'events_channel',
        'Etkinlik Bildirimleri',
        description: 'Etkinlik bildirimleri için özel kanal',
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      ),
    ];

    for (var channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _initializeFCMToken() async {
    try {
      isTokenRefreshing.value = true;

      // Önceki token'ı temizle
      final oldToken = await _firebaseMessaging.getToken();
      if (oldToken != null) {
        await _removeOldToken(oldToken);
      }

      // Yeni token al
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _updateFCMToken(token);
      } else {
        _logger.w('FCM token alınamadı');
        // Retry mechanism
        await Future.delayed(const Duration(seconds: 2));
        token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _updateFCMToken(token);
        }
      }
    } catch (e) {
      _logger.e('Error initializing FCM token: $e');
      // Fallback: Local token'ı kullan
      final localToken = _prefs.getString('fcm_token');
      if (localToken != null) {
        fcmToken.value = localToken;
      }
    } finally {
      isTokenRefreshing.value = false;
    }
  }

  Future<void> _removeOldToken(String oldToken) async {
    try {
      final String? userId = Get.find<AuthRepository>().currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.arrayRemove([oldToken]),
        });
      }
    } catch (e) {
      _logger.e('Error removing old FCM token: $e');
    }
  }

  Future<void> _updateFCMToken(String token) async {
    try {
      final String? userId = Get.find<AuthRepository>().currentUser?.uid;
      if (userId != null) {
        // Uygulama versiyonunu al
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String appVersion =
            '${packageInfo.version}+${packageInfo.buildNumber}';

        // Token'ı Firestore'a kaydet
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'deviceInfo': {
            'platform': GetPlatform.isIOS ? 'iOS' : 'Android',
            'appVersion': appVersion,
            'lastSeen': FieldValue.serverTimestamp(),
          },
        });

        // Token'ı local'e kaydet
        await _prefs.setString('fcm_token', token);
        fcmToken.value = token;

        _logger.i('FCM token updated successfully');
      } else {
        _logger.w('User not authenticated, token not saved to Firestore');
        // Local'e kaydet
        await _prefs.setString('fcm_token', token);
        fcmToken.value = token;
      }
    } catch (e) {
      _logger.e('Error updating FCM token: $e');
      // Local'e kaydetmeyi dene
      try {
        await _prefs.setString('fcm_token', token);
        fcmToken.value = token;
      } catch (localError) {
        _logger.e('Error saving token to local storage: $localError');
      }
    }
  }

  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      try {
        _logger.i('FCM token refreshed');
        await _updateFCMToken(token);
      } catch (e) {
        _logger.e('Error in token refresh listener: $e');
        // Retry mechanism
        await Future.delayed(const Duration(seconds: 5));
        try {
          await _updateFCMToken(token);
        } catch (retryError) {
          _logger.e('Error in token refresh retry: $retryError');
        }
      }
    }, onError: (error) {
      _logger.e('Token refresh stream error: $error');
    });
  }

  void _onSelectNotification(NotificationResponse response) {
    if (response.payload != null) {
      final Map<String, dynamic> payload = json.decode(response.payload!);
      // Bildirime tıklandığında yönlendirme işlemleri burada yapılacak
      handleNotificationNavigation(payload);
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
          'push_enabled', preferences['isPushEnabled'] ?? true);
      await _prefs.setBool(
          'in_app_enabled', preferences['isInAppEnabled'] ?? true);

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
    if (category != null && !(categoryPreferences[category]?.value ?? true)) {
      return;
    }

    // In-app bildirim göster
    if (isInAppEnabled.value) {
      _showInAppNotification(message);
    }

    // Local notification göster
    await _showLocalNotification(message);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    handleNotificationNavigation(message.data);
  }

  void _handleTerminatedMessage(RemoteMessage message) {
    handleNotificationNavigation(message.data);
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

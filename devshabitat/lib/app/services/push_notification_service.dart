import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../core/services/error_handler_service.dart';
import '../repositories/auth_repository.dart';

class PushNotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Notification state
  final RxBool isInitialized = false.obs;
  final RxString fcmToken = ''.obs;
  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initialize();
  }

  // Servisi başlat
  Future<void> initialize() async {
    try {
      // İzin iste
      final settings = await _requestPermissions();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        _logger.w('Bildirim izni verilmedi');
        return;
      }

      // Local notifications'ı başlat
      await _initializeLocalNotifications();

      // FCM token'ı al
      await _getFCMToken();

      // Message handler'ları ayarla
      _setupMessageHandlers();

      // Token yenileme dinleyicisi
      _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);

      isInitialized.value = true;
      _logger.i('PushNotificationService başlatıldı');
    } catch (e) {
      _logger.e('PushNotificationService başlatma hatası: $e');
      _errorHandler.handleError(
        'Bildirim servisi hatası: $e',
        'NOTIFICATION_INIT_ERROR',
      );
    }
  }

  // İzin iste
  Future<NotificationSettings> _requestPermissions() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // Local notifications başlat
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // FCM token al
  Future<void> _getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        await _saveTokenToFirestore(token);
        _logger.i('FCM Token alındı: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      _logger.e('FCM Token alma hatası: $e');
    }
  }

  // Token'ı Firestore'a kaydet
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return;

      await _firestore.collection('users').doc(currentUser.uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('FCM Token kaydetme hatası: $e');
    }
  }

  // Message handler'ları ayarla
  void _setupMessageHandlers() {
    // Uygulama foreground'da iken
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Uygulama background'dan açıldığında
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Uygulama kapalıyken gelmiş mesajları kontrol et
    _checkInitialMessage();
  }

  // Foreground mesaj işleme
  void _handleForegroundMessage(RemoteMessage message) {
    _logger.i('Foreground mesaj alındı: ${message.messageId}');

    // Notification'ı listeye ekle
    _addNotificationToList(message);

    // Local notification göster
    _showLocalNotification(message);
  }

  // Uygulama background'dan açıldığında
  void _handleMessageOpenedApp(RemoteMessage message) {
    _logger.i('Background mesajdan uygulama açıldı: ${message.messageId}');
    _handleNotificationAction(message);
  }

  // İlk mesajı kontrol et
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _logger.i('İlk mesaj: ${initialMessage.messageId}');
      _handleNotificationAction(initialMessage);
    }
  }

  // Local notification göster
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'devshabitat_channel',
      'DevShabitat Notifications',
      channelDescription: 'DevShabitat uygulaması bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
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
      message.hashCode,
      message.notification?.title ?? 'DevShabitat',
      message.notification?.body ?? 'Yeni bildirim',
      details,
      payload: message.data.toString(),
    );
  }

  // Bildirim tıklama işlemi
  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('Bildirim tıklandı: ${response.payload}');
    // Payload'a göre sayfa yönlendirmesi yapılabilir
  }

  // Token yenileme
  void _onTokenRefresh(String newToken) {
    fcmToken.value = newToken;
    _saveTokenToFirestore(newToken);
    _logger.i('FCM Token yenilendi');
  }

  // Bildirim aksiyonu işleme
  void _handleNotificationAction(RemoteMessage message) {
    final data = message.data;

    // Bildirim tipine göre sayfa yönlendirmesi
    switch (data['type']) {
      case 'message':
        Get.toNamed('/chat', arguments: data['chatId']);
        break;
      case 'comment':
        Get.toNamed('/comments', arguments: data['postId']);
        break;
      case 'follow':
        Get.toNamed('/profile', arguments: data['userId']);
        break;
      case 'event':
        Get.toNamed('/event-details', arguments: data['eventId']);
        break;
      default:
        Get.toNamed('/home');
    }
  }

  // Bildirim listesine ekle
  void _addNotificationToList(RemoteMessage message) {
    notifications.insert(0, {
      'id': message.messageId,
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': DateTime.now(),
      'isRead': false,
    });

    // Maksimum 100 bildirim tut
    if (notifications.length > 100) {
      notifications.removeLast();
    }
  }

  // Bildirimi okundu işaretle
  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      notifications[index]['isRead'] = true;
      notifications.refresh();
    }
  }

  // Tüm bildirimleri okundu işaretle
  void markAllAsRead() {
    for (final notification in notifications) {
      notification['isRead'] = true;
    }
    notifications.refresh();
  }

  // Bildirimi sil
  void removeNotification(String notificationId) {
    notifications.removeWhere((n) => n['id'] == notificationId);
  }

  // Tüm bildirimleri temizle
  void clearAllNotifications() {
    notifications.clear();
  }

  // Belirli kullanıcıya bildirim gönder
  Future<bool> sendNotificationToUser(
    String userId,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    try {
      // Kullanıcının FCM token'larını al
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      final tokens = List<String>.from(userData['fcmTokens'] ?? []);

      if (tokens.isEmpty) return false;

      // Cloud Function ile bildirim gönder
      await _firestore.collection('notifications_queue').add({
        'tokens': tokens,
        'title': title,
        'body': body,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
        'processed': false,
      });

      return true;
    } catch (e) {
      _logger.e('Bildirim gönderme hatası: $e');
      _errorHandler.handleError(
        'Bildirim gönderilemedi: $e',
        'SEND_NOTIFICATION_ERROR',
      );
      return false;
    }
  }

  // Toplu bildirim gönder
  Future<bool> sendBulkNotification(
    List<String> userIds,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final userId in userIds) {
        final docRef = _firestore.collection('notifications_queue').doc();
        batch.set(docRef, {
          'userId': userId,
          'title': title,
          'body': body,
          'data': data,
          'timestamp': FieldValue.serverTimestamp(),
          'processed': false,
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      _logger.e('Toplu bildirim hatası: $e');
      return false;
    }
  }

  // Topic'e abone ol
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.i('Topic\'e abone olundu: $topic');
    } catch (e) {
      _logger.e('Topic abonelik hatası: $e');
    }
  }

  // Topic aboneliğini iptal et
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.i('Topic aboneliği iptal edildi: $topic');
    } catch (e) {
      _logger.e('Topic abonelik iptali hatası: $e');
    }
  }

  // Bildirim sayısı
  int get unreadCount => notifications.where((n) => !n['isRead']).length;

  // Son bildirimleri al
  List<Map<String, dynamic>> get recentNotifications =>
      notifications.take(10).toList();
}

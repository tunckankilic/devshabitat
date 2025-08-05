import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../repositories/auth_repository.dart';

class BlogNotificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Bildirim kanalı
  static const String _commentChannel = 'blog_comments';

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initNotifications();
  }

  Future<void> _initNotifications() async {
    // FCM izinleri
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Yerel bildirim ayarları
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Bildirim kanalları oluştur
    await _createNotificationChannels();

    // FCM token'ı kaydet
    await _saveUserFCMToken();

    // Arka planda bildirim dinleyicisi
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _createNotificationChannels() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _commentChannel,
            'Blog Yorumları',
            description: 'Blog yorumları için bildirimler',
            importance: Importance.high,
          ),
        );

    // Diğer kanallar için benzer ayarlar...
  }

  Future<void> _saveUserFCMToken() async {
    final token = await _messaging.getToken();
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;

    if (token != null && userId != null) {
      await _firestore.collection('user_tokens').doc(userId).set({
        'token': token,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'platform': GetPlatform.isIOS ? 'ios' : 'android',
      });
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Arka planda bildirim işleme
  }

  // Yorum bildirimi gönderme
  Future<void> sendCommentNotification({
    required String blogId,
    required String blogTitle,
    required String commenterId,
    required String commenterName,
    required String authorId,
  }) async {
    final authorTokenDoc = await _firestore
        .collection('user_tokens')
        .doc(authorId)
        .get();

    if (!authorTokenDoc.exists) return;

    final token = authorTokenDoc.get('token') as String;

    await _firestore.collection('notifications').add({
      'token': token,
      'type': 'comment',
      'blogId': blogId,
      'commenterId': commenterId,
      'title': 'Yeni Yorum',
      'body': '$commenterName blogunuza yorum yaptı: $blogTitle',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Beğeni bildirimi gönderme
  Future<void> sendLikeNotification({
    required String blogId,
    required String blogTitle,
    required String likerId,
    required String likerName,
    required String authorId,
  }) async {
    final authorTokenDoc = await _firestore
        .collection('user_tokens')
        .doc(authorId)
        .get();

    if (!authorTokenDoc.exists) return;

    final token = authorTokenDoc.get('token') as String;

    await _firestore.collection('notifications').add({
      'token': token,
      'type': 'like',
      'blogId': blogId,
      'likerId': likerId,
      'title': 'Yeni Beğeni',
      'body': '$likerName blogunuzu beğendi: $blogTitle',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Takip bildirimi gönderme
  Future<void> sendFollowNotification({
    required String followerId,
    required String followerName,
    required String authorId,
  }) async {
    final authorTokenDoc = await _firestore
        .collection('user_tokens')
        .doc(authorId)
        .get();

    if (!authorTokenDoc.exists) return;

    final token = authorTokenDoc.get('token') as String;

    await _firestore.collection('notifications').add({
      'token': token,
      'type': 'follow',
      'followerId': followerId,
      'title': 'Yeni Takipçi',
      'body': '$followerName sizi takip etmeye başladı',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Yeni blog bildirimi gönderme
  Future<void> sendNewBlogNotification({
    required String blogId,
    required String blogTitle,
    required String authorId,
    required String authorName,
  }) async {
    // Yazarın takipçilerini bul
    final followers = await _firestore
        .collection('followers')
        .where('authorId', isEqualTo: authorId)
        .get();

    // Her takipçiye bildirim gönder
    for (final follower in followers.docs) {
      final followerId = follower.get('followerId') as String;
      final followerToken = await _firestore
          .collection('user_tokens')
          .doc(followerId)
          .get();

      if (!followerToken.exists) continue;

      final token = followerToken.get('token') as String;

      await _firestore.collection('notifications').add({
        'token': token,
        'type': 'new_blog',
        'blogId': blogId,
        'authorId': authorId,
        'title': 'Yeni Blog Yazısı',
        'body': '$authorName yeni bir blog yazısı yayınladı: $blogTitle',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  // Bildirim tercihlerini güncelleme
  Future<void> updateNotificationPreferences({
    required String userId,
    required bool comments,
    required bool likes,
    required bool follows,
    required bool newBlogs,
  }) async {
    await _firestore.collection('notification_preferences').doc(userId).set({
      'comments': comments,
      'likes': likes,
      'follows': follows,
      'newBlogs': newBlogs,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SimpleNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Bildirim gönder
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final fcmToken = userDoc.data()?['fcmToken'] as String?;

    if (fcmToken == null) return;

    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'data': data,
      'fcmToken': fcmToken,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Etkinlik hatırlatması gönder
  Future<void> sendEventReminder({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime reminderTime,
  }) async {
    final timeUntilEvent = reminderTime.difference(DateTime.now());
    String timeText;

    if (timeUntilEvent.inDays > 0) {
      timeText = '${timeUntilEvent.inDays} gün';
    } else if (timeUntilEvent.inHours > 0) {
      timeText = '${timeUntilEvent.inHours} saat';
    } else {
      timeText = '${timeUntilEvent.inMinutes} dakika';
    }

    await sendNotification(
      userId: userId,
      title: 'Etkinlik Hatırlatması',
      body: '$eventTitle etkinliği $timeText sonra başlayacak!',
      data: {'type': 'event_reminder', 'eventId': eventId},
    );
  }

  // Bildirimleri getir
  Future<List<Map<String, dynamic>>> getNotifications(
    String userId, {
    bool unreadOnly = false,
    int limit = 20,
  }) async {
    var query = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (unreadOnly) {
      query = query.where('isRead', isEqualTo: false);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  // Tüm bildirimleri okundu olarak işaretle
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // FCM token'ı güncelle
  Future<void> updateFCMToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'lastTokenUpdate': FieldValue.serverTimestamp(),
    });
  }

  // Bildirim izinlerini kontrol et ve iste
  Future<bool> requestNotificationPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Bildirim ayarlarını güncelle
  Future<void> updateNotificationSettings(
    String userId,
    Map<String, bool> settings,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'notificationSettings': settings,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

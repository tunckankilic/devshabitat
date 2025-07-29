import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/models/event/event_registration_model.dart';

class EventNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Request permission for notifications
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _localNotifications.initialize(initializationSettings);

    // Create notification channels for Android
    await _createEventNotificationChannels();
  }

  Future<void> _createEventNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'event_channel',
        'Etkinlik Bildirimleri',
        description: 'Etkinlik bildirimleri için kanal',
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      ),
      AndroidNotificationChannel(
        'event_reminder_channel',
        'Etkinlik Hatırlatmaları',
        description: 'Etkinlik hatırlatmaları için özel kanal',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        showBadge: true,
        enableLights: true,
      ),
      AndroidNotificationChannel(
        'event_updates_channel',
        'Etkinlik Güncellemeleri',
        description: 'Etkinlik güncellemeleri için kanal',
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

  // Subscribe to event notifications
  Future<void> subscribeToEvent(String eventId) async {
    await _messaging.subscribeToTopic('event_$eventId');
  }

  // Unsubscribe from event notifications
  Future<void> unsubscribeFromEvent(String eventId) async {
    await _messaging.unsubscribeFromTopic('event_$eventId');
  }

  // Send notification to event participants
  Future<void> sendEventNotification({
    required String eventId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // 1. Firestore'a kaydet
    await _firestore.collection('event_notifications').add({
      'eventId': eventId,
      'title': title,
      'body': body,
      'data': data,
      'sentAt': DateTime.now(),
    });

    // 2. Topic'e bildirim gönder (katılımcılara)
    await _messaging.subscribeToTopic('event_$eventId');

    // 3. Local notification ekle
    await _localNotifications.show(
      eventId.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel',
          'Etkinlik Bildirimleri',
          channelDescription: 'Etkinlik bildirimleri için kanal',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Schedule event reminder notification
  Future<void> scheduleEventReminder({
    required String eventId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  }) async {
    await _localNotifications.zonedSchedule(
      eventId.hashCode + 1000, // Farklı ID için offset
      'Etkinlik Hatırlatması: $title',
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminder_channel',
          'Etkinlik Hatırlatmaları',
          channelDescription: 'Etkinlik hatırlatmaları için özel kanal',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          enableLights: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: eventId,
    );
  }

  // Send event update notification
  Future<void> sendEventUpdate({
    required String eventId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _localNotifications.show(
      eventId.hashCode + 2000, // Farklı ID için offset
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_updates_channel',
          'Etkinlik Güncellemeleri',
          channelDescription: 'Etkinlik güncellemeleri için kanal',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Cancel scheduled reminder
  Future<void> cancelEventReminder(String eventId) async {
    await _localNotifications.cancel(eventId.hashCode + 1000);
  }

  // Send registration status notification
  Future<void> sendRegistrationStatusNotification(
    EventRegistrationModel registration,
    EventModel event,
  ) async {
    String title;
    String body;

    switch (registration.status) {
      case RegistrationStatus.approved:
        title = 'Kayıt Onaylandı';
        body = '${event.title} etkinliğine katılımınız onaylandı!';
        break;
      case RegistrationStatus.rejected:
        title = 'Kayıt Reddedildi';
        body =
            '${event.title} etkinliğine katılım talebiniz reddedildi.${registration.rejectionReason != null ? '\nNeden: ${registration.rejectionReason}' : ''}';
        break;
      case RegistrationStatus.cancelled:
        title = 'Kayıt İptal Edildi';
        body = '${event.title} etkinliğine katılımınız iptal edildi.';
        break;
      default:
        return;
    }

    await _localNotifications.show(
      registration.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_registration_channel',
          'Event Registrations',
          channelDescription:
              'Notifications for event registration status updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Send event reminder notification
  Future<void> sendEventReminder(EventModel event) async {
    const title = 'Etkinlik Hatırlatması';
    final body = '${event.title} etkinliği yakında başlayacak!';

    await sendEventNotification(
      eventId: event.id,
      title: title,
      body: body,
      data: {
        'type': 'reminder',
        'startDate': event.startDate.toIso8601String(),
      },
    );
  }
}

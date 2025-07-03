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
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(initializationSettings);
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
    final topic = 'event_$eventId';

    final message = {
      'notification': {
        'title': title,
        'body': body,
      },
      'data': {
        'eventId': eventId,
        ...?data,
      },
      'topic': topic,
    };

    // Store notification in Firestore
    await _firestore.collection('event_notifications').add({
      'eventId': eventId,
      'title': title,
      'body': body,
      'data': data,
      'sentAt': DateTime.now(),
    });

    // Send FCM notification using admin SDK
    // Note: This should be handled by Cloud Functions
    // Here we'll just store in Firestore and let Cloud Functions handle FCM
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

  // Schedule event reminder
  Future<void> scheduleEventReminder(EventModel event) async {
    final scheduledDate = event.startDate.subtract(const Duration(hours: 1));

    if (scheduledDate.isBefore(DateTime.now())) return;

    final zonedScheduleTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await _localNotifications.zonedSchedule(
      event.hashCode,
      'Etkinlik Hatırlatması',
      '${event.title} etkinliği 1 saat içinde başlayacak!',
      zonedScheduleTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminder_channel',
          'Event Reminders',
          channelDescription: 'Notifications for upcoming events',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

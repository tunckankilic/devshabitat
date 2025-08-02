import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/services/event/event_service.dart';
import 'package:devshabitat/app/services/notification/notification_service.dart';

class EventReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EventService _eventService = EventService();
  final NotificationService _notificationService = NotificationService();
  final String _collection = 'event_reminders';

  // Hatırlatıcı oluştur
  Future<void> createReminder({
    required String eventId,
    required String userId,
    required DateTime reminderTime,
    String? note,
    bool isCustom = false,
  }) async {
    final event = await _eventService.getEventById(eventId);
    if (event == null) {
      throw Exception('Etkinlik bulunamadı');
    }

    await _firestore.collection(_collection).add({
      'eventId': eventId,
      'userId': userId,
      'reminderTime': Timestamp.fromDate(reminderTime),
      'note': note,
      'isCustom': isCustom,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Varsayılan hatırlatıcıları oluştur
  Future<void> createDefaultReminders(String eventId, String userId) async {
    final event = await _eventService.getEventById(eventId);
    if (event == null) return;

    final startTime = event.startDate;

    // 1 gün önce
    await createReminder(
      eventId: eventId,
      userId: userId,
      reminderTime: startTime.subtract(const Duration(days: 1)),
    );

    // 1 saat önce
    await createReminder(
      eventId: eventId,
      userId: userId,
      reminderTime: startTime.subtract(const Duration(hours: 1)),
    );

    // 15 dakika önce
    await createReminder(
      eventId: eventId,
      userId: userId,
      reminderTime: startTime.subtract(const Duration(minutes: 15)),
    );
  }

  // Hatırlatıcıyı güncelle
  Future<void> updateReminder(
    String reminderId, {
    DateTime? reminderTime,
    String? note,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{
      if (reminderTime != null)
        'reminderTime': Timestamp.fromDate(reminderTime),
      if (note != null) 'note': note,
      if (isActive != null) 'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection(_collection).doc(reminderId).update(data);
  }

  // Hatırlatıcıyı sil
  Future<void> deleteReminder(String reminderId) async {
    await _firestore.collection(_collection).doc(reminderId).delete();
  }

  // Kullanıcının hatırlatıcılarını getir
  Future<List<Map<String, dynamic>>> getUserReminders(String userId) async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('reminderTime', isGreaterThan: Timestamp.fromDate(now))
        .where('isActive', isEqualTo: true)
        .orderBy('reminderTime')
        .get();

    final reminders = <Map<String, dynamic>>[];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final eventId = data['eventId'] as String;
      final event = await _eventService.getEventById(eventId);

      if (event != null) {
        reminders.add({
          'id': doc.id,
          ...data,
          'event': event.toMap(),
        });
      }
    }

    return reminders;
  }

  // Takvim entegrasyonu için ICS formatında veri oluştur
  String generateICSData(EventModel event) {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//DevsHabitat//Event Calendar//TR');
    buffer.writeln('BEGIN:VEVENT');
    buffer.writeln('UID:${event.id}@devshabitat.com');
    buffer.writeln('DTSTAMP:${_formatDateTime(DateTime.now())}');
    buffer.writeln('DTSTART:${_formatDateTime(event.startDate)}');
    buffer.writeln('DTEND:${_formatDateTime(event.endDate)}');
    buffer.writeln('SUMMARY:${event.title}');
    buffer.writeln('DESCRIPTION:${event.description}');
    buffer.writeln('LOCATION:${event.location}');
    buffer.writeln('END:VEVENT');
    buffer.writeln('END:VCALENDAR');
    return buffer.toString();
  }

  // ICS için tarih formatı
  String _formatDateTime(DateTime dt) {
    return '${dt.toUtc().toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.').first}Z';
  }

  // Yaklaşan hatırlatmaları kontrol et ve bildirim gönder
  Future<void> checkAndSendReminders() async {
    final now = DateTime.now();
    final fiveMinutesFromNow = now.add(const Duration(minutes: 5));

    final snapshot = await _firestore
        .collection(_collection)
        .where('reminderTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(now),
            isLessThanOrEqualTo: Timestamp.fromDate(fiveMinutesFromNow))
        .where('isActive', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final eventId = data['eventId'] as String;
      final userId = data['userId'] as String;
      final event = await _eventService.getEventById(eventId);

      if (event != null) {
        await _notificationService.sendEventReminder(
          userId: userId,
          eventId: eventId,
          eventTitle: event.title,
          reminderTime: (data['reminderTime'] as Timestamp).toDate(),
        );

        // Hatırlatıcıyı pasif yap
        await updateReminder(doc.id, isActive: false);
      }
    }
  }

  // Tüm hatırlatıcıları kaldır
  Future<void> removeAllReminders(String eventId, String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

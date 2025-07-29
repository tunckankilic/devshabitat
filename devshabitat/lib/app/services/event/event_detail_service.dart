import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event/event_model.dart';
import 'package:logger/logger.dart';

class EventDetailService extends GetxService {
  final _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  Future<EventModel?> getEventDetails(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      _logger.e('Etkinlik detayları alınırken hata: $e');
      throw Exception(
          'Etkinlik bilgileri şu anda yüklenemiyor. Lütfen daha sonra tekrar deneyin.');
    }
  }

  Future<List<Map<String, dynamic>>> getEventParticipants(
      String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) return [];

      final participants =
          eventDoc.data()?['participants'] as List<dynamic>? ?? [];
      final participantsData = <Map<String, dynamic>>[];

      for (final participantId in participants) {
        try {
          final userDoc =
              await _firestore.collection('users').doc(participantId).get();
          if (userDoc.exists) {
            participantsData.add({
              'id': participantId,
              'displayName': userDoc.data()?['displayName'] ?? 'Anonim',
              'email': userDoc.data()?['email'] ?? '',
              'photoURL': userDoc.data()?['photoURL'] ?? '',
            });
          }
        } catch (e) {
          _logger.w('Katılımcı bilgileri alınırken hata: $e');
        }
      }

      return participantsData;
    } catch (e) {
      _logger.e('Katılımcılar alınırken hata: $e');
      return [];
    }
  }

  Future<Map<String, int>> getEventStatistics(String eventId) async {
    try {
      final stats = <String, int>{
        'totalViews': 0,
        'totalShares': 0,
        'totalComments': 0,
        'totalLikes': 0,
      };

      // Get comments count
      final commentsSnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .get();
      stats['totalComments'] = commentsSnapshot.docs.length;

      // Get total likes from comments
      int totalLikes = 0;
      for (final doc in commentsSnapshot.docs) {
        final likes = doc.data()['likes'] as List<dynamic>? ?? [];
        totalLikes += likes.length;
      }
      stats['totalLikes'] = totalLikes;

      // Get RSVP counts
      final rsvpSnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('rsvp')
          .get();

      int goingCount = 0;
      int maybeCount = 0;
      int notGoingCount = 0;

      for (final doc in rsvpSnapshot.docs) {
        final status = doc.data()['status'] as String?;
        if (status != null) {
          if (status == 'RSVPStatus.going') {
            goingCount++;
          } else if (status == 'RSVPStatus.maybe') {
            maybeCount++;
          } else if (status == 'RSVPStatus.notGoing') {
            notGoingCount++;
          }
        }
      }

      stats['goingCount'] = goingCount;
      stats['maybeCount'] = maybeCount;
      stats['notGoingCount'] = notGoingCount;

      return stats;
    } catch (e) {
      _logger.e('Etkinlik istatistikleri alınırken hata: $e');
      return <String, int>{};
    }
  }

  Future<void> incrementEventViews(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'viewCount': FieldValue.increment(1),
        'lastViewed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Görüntüleme sayısı artırılırken hata: $e');
    }
  }

  Future<void> addEventShare(String eventId, String sharedBy) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('shares')
          .add({
        'sharedBy': sharedBy,
        'sharedAt': FieldValue.serverTimestamp(),
      });

      // Increment share count in event document
      await _firestore.collection('events').doc(eventId).update({
        'shareCount': FieldValue.increment(1),
      });
    } catch (e) {
      _logger.e('Paylaşım kaydedilirken hata: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEventReminders(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('reminders')
          .get();

      final reminders = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        reminders.add({
          'id': doc.id,
          'userId': data['userId'],
          'createdAt': data['createdAt'],
          'reminderTime': data['reminderTime'],
        });
      }

      return reminders;
    } catch (e) {
      _logger.e('Hatırlatıcılar alınırken hata: $e');
      return [];
    }
  }

  Future<void> sendEventNotification(
      String eventId, String title, String message) async {
    try {
      // Get all users who have reminders for this event
      final reminders = await getEventReminders(eventId);

      for (final reminder in reminders) {
        final userId = reminder['userId'] as String;

        // Create notification document
        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': title,
          'message': message,
          'type': 'event_reminder',
          'eventId': eventId,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    } catch (e) {
      _logger.e('Etkinlik bildirimi gönderilirken hata: $e');
    }
  }

  Future<Map<String, dynamic>?> getEventAnalytics(String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) return null;

      final data = eventDoc.data()!;
      final stats = await getEventStatistics(eventId);
      final participants = await getEventParticipants(eventId);

      return {
        'event': data,
        'statistics': stats,
        'participants': participants,
        'participantCount': participants.length,
        'viewCount': data['viewCount'] ?? 0,
        'shareCount': data['shareCount'] ?? 0,
      };
    } catch (e) {
      _logger.e('Etkinlik analitikleri alınırken hata: $e');
      return null;
    }
  }

  Future<void> updateEventStatus(String eventId, String status) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Etkinlik durumu güncellenirken hata: $e');
      throw Exception('Etkinlik durumu güncellenirken bir hata oluştu');
    }
  }

  Future<List<Map<String, dynamic>>> getSimilarEvents(String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) return [];

      final eventData = eventDoc.data()!;
      final categories = eventData['categories'] as List<dynamic>? ?? [];

      // Find events with similar categories or type
      Query query = _firestore
          .collection('events')
          .where('id', isNotEqualTo: eventId)
          .where('startDate', isGreaterThan: Timestamp.now())
          .limit(5);

      if (categories.isNotEmpty) {
        query = query.where('categories', arrayContainsAny: categories);
      }

      final snapshot = await query.get();
      final similarEvents = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          similarEvents.add({
            'id': doc.id,
            'title': data['title'] ?? '',
            'description': data['description'] ?? '',
            'startDate': data['startDate'],
            'type': data['type'] ?? '',
            'venueAddress': data['venueAddress'] ?? '',
            'participantCount':
                (data['participants'] as List<dynamic>? ?? []).length,
            'participantLimit': data['participantLimit'] ?? 0,
          });
        }
      }

      return similarEvents;
    } catch (e) {
      _logger.e('Benzer etkinlikler alınırken hata: $e');
      return [];
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/models/event/event_registration_model.dart';
import 'package:devshabitat/app/services/event/event_service.dart';
import 'package:devshabitat/app/services/event/event_registration_service.dart';

class EventParticipationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EventService _eventService = EventService();
  final EventRegistrationService _registrationService =
      EventRegistrationService();
  final String _collection = 'event_participants';

  // Katılımcı onaylama
  Future<void> approveParticipant(String eventId, String registrationId) async {
    final registration = await _firestore
        .collection('event_registrations')
        .doc(registrationId)
        .get();

    if (!registration.exists) {
      throw Exception('Kayıt bulunamadı');
    }

    final event = await _eventService.getEventById(eventId);
    if (event == null) {
      throw Exception('Etkinlik bulunamadı');
    }

    // Kapasite kontrolü
    if (event.participants.length >= event.participantLimit) {
      // Bekleme listesine al
      await _addToWaitingList(eventId, registrationId);
      return;
    }

    // Katılımcıyı onayla
    await _registrationService.updateRegistrationStatus(
      registrationId,
      RegistrationStatus.approved,
    );

    // Katılımcı listesini güncelle
    await _firestore.collection(_collection).doc(registrationId).set({
      'eventId': eventId,
      'registrationId': registrationId,
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  // Katılımcı reddetme
  Future<void> rejectParticipant(
    String eventId,
    String registrationId, {
    String? reason,
  }) async {
    await _registrationService.updateRegistrationStatus(
      registrationId,
      RegistrationStatus.rejected,
      rejectionReason: reason,
    );

    // Bekleme listesinden bir kişiyi onayla
    await _promoteFromWaitingList(eventId);
  }

  // Bekleme listesine ekleme
  Future<void> _addToWaitingList(String eventId, String registrationId) async {
    await _firestore.collection('event_waiting_list').add({
      'eventId': eventId,
      'registrationId': registrationId,
      'addedAt': FieldValue.serverTimestamp(),
      'position': await _getNextWaitingListPosition(eventId),
    });

    await _registrationService.updateRegistrationStatus(
      registrationId,
      RegistrationStatus.waitlisted,
    );
  }

  // Bekleme listesi pozisyonu alma
  Future<int> _getNextWaitingListPosition(String eventId) async {
    final waitingList = await _firestore
        .collection('event_waiting_list')
        .where('eventId', isEqualTo: eventId)
        .orderBy('position', descending: true)
        .limit(1)
        .get();

    if (waitingList.docs.isEmpty) return 1;
    return (waitingList.docs.first.data()['position'] as int) + 1;
  }

  // Bekleme listesinden katılımcı yükseltme
  Future<void> _promoteFromWaitingList(String eventId) async {
    final waitingList = await _firestore
        .collection('event_waiting_list')
        .where('eventId', isEqualTo: eventId)
        .orderBy('position')
        .limit(1)
        .get();

    if (waitingList.docs.isEmpty) return;

    final nextParticipant = waitingList.docs.first;
    final registrationId = nextParticipant.data()['registrationId'] as String;

    // Katılımcıyı onayla
    await approveParticipant(eventId, registrationId);

    // Bekleme listesinden kaldır
    await nextParticipant.reference.delete();
  }

  // Katılımcı listesi export (CSV)
  Future<String> exportParticipantsToCSV(String eventId) async {
    final registrations = await _registrationService
        .getRegistrationsByEvent(eventId, limit: 1000);

    final StringBuffer csv = StringBuffer();
    csv.writeln('ID,Ad Soyad,Email,Kayıt Tarihi,Durum');

    for (var registration in registrations) {
      final userData =
          await _firestore.collection('users').doc(registration.userId).get();
      final user = userData.data() ?? {};

      csv.writeln(
          '${registration.id},${user['name']},${user['email']},${registration.registrationDate},${registration.status}');
    }

    return csv.toString();
  }

  // Katılımcı istatistikleri
  Future<Map<String, dynamic>> getParticipationStats(String eventId) async {
    final stats = {
      'total': 0,
      'approved': 0,
      'waitlisted': 0,
      'rejected': 0,
      'cancelled': 0,
    };

    final registrations = await _registrationService
        .getRegistrationsByEvent(eventId, limit: 1000);

    for (var registration in registrations) {
      stats['total'] = (stats['total'] as int) + 1;

      switch (registration.status) {
        case RegistrationStatus.approved:
          stats['approved'] = (stats['approved'] as int) + 1;
          break;
        case RegistrationStatus.waitlisted:
          stats['waitlisted'] = (stats['waitlisted'] as int) + 1;
          break;
        case RegistrationStatus.rejected:
          stats['rejected'] = (stats['rejected'] as int) + 1;
          break;
        case RegistrationStatus.cancelled:
          stats['cancelled'] = (stats['cancelled'] as int) + 1;
          break;
        default:
          break;
      }
    }

    return stats;
  }

  // Toplu işlem: Durumu güncelleme
  Future<void> bulkUpdateStatus(
    String eventId,
    List<String> registrationIds,
    RegistrationStatus newStatus,
  ) async {
    final batch = _firestore.batch();

    for (var registrationId in registrationIds) {
      final ref =
          _firestore.collection('event_registrations').doc(registrationId);
      batch.update(ref, {
        'status': newStatus.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}

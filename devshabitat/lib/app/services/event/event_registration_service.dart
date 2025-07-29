import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/event/event_registration_model.dart';
import 'package:devshabitat/app/services/event/event_service.dart';

class EventRegistrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'event_registrations';
  final EventService _eventService = EventService();

  // Register for an event
  Future<EventRegistrationModel> registerForEvent(
    String eventId,
    String userId,
  ) async {
    // Check if user is already registered
    final existingRegistration =
        await getRegistrationByEventAndUser(eventId, userId);
    if (existingRegistration != null) {
      throw Exception('User is already registered for this event');
    }

    // Get event to check participant limit
    final event = await _eventService.getEventById(eventId);
    if (event == null) {
      throw Exception('Event not found');
    }

    if (event.participants.length >= event.participantLimit) {
      throw Exception('Event has reached participant limit');
    }

    // Create registration
    final registration = EventRegistrationModel(
      id: '', // Will be set after creation
      eventId: eventId,
      userId: userId,
      registrationDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final docRef =
        await _firestore.collection(_collection).add(registration.toJson());

    // Update participant count
    await _eventService.updateParticipantCount(
        eventId, event.participants.length + 1);

    return registration.copyWith(id: docRef.id);
  }

  // Get registration by event and user
  Future<EventRegistrationModel?> getRegistrationByEventAndUser(
    String eventId,
    String userId,
  ) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return EventRegistrationModel.fromFirestore(querySnapshot.docs.first);
  }

  // Get registrations by event
  Future<List<EventRegistrationModel>> getRegistrationsByEvent(
    String eventId, {
    int limit = 10,
    DocumentSnapshot? startAfter,
    RegistrationStatus? status,
  }) async {
    Query query =
        _firestore.collection(_collection).where('eventId', isEqualTo: eventId);

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString());
    }

    query = query.orderBy('registrationDate', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => EventRegistrationModel.fromFirestore(doc))
        .toList();
  }

  // Get registrations by user
  Future<List<EventRegistrationModel>> getRegistrationsByUser(
    String userId, {
    int limit = 10,
    DocumentSnapshot? startAfter,
    RegistrationStatus? status,
  }) async {
    Query query =
        _firestore.collection(_collection).where('userId', isEqualTo: userId);

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString());
    }

    query = query.orderBy('registrationDate', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => EventRegistrationModel.fromFirestore(doc))
        .toList();
  }

  // Update registration status
  Future<void> updateRegistrationStatus(
    String registrationId,
    RegistrationStatus status, {
    String? rejectionReason,
  }) async {
    final data = {
      'status': status.toString(),
      'updatedAt': DateTime.now(),
    };

    if (status == RegistrationStatus.approved) {
      data['approvalDate'] = DateTime.now();
    } else if (status == RegistrationStatus.rejected &&
        rejectionReason != null) {
      data['rejectionReason'] = rejectionReason;
    }

    await _firestore.collection(_collection).doc(registrationId).update(data);
  }

  // Cancel registration
  Future<void> cancelRegistration(String registrationId) async {
    final registration =
        await _firestore.collection(_collection).doc(registrationId).get();

    if (!registration.exists) {
      throw Exception('Registration not found');
    }

    final data = registration.data() as Map<String, dynamic>;
    final eventId = data['eventId'] as String;

    // Update registration status
    await updateRegistrationStatus(
        registrationId, RegistrationStatus.cancelled);

    // Update participant count
    final event = await _eventService.getEventById(eventId);
    if (event != null && event.participants.isNotEmpty) {
      await _eventService.updateParticipantCount(
          eventId, event.participants.length - 1);
    }
  }
}

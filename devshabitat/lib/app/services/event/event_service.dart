import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/models/event/event_category_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'events';

  // Create event
  Future<EventModel> createEvent(EventModel event) async {
    final docRef = await _firestore.collection(_collection).add(event.toMap());
    return EventModel.fromMap({...event.toMap(), 'id': docRef.id});
  }

  // Get event by id
  Future<EventModel?> getEventById(String eventId) async {
    final docSnapshot =
        await _firestore.collection(_collection).doc(eventId).get();
    if (!docSnapshot.exists) return null;
    return EventModel.fromMap({...docSnapshot.data()!, 'id': docSnapshot.id});
  }

  // Get all events with pagination
  Future<List<EventModel>> getEvents({
    int limit = 10,
    DocumentSnapshot? startAfter,
    List<String>? categoryIds,
    EventType? type,
    bool? isActive,
  }) async {
    Query query = _firestore.collection(_collection);

    if (categoryIds != null && categoryIds.isNotEmpty) {
      query = query.where('categories', arrayContainsAny: categoryIds);
    }

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString());
    }

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    query = query.orderBy('startDate', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => EventModel.fromMap(
            Map<String, dynamic>.from(doc.data() as Map<String, dynamic>)
              ..['id'] = doc.id))
        .toList();
  }

  // Update event
  Future<void> updateEvent(EventModel event) async {
    await _firestore
        .collection(_collection)
        .doc(event.id)
        .update(event.toMap());
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(_collection).doc(eventId).delete();
  }

  // Get events by organizer
  Future<List<EventModel>> getEventsByOrganizer(
    String organizerId, {
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore
        .collection(_collection)
        .where('createdBy', isEqualTo: organizerId)
        .orderBy('startDate', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => EventModel.fromMap(
            Map<String, dynamic>.from(doc.data() as Map<String, dynamic>)
              ..['id'] = doc.id))
        .toList();
  }

  // Get upcoming events
  Future<List<EventModel>> getUpcomingEvents({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    final now = DateTime.now();
    Query query = _firestore
        .collection(_collection)
        .where('startDate', isGreaterThan: now)
        .where('isActive', isEqualTo: true)
        .orderBy('startDate')
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => EventModel.fromMap(
            Map<String, dynamic>.from(doc.data() as Map<String, dynamic>)
              ..['id'] = doc.id))
        .toList();
  }

  // Update event participant count
  Future<void> updateParticipantCount(String eventId, int count) async {
    await _firestore.collection(_collection).doc(eventId).update(
        {'participants': List.generate(count, (index) => 'user$index')});
  }

  // Update event call status
  Future<void> updateEventCallStatus(String eventId, bool hasActiveCall) async {
    await _firestore.collection(_collection).doc(eventId).update({
      'hasActiveCall': hasActiveCall,
      'lastCallUpdateTime': FieldValue.serverTimestamp(),
    });
  }

  // Get event categories
  Future<List<EventCategoryModel>> getEventCategories() async {
    final querySnapshot = await _firestore.collection('event_categories').get();
    return querySnapshot.docs
        .map((doc) => EventCategoryModel.fromFirestore(doc))
        .toList();
  }
}

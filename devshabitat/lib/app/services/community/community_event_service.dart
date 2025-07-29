import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event/event_model.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class CommunityEventService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = Get.find<AuthController>();

  Future<List<EventModel>> getEventsForCommunity(String communityId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('communityId', isEqualTo: communityId)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting community events: $e');
      return [];
    }
  }

  Future<void> createEvent(EventModel event, String communityId) async {
    try {
      final eventData = event.toMap();
      eventData['communityId'] = communityId;
      eventData['createdBy'] = _auth.currentUser?.uid;
      eventData['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('events').add(eventData);
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      final eventData = event.toMap();
      eventData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('events').doc(event.id).update(eventData);
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  Future<void> joinEvent(String eventId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore.collection('events').doc(eventId).update({
        'participants': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      print('Error joining event: $e');
      rethrow;
    }
  }

  Future<void> leaveEvent(String eventId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore.collection('events').doc(eventId).update({
        'participants': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print('Error leaving event: $e');
      rethrow;
    }
  }
}

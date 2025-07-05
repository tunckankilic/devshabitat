import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityEventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('community_events')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    try {
      await _firestore.collection('community_events').add({
        ...eventData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }
}

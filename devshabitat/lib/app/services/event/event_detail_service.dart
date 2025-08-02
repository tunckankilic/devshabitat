import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event/event_model.dart';
import '../../controllers/event/event_detail_controller.dart';

class EventDetailService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<EventModel> getEventById(String eventId) async {
    final doc = await _firestore.collection('events').doc(eventId).get();
    if (!doc.exists) {
      throw Exception('Etkinlik bulunamadı');
    }
    return EventModel.fromMap({...doc.data()!, 'id': doc.id});
  }

  Future<void> reportEvent(String eventId) async {
    final userId = Get.find<String>(tag: 'userId');
    await _firestore.collection('event_reports').add({
      'eventId': eventId,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitFeedback({
    required String eventId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    await _firestore.collection('event_feedback').add({
      'eventId': eventId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addComment(String eventId, EventComment comment) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .doc(comment.id)
        .set(comment.toMap());
  }

  Future<void> deleteComment(String eventId, String commentId) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  Future<void> toggleCommentLike(
      String eventId, String commentId, String userId) async {
    final commentRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .doc(commentId);

    final comment = await commentRef.get();
    final likes = List<String>.from(comment.data()?['likes'] ?? []);

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await commentRef.update({'likes': likes});
  }

  Future<List<EventComment>> getComments(String eventId) async {
    final snapshot = await _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => EventComment.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }
}

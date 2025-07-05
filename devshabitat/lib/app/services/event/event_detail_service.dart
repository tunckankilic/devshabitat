import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event/event_model.dart';

class EventDetailService extends GetxService {
  final _firestore = FirebaseFirestore.instance;

  Future<EventModel?> getEventDetails(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Etkinlik detayları alınırken hata oluştu: $e');
    }
  }
}

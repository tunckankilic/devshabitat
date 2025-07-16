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
        return EventModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _logger.e('Etkinlik detayları alınırken hata: $e');
      throw Exception(
          'Etkinlik bilgileri şu anda yüklenemiyor. Lütfen daha sonra tekrar deneyin.');
    }
  }
}

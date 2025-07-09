import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../video/call_manager_service.dart';
import '../event/event_service.dart';
import '../../models/event/event_model.dart';
import '../../models/video/call_model.dart';

class VideoEventIntegrationService extends GetxService {
  final CallManagerService _callManagerService = Get.find();
  final EventService _eventService = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> startEventVideoCall(EventModel event) async {
    try {
      final organizerName = await getOrganizerName(event.id);
      await _callManagerService.initiateCall(
        participantIds: [], // Boş liste ile başlat
        initiatorId: event.organizerId,
        initiatorName: organizerName,
        type: CallType.video,
      );

      // Event servisine call status metodunu ekleyelim
      await _eventService.updateEventCallStatus(event.id, true);
    } catch (e) {
      print('Error starting event video call: $e');
      rethrow;
    }
  }

  Future<void> endEventVideoCall(String eventId) async {
    try {
      await _callManagerService.endCall();
      // Event servisine call status metodunu ekleyelim
      await _eventService.updateEventCallStatus(eventId, false);
    } catch (e) {
      print('Error ending event video call: $e');
      rethrow;
    }
  }

  Future<String> getOrganizerName(String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        return 'Unknown Organizer';
      }

      final organizerId = eventDoc.data()?['organizerId'];
      if (organizerId == null) {
        return 'Unknown Organizer';
      }

      final organizerDoc =
          await _firestore.collection('users').doc(organizerId).get();

      return organizerDoc.data()?['name'] ?? 'Unknown Organizer';
    } catch (e) {
      print('Error fetching organizer name: $e');
      return 'Unknown Organizer';
    }
  }
}

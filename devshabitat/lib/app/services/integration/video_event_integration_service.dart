import 'package:get/get.dart';
import '../video/call_manager_service.dart';
import '../event/event_service.dart';
import '../../models/event/event_model.dart';
import '../../models/video/call_model.dart';

class VideoEventIntegrationService extends GetxService {
  final CallManagerService _callManagerService = Get.find();
  final EventService _eventService = Get.find();

  Future<void> startEventVideoCall(EventModel event) async {
    try {
      final CallModel call = CallModel(
        eventId: event.id,
        title: 'Event: ${event.title}',
        startTime: DateTime.now(),
        participants: event.participants ?? [],
      );

      await _callManagerService.initializeCall(call);
      await _eventService.updateEventCallStatus(event.id!, true);
    } catch (e) {
      print('Error starting event video call: $e');
      rethrow;
    }
  }

  Future<void> endEventVideoCall(String eventId) async {
    try {
      await _callManagerService.endCall(eventId);
      await _eventService.updateEventCallStatus(eventId, false);
    } catch (e) {
      print('Error ending event video call: $e');
      rethrow;
    }
  }
}

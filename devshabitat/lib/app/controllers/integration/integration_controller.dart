// ignore_for_file: avoid_print

import 'package:get/get.dart';
import '../../services/integration/video_event_integration_service.dart';
import '../../services/integration/community_event_integration_service.dart';
import '../../services/integration/location_event_integration_service.dart';
import '../../models/event/event_model.dart';
import '../../models/community/community_model.dart';
import '../../models/location/location_model.dart';

class IntegrationController extends GetxController {
  final VideoEventIntegrationService _videoEventService = Get.find();
  final CommunityEventIntegrationService _communityEventService = Get.find();
  final LocationEventIntegrationService _locationEventService = Get.find();

  // Video-Etkinlik Entegrasyonu
  Future<void> handleEventVideoIntegration(EventModel event) async {
    try {
      if (event.isStarting) {
        await _videoEventService.startEventVideoCall(event);
      } else if (event.isEnding) {
        await _videoEventService.endEventVideoCall(event.id);
      }
    } catch (e) {
      print('Error in event-video integration: $e');
      rethrow;
    }
  }

  // Topluluk-Etkinlik Entegrasyonu
  Future<void> handleCommunityEventIntegration(
      EventModel event, CommunityModel community) async {
    try {
      await _communityEventService.linkEventToCommunity(event.id, community.id);
    } catch (e) {
      print('Error in community-event integration: $e');
      rethrow;
    }
  }

  // Konum-Etkinlik Entegrasyonu
  Future<void> handleLocationEventIntegration(
      LocationModel userLocation, String userToken) async {
    try {
      await _locationEventService.checkAndNotifyNearbyEvents(
          userLocation, userToken);
    } catch (e) {
      print('Error in location-event integration: $e');
      rethrow;
    }
  }

  // Yakındaki Etkinlikleri Getir
  Future<List<EventModel>> getNearbyEvents(LocationModel userLocation) async {
    try {
      return await _locationEventService.getNearbyEvents(userLocation);
    } catch (e) {
      print('Error getting nearby events: $e');
      rethrow;
    }
  }
}

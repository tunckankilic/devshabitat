import 'package:get/get.dart';
import '../community/community_service.dart';
import '../event/event_service.dart';
import '../../models/event/event_model.dart';
import '../../models/community/community_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CommunityEventIntegrationService extends GetxService {
  final CommunityService _communityService = Get.find();
  final EventService _eventService = Get.find();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> sendCommunityEventNotification(
      EventModel event, CommunityModel community) async {
    try {
      await _firebaseMessaging.subscribeToTopic('community_${community.id}');

      await FirebaseMessaging.instance.sendMessage(
        to: '/topics/community_${community.id}',
        data: {
          'type': 'community_event',
          'eventId': event.id,
          'communityId': community.id!,
          'route': '/event/detail/${event.id}',
          'title': 'Yeni Topluluk Etkinliği',
          'body':
              '${community.name} topluluğunda yeni bir etkinlik: ${event.title}',
        },
      );
    } catch (e) {
      print('Error sending community event notification: $e');
      rethrow;
    }
  }

  Future<void> linkEventToCommunity(String eventId, String communityId) async {
    try {
      final existingEvent = await _eventService.getEventById(eventId);
      if (existingEvent == null) {
        throw Exception('Event not found');
      }

      final updatedCategoryIds = List<String>.from(existingEvent.categoryIds)
        ..add(communityId);

      final updatedEvent = existingEvent.copyWith(
        categoryIds: updatedCategoryIds,
        updatedAt: DateTime.now(),
      );
      await _eventService.updateEvent(updatedEvent);

      final community = await _communityService.getCommunity(communityId);

      if (community != null) {
        await sendCommunityEventNotification(updatedEvent, community);
      }
    } catch (e) {
      print('Error linking event to community: $e');
      rethrow;
    }
  }
}

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
      final List<String> memberTokens =
          await _communityService.getMemberTokens(community.id!);

      for (final token in memberTokens) {
        await _firebaseMessaging.send(RemoteMessage(
          token: token,
          notification: RemoteNotification(
            title: 'Yeni Topluluk Etkinliği',
            body:
                '${community.name} topluluğunda yeni bir etkinlik: ${event.title}',
          ),
          data: {
            'type': 'community_event',
            'eventId': event.id!,
            'communityId': community.id!,
            'route': '/event/detail/${event.id}'
          },
        ));
      }
    } catch (e) {
      print('Error sending community event notification: $e');
      rethrow;
    }
  }

  Future<void> linkEventToCommunity(String eventId, String communityId) async {
    try {
      await _eventService.updateEventCommunity(eventId, communityId);
      final event = await _eventService.getEventById(eventId);
      final community = await _communityService.getCommunityById(communityId);
      await sendCommunityEventNotification(event, community);
    } catch (e) {
      print('Error linking event to community: $e');
      rethrow;
    }
  }
}

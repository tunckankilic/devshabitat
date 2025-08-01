// ignore_for_file: deprecated_member_use

import 'package:get/get.dart';
import '../community/community_service.dart';
import '../event/event_service.dart';
import '../../models/event/event_model.dart';
import '../../models/community/community_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../fcm_service.dart';

class CommunityEventIntegrationService extends GetxService {
  final CommunityService _communityService = Get.find();
  final EventService _eventService = Get.find();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FCMService _fcmService = Get.find();

  Future<void> sendCommunityEventNotification(
      EventModel event, CommunityModel community) async {
    try {
      await _firebaseMessaging.subscribeToTopic('community_${community.id}');

      await _fcmService.sendNotification(
        topic: 'community_${community.id}',
        title: 'Yeni Topluluk Etkinliği',
        body:
            '${community.name} topluluğunda yeni bir etkinlik: ${event.title}',
        data: {
          'type': 'community_event',
          'eventId': event.id,
          'communityId': community.id,
          'route': '/event/detail/${event.id}'
        },
      );
    } catch (e) {
      print('Bildirim gönderme hatası: $e');
      rethrow;
    }
  }

  Future<void> linkEventToCommunity(String eventId, String communityId) async {
    try {
      final existingEvent = await _eventService.getEventById(eventId);
      if (existingEvent == null) {
        throw Exception('Event not found');
      }

      final updatedCategories = List<String>.from(existingEvent.categories)
        ..add(communityId);

      final updatedEvent = EventModel(
        id: existingEvent.id,
        title: existingEvent.title,
        description: existingEvent.description,
        type: existingEvent.type,
        onlineMeetingUrl: existingEvent.onlineMeetingUrl,
        venueAddress: existingEvent.venueAddress,
        startDate: existingEvent.startDate,
        endDate: existingEvent.endDate,
        participantLimit: existingEvent.participantLimit,
        categories: updatedCategories,
        participants: existingEvent.participants,
        communityId: existingEvent.communityId,
        createdBy: existingEvent.createdBy,
        createdAt: existingEvent.createdAt,
        updatedAt: DateTime.now(),
        location: existingEvent.location,
      );
      await _eventService.updateEvent(updatedEvent);

      final community = await _communityService.getCommunity(communityId);
      await sendCommunityEventNotification(updatedEvent, community);
    } catch (e) {
      print('Error linking event to community: $e');
      rethrow;
    }
  }
}

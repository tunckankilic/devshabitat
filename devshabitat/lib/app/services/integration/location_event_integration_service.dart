import 'package:get/get.dart';
import '../location/location_tracking_service.dart';
import '../event/event_service.dart';
import '../../models/event/event_model.dart';
import '../../models/location/location_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationEventIntegrationService extends GetxService {
  final LocationTrackingService _locationService = Get.find();
  final EventService _eventService = Get.find();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static const double NEARBY_THRESHOLD_KM = 5.0; // 5 km yarıçap

  Future<List<EventModel>> getNearbyEvents(LocationModel userLocation) async {
    try {
      final allEvents = await _eventService.getUpcomingEvents();
      return allEvents.where((event) {
        // Sadece offline etkinlikleri kontrol et
        if (event.location != EventLocation.offline ||
            event.venueAddress == null) {
          return false;
        }

        // Etkinlik konumunu geocode servisi ile almamız gerekiyor
        // Şimdilik basit bir kontrol yapıyoruz
        return true; // TODO: Implement proper location check
      }).toList();
    } catch (e) {
      print('Error getting nearby events: $e');
      rethrow;
    }
  }

  Future<void> sendNearbyEventNotification(
      EventModel event, String userToken) async {
    try {
      final message = {
        'data': {
          'type': 'nearby_event',
          'eventId': event.id,
          'route': '/event/detail/${event.id}'
        }
      };

      await FirebaseMessaging.instance.sendMessage(
        to: userToken,
        data: message['data'] as Map<String, String>,
      );
    } catch (e) {
      print('Error sending nearby event notification: $e');
      rethrow;
    }
  }

  Future<void> checkAndNotifyNearbyEvents(
      LocationModel userLocation, String userToken) async {
    try {
      final nearbyEvents = await getNearbyEvents(userLocation);
      for (final event in nearbyEvents) {
        await sendNearbyEventNotification(event, userToken);
      }
    } catch (e) {
      print('Error checking and notifying nearby events: $e');
      rethrow;
    }
  }
}

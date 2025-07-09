import 'package:get/get.dart';
import '../event/event_service.dart';
import '../../models/event/event_model.dart';
import '../../models/location/location_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class LocationEventIntegrationService extends GetxService {
  final EventService _eventService = Get.find();

  static const double NEARBY_THRESHOLD_KM = 5.0; // 5 km yarıçap

  Future<List<EventModel>> getNearbyEvents(LocationModel userLocation) async {
    try {
      final allEvents = await _eventService.getUpcomingEvents();
      return allEvents.where((event) {
        // Sadece offline etkinlikleri kontrol et
        if (event.location != EventLocation.offline || event.geoPoint == null) {
          return false;
        }

        // Etkinlik ve kullanıcı konumu arasındaki mesafeyi hesapla
        final eventLatLng =
            LatLng(event.geoPoint!.latitude, event.geoPoint!.longitude);
        final userLatLng =
            LatLng(userLocation.latitude, userLocation.longitude);

        final distanceInKm = _calculateDistance(eventLatLng, userLatLng);
        return distanceInKm <= NEARBY_THRESHOLD_KM;
      }).toList();
    } catch (e) {
      print('Error getting nearby events: $e');
      rethrow;
    }
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Dünya yarıçapı (km)
    final lat1 = point1.latitude * (pi / 180);
    final lat2 = point2.latitude * (pi / 180);
    final dLat = (point2.latitude - point1.latitude) * (pi / 180);
    final dLon = (point2.longitude - point1.longitude) * (pi / 180);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
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

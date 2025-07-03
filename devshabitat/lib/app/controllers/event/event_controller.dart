import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/models/event/event_registration_model.dart';
import 'package:devshabitat/app/services/event/event_service.dart';
import 'package:devshabitat/app/services/event/event_registration_service.dart';
import 'package:devshabitat/app/services/event/event_notification_service.dart';
import 'package:devshabitat/app/controllers/auth_controller.dart';

class EventController extends GetxController {
  final EventService _eventService = EventService();
  final EventRegistrationService _registrationService =
      EventRegistrationService();
  final EventNotificationService _notificationService =
      EventNotificationService();

  final events = <EventModel>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;
  DocumentSnapshot? lastDocument;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  // Load events with pagination
  Future<void> loadEvents({bool refresh = false}) async {
    if (isLoading.value) return;
    if (refresh) {
      events.clear();
      lastDocument = null;
      hasMore.value = true;
    }
    if (!hasMore.value) return;

    try {
      isLoading.value = true;
      final newEvents = await _eventService.getEvents(
        startAfter: lastDocument,
        isActive: true,
      );

      if (newEvents.isEmpty) {
        hasMore.value = false;
      } else {
        events.addAll(newEvents);
        lastDocument = newEvents.last as DocumentSnapshot;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Etkinlikler yüklenirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Register for event
  Future<void> registerForEvent(String eventId) async {
    try {
      final userId = Get.find<AuthController>().currentUser?.uid;
      if (userId == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }
      final registration = await _registrationService.registerForEvent(
        eventId,
        userId,
      );

      // Subscribe to event notifications
      await _notificationService.subscribeToEvent(eventId);

      Get.snackbar('Başarılı', 'Etkinliğe başarıyla kayıt oldunuz');
    } catch (e) {
      Get.snackbar('Hata', e.toString());
    }
  }

  // Cancel registration
  Future<void> cancelRegistration(String registrationId) async {
    try {
      await _registrationService.cancelRegistration(registrationId);
      Get.snackbar('Başarılı', 'Etkinlik kaydınız iptal edildi');
    } catch (e) {
      Get.snackbar('Hata', 'Kayıt iptal edilirken bir hata oluştu');
    }
  }

  // Get event details
  Future<EventModel?> getEventDetails(String eventId) async {
    try {
      return await _eventService.getEventById(eventId);
    } catch (e) {
      Get.snackbar('Hata', 'Etkinlik detayları alınırken bir hata oluştu');
      return null;
    }
  }

  // Get user registrations
  Future<List<EventRegistrationModel>> getUserRegistrations() async {
    try {
      final userId = Get.find<AuthController>().currentUser?.uid;
      if (userId == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }
      return await _registrationService.getRegistrationsByUser(userId);
    } catch (e) {
      Get.snackbar('Hata', 'Kayıtlarınız alınırken bir hata oluştu');
      return [];
    }
  }

  // Filter events by category
  Future<void> filterByCategory(List<String> categoryIds) async {
    events.clear();
    lastDocument = null;
    hasMore.value = true;

    try {
      isLoading.value = true;
      final filteredEvents = await _eventService.getEvents(
        categoryIds: categoryIds,
        isActive: true,
      );

      if (filteredEvents.isEmpty) {
        hasMore.value = false;
      } else {
        events.addAll(filteredEvents);
        lastDocument = filteredEvents.last as DocumentSnapshot;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Etkinlikler filtrelenirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter events by type
  Future<void> filterByType(EventType type) async {
    events.clear();
    lastDocument = null;
    hasMore.value = true;

    try {
      isLoading.value = true;
      final filteredEvents = await _eventService.getEvents(
        type: type,
        isActive: true,
      );

      if (filteredEvents.isEmpty) {
        hasMore.value = false;
      } else {
        events.addAll(filteredEvents);
        lastDocument = filteredEvents.last as DocumentSnapshot;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Etkinlikler filtrelenirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }
}

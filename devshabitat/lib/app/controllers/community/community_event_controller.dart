// ignore_for_file: avoid_print

import 'package:get/get.dart';
import '../../services/community/community_event_service.dart';
import '../../models/event/event_model.dart';
import '../../models/community/community_model.dart';
import '../../constants/app_strings.dart';

class CommunityEventController extends GetxController {
  final CommunityEventService eventService;
  final events = <EventModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final currentCommunity = Rxn<CommunityModel>();

  CommunityEventController({required this.eventService});

  @override
  void onInit() {
    super.onInit();
    ever(currentCommunity, (_) => loadEvents());
  }

  void setCommunity(CommunityModel community) {
    currentCommunity.value = community;
  }

  Future<void> loadEvents() async {
    if (currentCommunity.value == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final communityEvents = await eventService.getEventsForCommunity(
        currentCommunity.value!.id,
      );
      events.value = communityEvents;
    } catch (e) {
      errorMessage.value = AppStrings.errorLoadingEvents;
      print('Error loading community events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createEvent(EventModel event) async {
    if (currentCommunity.value == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await eventService.createEvent(
        event,
        currentCommunity.value!.id,
      );
      await loadEvents();
    } catch (e) {
      errorMessage.value = AppStrings.errorGeneric;
      print('Error creating community event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await eventService.updateEvent(event);
      await loadEvents();
    } catch (e) {
      errorMessage.value = AppStrings.errorGeneric;
      print('Error updating community event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await eventService.deleteEvent(eventId);
      await loadEvents();
    } catch (e) {
      errorMessage.value = AppStrings.errorGeneric;
      print('Error deleting community event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinEvent(String eventId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await eventService.joinEvent(eventId);
      await loadEvents();
    } catch (e) {
      errorMessage.value = AppStrings.errorGeneric;
      print('Error joining community event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> leaveEvent(String eventId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await eventService.leaveEvent(eventId);
      await loadEvents();
    } catch (e) {
      errorMessage.value = AppStrings.errorGeneric;
      print('Error leaving community event: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

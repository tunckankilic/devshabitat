import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/models/event/event_category_model.dart';
import 'package:devshabitat/app/services/event/event_service.dart';

class EventDiscoveryController extends GetxController {
  final EventService _eventService = EventService();

  final events = <EventModel>[].obs;
  final categories = <EventCategoryModel>[].obs;
  final selectedCategories = <String>[].obs;
  final selectedType = Rx<EventType?>(null);
  final isLoading = false.obs;
  final hasMore = true.obs;
  DocumentSnapshot? lastDocument;

  // Search filters
  final searchQuery = ''.obs;
  final showOnlineOnly = false.obs;
  final showOfflineOnly = false.obs;
  final showUpcomingOnly = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadEvents();
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      // TODO: Implement category loading from Firestore
      // This will be implemented when we create the category service
    } catch (e) {
      Get.snackbar('Hata', 'Kategoriler yüklenirken bir hata oluştu');
    }
  }

  // Load events with filters
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

      // Apply filters
      final filteredEvents = await _eventService.getEvents(
        startAfter: lastDocument,
        categoryIds: selectedCategories.isNotEmpty ? selectedCategories : null,
        type: selectedType.value,
        isActive: true,
      );

      // Apply additional filters in memory
      final now = DateTime.now();
      final filtered = filteredEvents.where((event) {
        // Apply location filter
        if (showOnlineOnly.value && event.location != EventLocation.online) {
          return false;
        }
        if (showOfflineOnly.value && event.location != EventLocation.offline) {
          return false;
        }

        // Apply upcoming filter
        if (showUpcomingOnly.value && event.startDate.isBefore(now)) {
          return false;
        }

        // Apply search query
        if (searchQuery.value.isNotEmpty) {
          final query = searchQuery.value.toLowerCase();
          return event.title.toLowerCase().contains(query) ||
              event.description.toLowerCase().contains(query);
        }

        return true;
      }).toList();

      if (filtered.isEmpty) {
        hasMore.value = false;
      } else {
        events.addAll(filtered);
        lastDocument = filteredEvents.last as DocumentSnapshot;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Etkinlikler yüklenirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle category filter
  void toggleCategory(String categoryId) {
    if (selectedCategories.contains(categoryId)) {
      selectedCategories.remove(categoryId);
    } else {
      selectedCategories.add(categoryId);
    }
    loadEvents(refresh: true);
  }

  // Update event type filter
  void updateEventType(EventType? type) {
    selectedType.value = type;
    loadEvents(refresh: true);
  }

  // Update location filters
  void toggleOnlineOnly(bool value) {
    showOnlineOnly.value = value;
    if (value) showOfflineOnly.value = false;
    loadEvents(refresh: true);
  }

  void toggleOfflineOnly(bool value) {
    showOfflineOnly.value = value;
    if (value) showOnlineOnly.value = false;
    loadEvents(refresh: true);
  }

  // Update upcoming filter
  void toggleUpcomingOnly(bool value) {
    showUpcomingOnly.value = value;
    loadEvents(refresh: true);
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    loadEvents(refresh: true);
  }

  // Reset all filters
  void resetFilters() {
    selectedCategories.clear();
    selectedType.value = null;
    showOnlineOnly.value = false;
    showOfflineOnly.value = false;
    showUpcomingOnly.value = true;
    searchQuery.value = '';
    loadEvents(refresh: true);
  }
}

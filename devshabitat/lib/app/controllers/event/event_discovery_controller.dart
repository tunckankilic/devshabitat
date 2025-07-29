// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/models/event/event_category_model.dart';
import 'package:devshabitat/app/services/event/event_service.dart';
import 'package:devshabitat/app/services/location/location_tracking_service.dart';
import 'dart:math';

class EventDiscoveryController extends GetxController {
  final EventService _eventService = EventService();
  final LocationTrackingService _locationService =
      Get.find<LocationTrackingService>();
  late GoogleMapController _mapController;

  final events = <EventModel>[].obs;
  final categories = <EventCategoryModel>[].obs;
  final selectedCategories = <String>[].obs;
  final selectedType = Rx<EventType?>(null);
  final selectedDay = Rx<DateTime?>(null);
  final isLoading = false.obs;
  final hasMore = true.obs;
  DocumentSnapshot? lastDocument;

  // Map related variables
  final currentPosition =
      const LatLng(41.0082, 28.9784).obs; // İstanbul merkezi
  final mapType = MapType.normal.obs;
  final showFilters = false.obs;
  final searchRadius = 10.0.obs;
  final eventMarkers = <Marker>{}.obs;
  final visibleEvents = <EventModel>[].obs;
  final selectedEventCategories = <String>[].obs;

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
    _initializeLocation();
  }

  @override
  void onClose() {
    _mapController.dispose();
    super.onClose();
  }

  // Map related methods
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void onCameraMove(CameraPosition position) {
    currentPosition.value = position.target;
    _updateVisibleEvents();
  }

  void onMapTap(LatLng position) {
    if (showFilters.value) {
      showFilters.value = false;
    }
  }

  void zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }

  void centerOnUserLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      final latLng = LatLng(location.latitude!, location.longitude!);
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15),
      );
    }
  }

  void toggleMapType() {
    mapType.value =
        mapType.value == MapType.normal ? MapType.satellite : MapType.normal;
  }

  void toggleFilters() {
    showFilters.value = !showFilters.value;
  }

  void updateSearchRadius(double value) {
    searchRadius.value = value;
    _updateVisibleEvents();
  }

  void updateSelectedEventCategories(List<String> categories) {
    selectedEventCategories.value = categories;
    _updateVisibleEvents();
  }

  void refreshEvents() {
    loadEvents(refresh: true);
  }

  Future<void> _initializeLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      currentPosition.value = LatLng(
        location.latitude!,
        location.longitude!,
      );
    }
  }

  void _updateVisibleEvents() async {
    await filterAndCreateMarkers();
    visibleEvents.value = events.where((event) {
      if (event.location == null) return false;

      final distance = calculateDistance(
        currentPosition.value.latitude,
        currentPosition.value.longitude,
        event.location!.latitude,
        event.location!.longitude,
      );

      return distance <= searchRadius.value;
    }).toList();
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('event_categories').get();

      categories.value = snapshot.docs
          .map((doc) => EventCategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading categories: $e');
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
        if (showOnlineOnly.value && event.type != EventType.online) {
          return false;
        }
        if (showOfflineOnly.value && event.type != EventType.inPerson) {
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
    selectedDay.value = null;
    showOnlineOnly.value = false;
    showOfflineOnly.value = false;
    showUpcomingOnly.value = true;
    searchQuery.value = '';
    loadEvents(refresh: true);
  }

  Future<void> filterAndCreateMarkers() async {
    try {
      final events = await _eventService.getEvents();
      final filteredEvents = events.where((event) {
        // Kategori filtresi
        if (selectedEventCategories.isNotEmpty &&
            !selectedEventCategories.contains(event.categories.first)) {
          return false;
        }

        // Tarih filtresi
        if (selectedDay.value != null) {
          if (!isSameDay(event.startDate, selectedDay.value!)) {
            return false;
          }
        }

        // Konum filtresi
        if (event.location != null) {
          final distance = calculateDistance(
            currentPosition.value.latitude,
            currentPosition.value.longitude,
            event.location!.latitude,
            event.location!.longitude,
          );
          if (distance > searchRadius.value) {
            return false;
          }
        }

        return true;
      }).toList();

      // Marker'ları oluştur
      eventMarkers.clear();
      for (final event in filteredEvents) {
        if (event.location != null) {
          final marker = Marker(
            markerId: MarkerId(event.id),
            position:
                LatLng(event.location!.latitude, event.location!.longitude),
            infoWindow: InfoWindow(
              title: event.title,
              snippet: event.description,
            ),
            onTap: () => navigateToEventDetail(event.id),
          );
          eventMarkers.add(marker);
        }
      }
    } catch (e) {
      print('Error filtering events: $e');
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Dünya'nın yarıçapı (km)
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  void navigateToEventDetail(String eventId) {
    Get.toNamed('/event/$eventId');
  }
}

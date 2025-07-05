import 'package:get/get.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/services/event/event_service.dart';
import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventCreateController extends GetxController {
  final EventService _eventService = EventService();

  final title = ''.obs;
  final description = ''.obs;
  final type = Rx<EventType?>(null);
  final location = Rx<EventLocation?>(null);
  final venueAddress = Rx<String?>(null);
  final onlineMeetingUrl = Rx<String?>(null);
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);
  final participantLimit = 0.obs;
  final selectedCategories = <String>[].obs;
  final selectedLocation = Rx<GeoPoint?>(null);
  final isLoading = false.obs;
  final _categoryNames = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCategoryNames();
  }

  Future<void> _loadCategoryNames() async {
    try {
      final categories = await _eventService.getEventCategories();
      for (var category in categories) {
        _categoryNames[category.id] = category.name;
      }
    } catch (e) {
      print('Error loading category names: $e');
    }
  }

  String getCategoryName(String categoryId) {
    return _categoryNames[categoryId] ?? categoryId;
  }

  // Form validation
  bool get isFormValid =>
      title.value.isNotEmpty &&
      description.value.isNotEmpty &&
      type.value != null &&
      location.value != null &&
      startDate.value != null &&
      endDate.value != null &&
      participantLimit.value > 0 &&
      selectedCategories.isNotEmpty &&
      _isLocationValid;

  bool get _isLocationValid {
    if (location.value == EventLocation.online) {
      return onlineMeetingUrl.value?.isNotEmpty ?? false;
    } else if (location.value == EventLocation.offline) {
      return venueAddress.value?.isNotEmpty ?? false;
    }
    return false;
  }

  // Update location coordinates
  void updateLocationCoordinates(double latitude, double longitude) {
    selectedLocation.value = GeoPoint(latitude, longitude);
  }

  // Create event
  Future<void> createEvent() async {
    if (!isFormValid) {
      Get.snackbar('Hata', 'Lütfen tüm alanları doldurun');
      return;
    }

    try {
      isLoading.value = true;

      final event = EventModel(
        id: '', // Will be set by Firestore
        title: title.value,
        description: description.value,
        organizerId: Get.find<AuthController>().currentUser?.uid ?? '',
        type: type.value!,
        location: location.value!,
        geoPoint: location.value == EventLocation.offline
            ? selectedLocation.value
            : null,
        venueAddress: venueAddress.value,
        onlineMeetingUrl: onlineMeetingUrl.value,
        startDate: startDate.value!,
        endDate: endDate.value!,
        participantLimit: participantLimit.value,
        categoryIds: selectedCategories,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _eventService.createEvent(event);
      Get.snackbar('Başarılı', 'Etkinlik başarıyla oluşturuldu');
      _resetForm();
      Get.back(); // Return to previous screen
    } catch (e) {
      Get.snackbar('Hata', 'Etkinlik oluşturulurken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Update form fields
  void updateTitle(String value) => title.value = value;
  void updateDescription(String value) => description.value = value;
  void updateType(EventType value) => type.value = value;
  void updateLocation(EventLocation value) {
    location.value = value;
    // Reset location specific fields
    if (value == EventLocation.online) {
      venueAddress.value = null;
    } else {
      onlineMeetingUrl.value = null;
    }
  }

  void updateVenueAddress(String value) => venueAddress.value = value;
  void updateOnlineMeetingUrl(String value) => onlineMeetingUrl.value = value;
  void updateStartDate(DateTime value) => startDate.value = value;
  void updateEndDate(DateTime value) => endDate.value = value;
  void updateParticipantLimit(int value) => participantLimit.value = value;

  // Category management
  void toggleCategory(String categoryId) {
    if (selectedCategories.contains(categoryId)) {
      selectedCategories.remove(categoryId);
    } else {
      selectedCategories.add(categoryId);
    }
  }

  // Reset form
  void _resetForm() {
    title.value = '';
    description.value = '';
    type.value = null;
    location.value = null;
    venueAddress.value = null;
    onlineMeetingUrl.value = null;
    startDate.value = null;
    endDate.value = null;
    participantLimit.value = 0;
    selectedCategories.clear();
  }
}

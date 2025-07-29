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
      startDate.value != null &&
      endDate.value != null &&
      participantLimit.value > 0 &&
      selectedCategories.isNotEmpty &&
      _isLocationValid &&
      _isDateValid;

  bool get _isDateValid {
    if (startDate.value == null || endDate.value == null) return false;
    return startDate.value!.isBefore(endDate.value!) &&
        startDate.value!.isAfter(DateTime.now());
  }

  bool get _isLocationValid {
    if (type.value == EventType.online) {
      return onlineMeetingUrl.value?.isNotEmpty ?? false;
    } else if (type.value == EventType.inPerson) {
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
    // Kullanıcı doğrulama
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) {
      Get.snackbar(
        'Hata',
        'Etkinlik oluşturmak için giriş yapmalısınız',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Form validasyonu
    if (!isFormValid) {
      Get.snackbar(
        'Hata',
        'Lütfen tüm alanları doldurun',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Tarih validasyonu
    if (startDate.value!.isAfter(endDate.value!)) {
      Get.snackbar(
        'Hata',
        'Başlangıç tarihi bitiş tarihinden önce olmalıdır',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Geçmiş tarih kontrolü
    if (startDate.value!.isBefore(DateTime.now())) {
      Get.snackbar(
        'Hata',
        'Etkinlik tarihi gelecekte olmalıdır',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final event = EventModel(
        id: '', // Will be set by Firestore
        title: title.value.trim(),
        description: description.value.trim(),
        type: type.value!,
        venueAddress: type.value == EventType.inPerson
            ? venueAddress.value?.trim()
            : null,
        onlineMeetingUrl: type.value == EventType.online
            ? onlineMeetingUrl.value?.trim()
            : null,
        startDate: startDate.value!,
        endDate: endDate.value!,
        participantLimit: participantLimit.value,
        categories: selectedCategories.toList(),
        participants: [],
        createdBy: authController.currentUser!.uid,
        createdAt: DateTime.now(),
        location:
            type.value == EventType.inPerson ? selectedLocation.value : null,
      );

      await _eventService.createEvent(event);

      Get.snackbar(
        'Başarılı',
        'Etkinlik başarıyla oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
      );

      _resetForm();
      Get.back(); // Return to previous screen
    } on FirebaseException catch (e) {
      Get.snackbar(
        'Hata',
        'Firebase hatası: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Etkinlik oluşturulurken beklenmeyen bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update form fields
  void updateTitle(String value) => title.value = value;
  void updateDescription(String value) => description.value = value;
  void updateType(EventType value) {
    type.value = value;
    // Reset location specific fields
    if (value == EventType.online) {
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
    venueAddress.value = null;
    onlineMeetingUrl.value = null;
    startDate.value = null;
    endDate.value = null;
    participantLimit.value = 0;
    selectedCategories.clear();
  }
}

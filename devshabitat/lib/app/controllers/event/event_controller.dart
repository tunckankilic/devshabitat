import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/models/event/event_registration_model.dart';
import 'package:devshabitat/app/services/event/event_service.dart';
import 'package:devshabitat/app/services/event/event_registration_service.dart';
import 'package:devshabitat/app/services/event/event_notification_service.dart';
import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:logger/logger.dart';

class EventController extends GetxController {
  final EventService _eventService = EventService();
  final EventRegistrationService _registrationService =
      EventRegistrationService();
  final EventNotificationService _notificationService =
      EventNotificationService();
  final Logger _logger = Logger();

  // Enhanced reactive variables
  final events = <EventModel>[].obs;
  final isLoading = false.obs;
  final isLoadingRegistration = false.obs;
  final isLoadingNotifications = false.obs;
  final hasMore = true.obs;
  final notificationStatus = ''.obs;
  final registrationStatus = ''.obs;
  final errorMessage = ''.obs;

  // Event filtering and search
  final searchQuery = ''.obs;
  final filteredEvents = <EventModel>[].obs;
  final selectedCategory = ''.obs;
  final selectedLocation = ''.obs;

  // Notification management
  final scheduledReminders = <String, DateTime>{}.obs;
  final notificationChannelsInitialized = false.obs;

  DocumentSnapshot? lastDocument;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    loadEvents();
    _setupEventFiltering();
  }

  // Initialize enhanced notification system
  Future<void> _initializeNotifications() async {
    try {
      isLoadingNotifications.value = true;
      notificationStatus.value = 'Initializing notifications...';

      await _notificationService.initialize();
      notificationChannelsInitialized.value = true;
      notificationStatus.value = 'Notifications ready';

      _logger.i('Event notifications initialized successfully');
    } catch (e) {
      notificationStatus.value = 'Notification initialization failed';
      _logger.e('Notification initialization error: $e');
    } finally {
      isLoadingNotifications.value = false;
    }
  }

  // Setup real-time event filtering
  void _setupEventFiltering() {
    // React to search query changes
    ever(searchQuery, (_) => _filterEvents());
    ever(selectedCategory, (_) => _filterEvents());
    ever(selectedLocation, (_) => _filterEvents());
    ever(events, (_) => _filterEvents());
  }

  void _filterEvents() {
    var filtered = events.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((event) =>
              event.title
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              event.description
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    // Apply category filter
    if (selectedCategory.value.isNotEmpty) {
      filtered = filtered
          .where((event) => event.categoryIds.contains(selectedCategory.value))
          .toList();
    }

    // Apply location filter
    if (selectedLocation.value.isNotEmpty) {
      filtered = filtered
          .where((event) => event.location
              .toString()
              .toLowerCase()
              .contains(selectedLocation.value.toLowerCase()))
          .toList();
    }

    filteredEvents.value = filtered;
  }

  // Enhanced event loading with better error handling
  Future<void> loadEvents({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    try {
      if (refresh) {
        events.clear();
        lastDocument = null;
        hasMore.value = true;
        errorMessage.value = '';
      }

      if (!hasMore.value) return;

      isLoading.value = true;
      registrationStatus.value = 'Loading events...';

      final newEvents = await _eventService.getEvents(
        startAfter: lastDocument,
        isActive: true,
      );

      if (newEvents.isEmpty) {
        hasMore.value = false;
        registrationStatus.value = 'All events loaded';
      } else {
        events.addAll(newEvents);
        lastDocument = newEvents.last as DocumentSnapshot;
        registrationStatus.value = '${events.length} events loaded';

        // Auto-schedule reminders for newly loaded events
        await _autoScheduleReminders(newEvents);
      }

      _logger.i('Loaded ${newEvents.length} events');
    } catch (e) {
      errorMessage.value = 'Failed to load events: $e';
      registrationStatus.value = 'Event loading failed';
      _logger.e('Event loading error: $e');

      Get.snackbar(
        'Hata',
        'Etkinlikler yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Auto-schedule reminders for upcoming events
  Future<void> _autoScheduleReminders(List<EventModel> eventList) async {
    try {
      for (final event in eventList) {
        // Schedule reminder 1 day before event
        final reminderTime = event.startDate.subtract(const Duration(days: 1));

        if (reminderTime.isAfter(DateTime.now())) {
          await scheduleEventReminder(event, reminderTime);
        }

        // Schedule reminder 1 hour before event
        final hourReminderTime =
            event.startDate.subtract(const Duration(hours: 1));

        if (hourReminderTime.isAfter(DateTime.now())) {
          await scheduleEventReminder(event, hourReminderTime, isHourly: true);
        }
      }
    } catch (e) {
      _logger.e('Auto-schedule reminders error: $e');
    }
  }

  // Enhanced event registration with notifications
  Future<void> registerForEvent(EventModel event) async {
    try {
      isLoadingRegistration.value = true;
      registrationStatus.value = 'Registering for event...';

      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Register for event
      await _registrationService.registerForEvent(
        event.id,
        currentUser.uid,
      );

      // Send immediate confirmation notification
      await _notificationService.sendEventNotification(
        eventId: event.id,
        title: 'Kayıt Başarılı',
        body: '${event.title} etkinliğine başarıyla kaydoldunuz!',
        data: {
          'type': 'registration_success',
          'eventId': event.id,
          'eventTitle': event.title,
        },
      );

      // Schedule automatic reminders
      await _scheduleEventReminders(event);

      registrationStatus.value = 'Registration successful';
      _logger.i('Successfully registered for event: ${event.id}');

      Get.snackbar(
        'Başarılı',
        'Etkinlik kaydınız tamamlandı!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Registration failed: $e';
      registrationStatus.value = 'Registration failed';
      _logger.e('Event registration error: $e');

      Get.snackbar(
        'Hata',
        'Etkinlik kaydı yapılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRegistration.value = false;
    }
  }

  // Schedule comprehensive event reminders
  Future<void> _scheduleEventReminders(EventModel event) async {
    try {
      // 24-hour reminder
      final dayReminder = event.startDate.subtract(const Duration(days: 1));
      if (dayReminder.isAfter(DateTime.now())) {
        await scheduleEventReminder(event, dayReminder);
      }

      // 1-hour reminder
      final hourReminder = event.startDate.subtract(const Duration(hours: 1));
      if (hourReminder.isAfter(DateTime.now())) {
        await scheduleEventReminder(event, hourReminder, isHourly: true);
      }

      // 15-minute reminder for important events (conferences and hackathons)
      if (event.type == EventType.conference ||
          event.type == EventType.hackathon) {
        final minuteReminder =
            event.startDate.subtract(const Duration(minutes: 15));
        if (minuteReminder.isAfter(DateTime.now())) {
          await scheduleEventReminder(event, minuteReminder, isPriority: true);
        }
      }
    } catch (e) {
      _logger.e('Schedule reminders error: $e');
    }
  }

  // Enhanced reminder scheduling with different types
  Future<void> scheduleEventReminder(
    EventModel event,
    DateTime reminderTime, {
    bool isHourly = false,
    bool isPriority = false,
  }) async {
    try {
      String title;
      String body;

      if (isPriority) {
        title = 'Önemli Etkinlik Başlıyor!';
        body = '${event.title} 15 dakika içinde başlayacak!';
      } else if (isHourly) {
        title = 'Etkinlik Hatırlatması';
        body = '${event.title} 1 saat içinde başlayacak!';
      } else {
        title = 'Etkinlik Hatırlatması';
        body = '${event.title} yarın başlayacak!';
      }

      await _notificationService.scheduleEventReminder(
        eventId: event.id,
        title: title,
        body: body,
        scheduledTime: reminderTime,
        data: {
          'type': 'reminder',
          'eventId': event.id,
          'reminderType':
              isPriority ? 'priority' : (isHourly ? 'hourly' : 'daily'),
          'eventTitle': event.title,
          'startDate': event.startDate.toIso8601String(),
        },
      );

      scheduledReminders[event.id] = reminderTime;
      notificationStatus.value = 'Reminder scheduled for ${event.title}';
      _logger.i('Scheduled reminder for event ${event.id} at $reminderTime');
    } catch (e) {
      _logger.e('Schedule reminder error: $e');
    }
  }

  // Cancel event reminder
  Future<void> cancelEventReminder(String eventId) async {
    try {
      await _notificationService.cancelEventReminder(eventId);
      scheduledReminders.remove(eventId);
      notificationStatus.value = 'Reminder cancelled';
      _logger.i('Cancelled reminder for event: $eventId');
    } catch (e) {
      _logger.e('Cancel reminder error: $e');
    }
  }

  // Send event update notification
  Future<void> notifyEventUpdate(EventModel event, String updateMessage) async {
    try {
      await _notificationService.sendEventUpdate(
        eventId: event.id,
        title: 'Etkinlik Güncellendi',
        body: '${event.title}: $updateMessage',
        data: {
          'type': 'event_update',
          'eventId': event.id,
          'updateMessage': updateMessage,
        },
      );

      notificationStatus.value = 'Update notification sent';
      _logger.i('Sent update notification for event: ${event.id}');
    } catch (e) {
      _logger.e('Send update notification error: $e');
    }
  }

  // Search and filter methods
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setLocation(String location) {
    selectedLocation.value = location;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = '';
    selectedLocation.value = '';
  }

  // Get comprehensive status
  Map<String, dynamic> getEventStatus() {
    return {
      'total_events': events.length,
      'filtered_events': filteredEvents.length,
      'is_loading': isLoading.value,
      'has_more': hasMore.value,
      'notifications_initialized': notificationChannelsInitialized.value,
      'scheduled_reminders': scheduledReminders.length,
      'search_query': searchQuery.value,
      'selected_category': selectedCategory.value,
      'notification_status': notificationStatus.value,
      'registration_status': registrationStatus.value,
      'error_message': errorMessage.value,
    };
  }

  // Refresh everything
  Future<void> refreshEvents() async {
    await loadEvents(refresh: true);
  }

  @override
  void onClose() {
    // Cancel any pending operations
    super.onClose();
  }
}

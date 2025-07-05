import 'package:get/get.dart';
import '../../services/community/community_event_service.dart';

class CommunityEventController extends GetxController {
  final CommunityEventService eventService;

  CommunityEventController({required this.eventService});

  final events = <dynamic>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      events.value = await eventService.getEvents();
    } catch (e) {
      print('Error loading events: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

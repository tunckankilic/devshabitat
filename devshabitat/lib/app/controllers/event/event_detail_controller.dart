import 'package:get/get.dart';
import '../../models/event/event_model.dart';
import '../../services/event/event_detail_service.dart';

class EventDetailController extends GetxController {
  final EventDetailService eventService;
  final event = Rxn<EventModel>();
  final isLoading = false.obs;

  EventDetailController({required this.eventService});

  Future<void> loadEventDetails(String eventId) async {
    try {
      isLoading.value = true;
      event.value = await eventService.getEventDetails(eventId);
    } catch (e) {
      Get.snackbar('Hata', 'Etkinlik detayları yüklenirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }
}

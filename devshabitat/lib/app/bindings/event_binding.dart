import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/event/event_controller.dart';
import 'package:devshabitat/app/controllers/event/event_create_controller.dart';
import 'package:devshabitat/app/controllers/event/event_discovery_controller.dart';

class EventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventController>(() => EventController());
    Get.lazyPut<EventCreateController>(() => EventCreateController());
    Get.lazyPut<EventDiscoveryController>(() => EventDiscoveryController());
  }
}

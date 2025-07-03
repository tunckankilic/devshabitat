import 'package:get/get.dart';
import '../../controllers/event/event_discovery_controller.dart';
import '../../services/event/event_service.dart';
import '../../services/location/location_tracking_service.dart';

class NearbyEventsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EventService());
    Get.lazyPut(() => LocationTrackingService());
    Get.lazyPut(() => EventDiscoveryController());
  }
}

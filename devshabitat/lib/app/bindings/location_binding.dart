import 'package:get/get.dart';
import '../controllers/location/location_controller.dart';
import '../controllers/location/map_controller.dart';
import '../controllers/location/nearby_developers_controller.dart';
import '../services/location/geofence_service.dart';
import '../services/location/location_tracking_service.dart';
import '../services/location/maps_service.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    // Servisleri kaydet
    Get.lazyPut<MapsService>(() => MapsService());
    Get.lazyPut<LocationTrackingService>(() => LocationTrackingService());
    Get.lazyPut<GeofenceService>(() => GeofenceService());

    // Kontrolcüleri kaydet
    Get.lazyPut<LocationController>(() => LocationController());
    Get.lazyPut<MapController>(
      () => MapController(
        locationService: Get.find<LocationTrackingService>(),
      ),
    );
    Get.lazyPut<NearbyDevelopersController>(() => NearbyDevelopersController());
  }
}

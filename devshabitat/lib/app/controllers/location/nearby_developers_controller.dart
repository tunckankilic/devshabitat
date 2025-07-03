import 'package:get/get.dart';
import '../../models/location/location_model.dart';
import '../../models/enhanced_user_model.dart';
import '../../services/location/maps_service.dart';
import '../../services/user_service.dart' as user_service;

class NearbyDevelopersController extends GetxController {
  final MapsService _mapsService = Get.find<MapsService>();
  final user_service.UserService _userService =
      Get.find<user_service.UserService>();

  final nearbyDevelopers = <EnhancedUserModel>[].obs;
  final searchRadius = 5.0.obs; // km cinsinden
  final isLoading = false.obs;
  final currentLocation = Rxn<LocationModel>();

  @override
  void onInit() {
    super.onInit();
    ever(searchRadius, (_) => refreshNearbyDevelopers());
  }

  Future<void> refreshNearbyDevelopers() async {
    if (currentLocation.value == null) return;

    try {
      isLoading.value = true;

      // Yakındaki geliştiricileri getir
      final developers = await _userService.getAllDevelopers();
      final nearbyDevs = <EnhancedUserModel>[];

      for (final developer in developers) {
        if (developer.location == null) continue;

        final distance = _mapsService.calculateDistance(
          currentLocation.value!,
          developer.location!,
        );

        if (distance <= searchRadius.value) {
          nearbyDevs.add(developer);
        }
      }

      // Mesafeye göre sırala
      nearbyDevs.sort((a, b) {
        final distanceA = _mapsService.calculateDistance(
          currentLocation.value!,
          a.location!,
        );
        final distanceB = _mapsService.calculateDistance(
          currentLocation.value!,
          b.location!,
        );
        return distanceA.compareTo(distanceB);
      });

      nearbyDevelopers.value = nearbyDevs;
    } catch (e) {
      print('Yakındaki geliştiricileri getirme hatası: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchRadius(double radius) {
    searchRadius.value = radius;
  }

  void updateCurrentLocation(LocationModel location) {
    currentLocation.value = location;
    refreshNearbyDevelopers();
  }

  String getDistanceText(EnhancedUserModel developer) {
    if (currentLocation.value == null || developer.location == null) {
      return 'Mesafe bilinmiyor';
    }

    final distance = _mapsService.calculateDistance(
      currentLocation.value!,
      developer.location!,
    );

    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} metre';
    } else {
      return '${distance.toStringAsFixed(1)} km';
    }
  }

  List<EnhancedUserModel> filterDevelopersBySkills(List<String> skills) {
    return nearbyDevelopers.where((developer) {
      return developer.skills?.any((skill) => skills.contains(skill)) ?? false;
    }).toList();
  }

  List<EnhancedUserModel> filterDevelopersByExperience(int minYears) {
    return nearbyDevelopers.where((developer) {
      return developer.yearsOfExperience >= minYears;
    }).toList();
  }
}

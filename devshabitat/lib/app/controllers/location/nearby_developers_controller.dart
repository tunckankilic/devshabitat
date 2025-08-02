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

  // Gizlilik ayarları
  final isLocationSharingEnabled = true.obs;
  final isOnlineStatusVisible = true.obs;
  final isProfileVisible = true.obs;

  // Filtreleme ayarları
  final selectedSkills = <String>[].obs;
  final minExperienceYears = 0.obs;
  final showOnlineOnly = false.obs;
  final showOpenPositions = false.obs;
  final showMentors = false.obs;

  // Sıralama
  final sortBy = 'distance'.obs; // 'distance', 'experience', 'activity'

  // Arama
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(searchRadius, (_) => refreshNearbyDevelopers());
    ever(selectedSkills, (_) => applyFilters());
    ever(minExperienceYears, (_) => applyFilters());
    ever(showOnlineOnly, (_) => applyFilters());
    ever(showOpenPositions, (_) => applyFilters());
    ever(showMentors, (_) => applyFilters());
    ever(sortBy, (_) => applySorting());
    ever(searchQuery, (_) => applySearch());
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
          currentLocation.value!.toLocationData(),
          developer.location!.toLocationData(),
        );

        if (distance <= searchRadius.value) {
          nearbyDevs.add(developer);
        }
      }

      // Mesafeye göre sırala
      nearbyDevs.sort((a, b) {
        final distanceA = _mapsService.calculateDistance(
          currentLocation.value!.toLocationData(),
          a.location!.toLocationData(),
        );
        final distanceB = _mapsService.calculateDistance(
          currentLocation.value!.toLocationData(),
          b.location!.toLocationData(),
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
      currentLocation.value!.toLocationData(),
      developer.location!.toLocationData(),
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

  // Gizlilik ayarları
  void updateLocationSharing(bool enabled) {
    isLocationSharingEnabled.value = enabled;
    // Bu ayarı backend'e kaydet
  }

  void updateOnlineStatusVisibility(bool visible) {
    isOnlineStatusVisible.value = visible;
    // Bu ayarı backend'e kaydet
  }

  void updateProfileVisibility(bool visible) {
    isProfileVisible.value = visible;
    // Bu ayarı backend'e kaydet
  }

  // Filtreleme fonksiyonları
  void addSkillFilter(String skill) {
    if (!selectedSkills.contains(skill)) {
      selectedSkills.add(skill);
    }
  }

  void removeSkillFilter(String skill) {
    selectedSkills.remove(skill);
  }

  void updateMinExperienceYears(int years) {
    minExperienceYears.value = years;
  }

  void toggleOnlineOnly() {
    showOnlineOnly.value = !showOnlineOnly.value;
  }

  void toggleOpenPositions() {
    showOpenPositions.value = !showOpenPositions.value;
  }

  void toggleMentors() {
    showMentors.value = !showMentors.value;
  }

  // Sıralama fonksiyonları
  void updateSortBy(String sortType) {
    sortBy.value = sortType;
  }

  // Arama fonksiyonu
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Filtreleri uygula
  void applyFilters() {
    var filteredDevelopers = List<EnhancedUserModel>.from(nearbyDevelopers);

    // Yetenek filtresi
    if (selectedSkills.isNotEmpty) {
      filteredDevelopers = filteredDevelopers.where((developer) {
        return developer.skills
                ?.any((skill) => selectedSkills.contains(skill)) ??
            false;
      }).toList();
    }

    // Deneyim filtresi
    if (minExperienceYears.value > 0) {
      filteredDevelopers = filteredDevelopers.where((developer) {
        return developer.yearsOfExperience >= minExperienceYears.value;
      }).toList();
    }

    // Çevrimiçi filtresi
    if (showOnlineOnly.value) {
      filteredDevelopers = filteredDevelopers.where((developer) {
        // Çevrimiçi durumu kontrolü (son görülme zamanına göre)
        if (developer.lastSeen == null) return false;
        final timeDifference = DateTime.now().difference(developer.lastSeen!);
        return timeDifference.inMinutes < 15; // 15 dakika içinde aktif
      }).toList();
    }

    // Açık pozisyon filtresi
    if (showOpenPositions.value) {
      filteredDevelopers = filteredDevelopers.where((developer) {
        // Açık pozisyon kontrolü (preferences'da jobSeeking olabilir)
        return developer.preferences?['jobSeeking'] == true;
      }).toList();
    }

    // Mentor filtresi
    if (showMentors.value) {
      filteredDevelopers = filteredDevelopers.where((developer) {
        // Mentor kontrolü (preferences'da isMentor olabilir)
        return developer.preferences?['isMentor'] == true;
      }).toList();
    }

    nearbyDevelopers.value = filteredDevelopers;
  }

  // Sıralama uygula
  void applySorting() {
    final developers = List<EnhancedUserModel>.from(nearbyDevelopers);

    switch (sortBy.value) {
      case 'distance':
        developers.sort((a, b) {
          if (currentLocation.value == null) return 0;
          final distanceA = _mapsService.calculateDistance(
            currentLocation.value!.toLocationData(),
            a.location!.toLocationData(),
          );
          final distanceB = _mapsService.calculateDistance(
            currentLocation.value!.toLocationData(),
            b.location!.toLocationData(),
          );
          return distanceA.compareTo(distanceB);
        });
        break;
      case 'experience':
        developers
            .sort((a, b) => b.yearsOfExperience.compareTo(a.yearsOfExperience));
        break;
      case 'activity':
        developers.sort((a, b) {
          if (a.lastSeen == null && b.lastSeen == null) return 0;
          if (a.lastSeen == null) return 1;
          if (b.lastSeen == null) return -1;
          return b.lastSeen!.compareTo(a.lastSeen!);
        });
        break;
    }

    nearbyDevelopers.value = developers;
  }

  // Arama uygula
  void applySearch() {
    if (searchQuery.value.isEmpty) {
      refreshNearbyDevelopers();
      return;
    }

    final query = searchQuery.value.toLowerCase();
    final filteredDevelopers = nearbyDevelopers.where((developer) {
      final name = developer.displayName?.toLowerCase() ?? '';
      final title = developer.title?.toLowerCase() ?? '';
      final company = developer.company?.toLowerCase() ?? '';
      final bio = developer.bio?.toLowerCase() ?? '';

      return name.contains(query) ||
          title.contains(query) ||
          company.contains(query) ||
          bio.contains(query);
    }).toList();

    nearbyDevelopers.value = filteredDevelopers;
  }

  // Tüm filtreleri temizle
  void clearAllFilters() {
    selectedSkills.clear();
    minExperienceYears.value = 0;
    showOnlineOnly.value = false;
    showOpenPositions.value = false;
    showMentors.value = false;
    searchQuery.value = '';
    sortBy.value = 'distance';
    refreshNearbyDevelopers();
  }

  // Geliştirici ile bağlantı kur
  Future<void> connectWithDeveloper(EnhancedUserModel developer) async {
    try {
      // Bağlantı isteği gönder
      // await _userService.sendConnectionRequest(developer.uid);
      Get.snackbar(
        'Bağlantı İsteği',
        '${developer.displayName} ile bağlantı isteği gönderildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Bağlantı isteği gönderilemedi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Mesaj gönder
  Future<void> sendMessageToDeveloper(EnhancedUserModel developer) async {
    try {
      // Mesaj sayfasına yönlendir
      Get.toNamed('/chat', arguments: {
        'recipient': developer,
        'isNearby': true,
      });
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Mesaj gönderilemedi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Geliştirici profilini görüntüle
  void viewDeveloperProfile(EnhancedUserModel developer) {
    Get.toNamed('/developer-profile', arguments: developer);
  }
}

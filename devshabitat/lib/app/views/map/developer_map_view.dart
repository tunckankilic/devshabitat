import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/widgets/map/custom_map_widget.dart';
import 'package:devshabitat/app/widgets/map/location_filter_widget.dart';
import 'package:devshabitat/app/widgets/map/map_controls_widget.dart';
import 'package:devshabitat/app/controllers/location/map_controller.dart';
import 'package:devshabitat/app/controllers/location/nearby_developers_controller.dart';
import 'package:devshabitat/app/controllers/responsive_controller.dart';
import 'package:devshabitat/app/models/enhanced_user_model.dart';

class DeveloperMapView extends GetView<MapController> {
  const DeveloperMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveController.to;
    final nearbyController = Get.find<NearbyDevelopersController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yakındaki Geliştiriciler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showAdvancedFilters(context, nearbyController),
            tooltip: 'Gelişmiş Filtreler',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showPrivacySettings(context, nearbyController),
            tooltip: 'Gizlilik Ayarları',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ana harita
          Obx(() {
            return CustomMapWidget(
              markers: controller.developerMarkers,
              initialPosition: controller.currentPosition.value,
              onMapCreated: controller.onMapCreated,
              onCameraMove: controller.onCameraMove,
              onTap: controller.onMapTap,
            );
          }),

          // Harita kontrolleri
          Obx(() {
            return MapControlsWidget(
              onZoomIn: controller.zoomIn,
              onZoomOut: controller.zoomOut,
              onLocateMe: () {
                controller.centerOnUserLocation();
                nearbyController.refreshNearbyDevelopers();
              },
              onToggleMapType: controller.toggleMapType,
              onToggleFilters: controller.toggleFilters,
              currentMapType: controller.mapType.value,
            );
          }),

          // Filtre paneli
          Obx(() {
            if (!controller.showFilters.value) return const SizedBox.shrink();
            return Positioned(
              left: responsive.responsivePadding(left: 16).left,
              right: responsive.responsivePadding(right: 16).right,
              top: responsive.responsivePadding(top: 16).top,
              child: SafeArea(
                minimum: responsive.responsivePadding(all: 16),
                child: LocationFilterWidget(
                  radius: nearbyController.searchRadius.value,
                  onRadiusChanged: nearbyController.updateSearchRadius,
                  selectedCategories: controller.selectedCategories,
                  onCategoriesChanged: controller.updateSelectedCategories,
                  showOnlineOnly: controller.showOnlineOnly.value,
                  onOnlineStatusChanged: controller.toggleOnlineOnly,
                ),
              ),
            );
          }),

          // Yakındaki geliştiriciler listesi
          Positioned(
            left: responsive.responsivePadding(left: 16).left,
            right: responsive.responsivePadding(right: 16).right,
            bottom: responsive.responsivePadding(bottom: 16).bottom,
            child: _buildNearbyDevelopersList(nearbyController, responsive),
          ),

          // Yükleme göstergesi
          Obx(() {
            if (!nearbyController.isLoading.value) {
              return const SizedBox.shrink();
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDeveloperDetails(context, nearbyController),
        icon: const Icon(Icons.person_search),
        label: const Text('Geliştirici Ara'),
      ),
    );
  }

  Widget _buildNearbyDevelopersList(NearbyDevelopersController nearbyController,
      ResponsiveController responsive) {
    return Obx(() {
      if (nearbyController.nearbyDevelopers.isEmpty) {
        return Card(
          child: Padding(
            padding: responsive.responsivePadding(all: 16),
            child: const Center(
              child: Text(
                'Yakınınızda geliştirici bulunamadı',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        );
      }

      return SizedBox(
        height: 200,
        child: Card(
          child: Column(
            children: [
              Padding(
                padding: responsive.responsivePadding(all: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Yakındaki Geliştiriciler (${nearbyController.nearbyDevelopers.length})',
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: nearbyController.refreshNearbyDevelopers,
                      tooltip: 'Yenile',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: responsive.responsivePadding(horizontal: 8),
                  itemCount: nearbyController.nearbyDevelopers.length,
                  itemBuilder: (context, index) {
                    final developer = nearbyController.nearbyDevelopers[index];
                    return _buildDeveloperCard(
                        developer, nearbyController, responsive);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDeveloperCard(
      EnhancedUserModel developer,
      NearbyDevelopersController nearbyController,
      ResponsiveController responsive) {
    return Container(
      width: 280,
      margin: responsive.responsivePadding(horizontal: 8),
      child: Card(
        child: InkWell(
          onTap: () => _showDeveloperProfile(Get.context!, developer),
          child: Padding(
            padding: responsive.responsivePadding(all: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: developer.photoURL != null
                          ? NetworkImage(developer.photoURL!)
                          : null,
                      child: developer.photoURL == null
                          ? Text(developer.displayName
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                              '?')
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            developer.displayName ?? 'İsimsiz',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            developer.title ?? 'Geliştirici',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        nearbyController.getDistanceText(developer),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (developer.skills != null &&
                    developer.skills!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: developer.skills!.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _sendMessage(Get.context!, developer),
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Mesaj'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _connectWithDeveloper(Get.context!, developer),
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('Bağlan'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAdvancedFilters(
      BuildContext context, NearbyDevelopersController nearbyController) {
    final skillsController = TextEditingController();
    final minExperienceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gelişmiş Filtreler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: skillsController,
              decoration: const InputDecoration(
                labelText: 'Yetenekler (virgülle ayırın)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minExperienceController,
              decoration: const InputDecoration(
                labelText: 'Minimum Deneyim (yıl)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Filtreleri uygula
              final skills = skillsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              final minExperience =
                  int.tryParse(minExperienceController.text) ?? 0;

              // Controller'a filtreleri uygula
              nearbyController.selectedSkills.clear();
              nearbyController.selectedSkills.addAll(skills);
              nearbyController.updateMinExperienceYears(minExperience);

              Get.back();
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(
      BuildContext context, NearbyDevelopersController nearbyController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gizlilik Ayarları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => SwitchListTile(
                  title: const Text('Konum Paylaşımı'),
                  subtitle: const Text('Diğer geliştiriciler sizi görebilsin'),
                  value: nearbyController.isLocationSharingEnabled.value,
                  onChanged: nearbyController.updateLocationSharing,
                )),
            Obx(() => SwitchListTile(
                  title: const Text('Çevrimiçi Durumu'),
                  subtitle: const Text('Çevrimiçi olduğunuzu göster'),
                  value: nearbyController.isOnlineStatusVisible.value,
                  onChanged: nearbyController.updateOnlineStatusVisibility,
                )),
            Obx(() => SwitchListTile(
                  title: const Text('Profil Görünürlüğü'),
                  subtitle: const Text(
                      'Profilinizi yakındaki geliştiricilere göster'),
                  value: nearbyController.isProfileVisible.value,
                  onChanged: nearbyController.updateProfileVisibility,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperDetails(
      BuildContext context, NearbyDevelopersController nearbyController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Geliştirici Arama',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildSearchSection(nearbyController),
                    const SizedBox(height: 16),
                    _buildFilterSection(nearbyController),
                    const SizedBox(height: 16),
                    _buildSortSection(nearbyController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(NearbyDevelopersController nearbyController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Arama Kriterleri',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'İsim veya şirket ara',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: nearbyController.updateSearchQuery,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(NearbyDevelopersController nearbyController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtreler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Obx(() => FilterChip(
                      label: const Text('Çevrimiçi'),
                      selected: nearbyController.showOnlineOnly.value,
                      onSelected: (value) {
                        nearbyController.toggleOnlineOnly();
                      },
                    )),
                Obx(() => FilterChip(
                      label: const Text('Açık Pozisyon'),
                      selected: nearbyController.showOpenPositions.value,
                      onSelected: (value) {
                        nearbyController.toggleOpenPositions();
                      },
                    )),
                Obx(() => FilterChip(
                      label: const Text('Mentor'),
                      selected: nearbyController.showMentors.value,
                      onSelected: (value) {
                        nearbyController.toggleMentors();
                      },
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Seçili Yetenekler:'),
                TextButton(
                  onPressed: () => nearbyController.selectedSkills.clear(),
                  child: const Text('Temizle'),
                ),
              ],
            ),
            if (nearbyController.selectedSkills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: nearbyController.selectedSkills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    onDeleted: () => nearbyController.removeSkillFilter(skill),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortSection(NearbyDevelopersController nearbyController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sıralama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('En Yakın'),
                      value: 'distance',
                      groupValue: nearbyController.sortBy.value,
                      onChanged: (value) {
                        nearbyController.updateSortBy(value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('En Deneyimli'),
                      value: 'experience',
                      groupValue: nearbyController.sortBy.value,
                      onChanged: (value) {
                        nearbyController.updateSortBy(value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('En Aktif'),
                      value: 'activity',
                      groupValue: nearbyController.sortBy.value,
                      onChanged: (value) {
                        nearbyController.updateSortBy(value!);
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  void _showDeveloperProfile(
      BuildContext context, EnhancedUserModel developer) {
    final nearbyController = Get.find<NearbyDevelopersController>();
    nearbyController.viewDeveloperProfile(developer);
  }

  void _sendMessage(BuildContext context, EnhancedUserModel developer) {
    final nearbyController = Get.find<NearbyDevelopersController>();
    nearbyController.sendMessageToDeveloper(developer);
  }

  void _connectWithDeveloper(
      BuildContext context, EnhancedUserModel developer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${developer.displayName} ile Bağlan'),
        content: Text(
            '${developer.displayName} ile bağlantı kurmak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              final nearbyController = Get.find<NearbyDevelopersController>();
              nearbyController.connectWithDeveloper(developer);
            },
            child: const Text('Bağlan'),
          ),
        ],
      ),
    );
  }
}

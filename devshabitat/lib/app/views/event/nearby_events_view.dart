import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event/event_discovery_controller.dart';
import '../../models/event/event_model.dart';
import '../../widgets/event/event_card.dart';

class NearbyEventsView extends GetView<EventDiscoveryController> {
  const NearbyEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yakındaki Etkinlikler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshEvents(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => controller.toggleFilters(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtreler
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: controller.showFilters.value ? 120 : 0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Online/Offline filtresi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FilterChip(
                            label: const Text('Online'),
                            selected: controller.showOnlineOnly.value,
                            onSelected: controller.toggleOnlineOnly,
                          ),
                          FilterChip(
                            label: const Text('Yüz Yüze'),
                            selected: controller.showOfflineOnly.value,
                            onSelected: controller.toggleOfflineOnly,
                          ),
                        ],
                      ),
                      // Arama yarıçapı ayarı
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Text('Arama Yarıçapı: '),
                            Expanded(
                              child: Slider(
                                value: controller.searchRadius.value,
                                min: 1.0,
                                max: 50.0,
                                divisions: 49,
                                label:
                                    '${controller.searchRadius.value.round()} km',
                                onChanged: controller.updateSearchRadius,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          // Etkinlik Listesi
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.events.isEmpty) {
                return const Center(
                  child: Text('Yakında etkinlik bulunamadı'),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadEvents(refresh: true),
                child: ListView.builder(
                  itemCount: controller.events.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.events.length) {
                      if (controller.hasMore.value) {
                        controller.loadEvents();
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return const SizedBox();
                    }

                    final event = controller.events[index];
                    return EventCard(event: event);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.centerOnUserLocation(),
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

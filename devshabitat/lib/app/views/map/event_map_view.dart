import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/widgets/map/custom_map_widget.dart';
import 'package:devshabitat/app/widgets/map/location_filter_widget.dart';
import 'package:devshabitat/app/widgets/map/map_controls_widget.dart';
import 'package:devshabitat/app/controllers/event/event_discovery_controller.dart';

class EventMapView extends GetView<EventDiscoveryController> {
  const EventMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            return CustomMapWidget(
              markers: controller.eventMarkers,
              initialPosition: controller.currentPosition.value,
              onMapCreated: controller.onMapCreated,
              onCameraMove: controller.onCameraMove,
              onTap: controller.onMapTap,
            );
          }),
          Obx(() {
            return MapControlsWidget(
              onZoomIn: controller.zoomIn,
              onZoomOut: controller.zoomOut,
              onLocateMe: controller.centerOnUserLocation,
              onToggleMapType: controller.toggleMapType,
              onToggleFilters: controller.toggleFilters,
              currentMapType: controller.mapType.value,
            );
          }),
          Obx(() {
            if (!controller.showFilters.value) return const SizedBox.shrink();
            return Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: SafeArea(
                child: LocationFilterWidget(
                  radius: controller.searchRadius.value,
                  onRadiusChanged: controller.updateSearchRadius,
                  selectedCategories: controller.selectedEventCategories,
                  onCategoriesChanged: controller.updateSelectedEventCategories,
                  showOnlineOnly: controller.showOnlineOnly.value,
                  onOnlineStatusChanged: controller.toggleOnlineOnly,
                ),
              ),
            );
          }),
          Positioned(
            left: 16,
            right: 80,
            bottom: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        return Text(
                          '${controller.visibleEvents.length} etkinlik bulundu',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: controller.refreshEvents,
                      tooltip: 'Yenile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

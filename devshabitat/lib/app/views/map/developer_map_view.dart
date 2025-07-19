import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/widgets/map/custom_map_widget.dart';
import 'package:devshabitat/app/widgets/map/location_filter_widget.dart';
import 'package:devshabitat/app/widgets/map/map_controls_widget.dart';
import 'package:devshabitat/app/controllers/location/map_controller.dart';
import 'package:devshabitat/app/controllers/responsive_controller.dart';

class DeveloperMapView extends GetView<MapController> {
  const DeveloperMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveController.to;
    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            return CustomMapWidget(
              markers: controller.developerMarkers,
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
              left: responsive.responsivePadding(left: 16).left,
              right: responsive.responsivePadding(right: 16).right,
              top: responsive.responsivePadding(top: 16).top,
              child: SafeArea(
                minimum: responsive.responsivePadding(all: 16),
                child: LocationFilterWidget(
                  radius: controller.searchRadius.value,
                  onRadiusChanged: controller.updateSearchRadius,
                  selectedCategories: controller.selectedCategories,
                  onCategoriesChanged: controller.updateSelectedCategories,
                  showOnlineOnly: controller.showOnlineOnly.value,
                  onOnlineStatusChanged: controller.toggleOnlineOnly,
                ),
              ),
            );
          }),
          Positioned(
            left: responsive.responsivePadding(left: 16).left,
            right: responsive.responsivePadding(right: 80).right,
            bottom: responsive.responsivePadding(bottom: 16).bottom,
            child: Card(
              child: Padding(
                padding: responsive.responsivePadding(all: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        return Text(
                          '${controller.visibleDevelopers.length} geliştirici bulundu',
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: responsive.responsiveValue(
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                        ),
                      ),
                      onPressed: controller.refreshDevelopers,
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

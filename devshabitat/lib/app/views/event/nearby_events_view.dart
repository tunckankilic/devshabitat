import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event/event_discovery_controller.dart';
import '../../widgets/event/event_card.dart';
import '../base/base_view.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveText, ResponsiveSafeArea;
import '../../widgets/responsive/animated_responsive_layout.dart';

class NearbyEventsView extends BaseView<EventDiscoveryController> {
  const NearbyEventsView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Yakındaki Etkinlikler',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
        actions: [
          AdaptiveTouchTarget(
            onTap: () => controller.refreshEvents(),
            child: Icon(
              Icons.refresh,
              size: responsive.minTouchTarget,
            ),
          ),
          AdaptiveTouchTarget(
            onTap: () => controller.toggleFilters(),
            child: Icon(
              Icons.filter_list,
              size: responsive.minTouchTarget,
            ),
          ),
        ],
      ),
      body: ResponsiveSafeArea(
        child: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: ResponsiveOverflowHandler(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: responsive.responsiveValue(
                          mobile: 2,
                          tablet: 3,
                        ),
                      ),
                    );
                  }

                  if (controller.events.isEmpty) {
                    return Center(
                      child: ResponsiveText(
                        'Yakında etkinlik bulunamadı',
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 16,
                            tablet: 18,
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.loadEvents(refresh: true),
                    child: AnimatedResponsiveLayout(
                      mobile: _buildMobileEventList(),
                      tablet: _buildTabletEventGrid(),
                      animationDuration: const Duration(milliseconds: 300),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.centerOnUserLocation(),
        child: Icon(
          Icons.my_location,
          size: responsive.responsiveValue(
            mobile: 24,
            tablet: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: controller.showFilters.value
              ? responsive.responsiveValue(
                  mobile: 120,
                  tablet: 140,
                )
              : 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilterChip(
                      label: ResponsiveText(
                        'Online',
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 14,
                            tablet: 16,
                          ),
                        ),
                      ),
                      selected: controller.showOnlineOnly.value,
                      onSelected: controller.toggleOnlineOnly,
                    ),
                    FilterChip(
                      label: ResponsiveText(
                        'Yüz Yüze',
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 14,
                            tablet: 16,
                          ),
                        ),
                      ),
                      selected: controller.showOfflineOnly.value,
                      onSelected: controller.toggleOfflineOnly,
                    ),
                  ],
                ),
                Padding(
                  padding: responsive.responsivePadding(horizontal: 16),
                  child: Row(
                    children: [
                      ResponsiveText(
                        'Arama Yarıçapı: ',
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 14,
                            tablet: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: controller.searchRadius.value,
                          min: 1.0,
                          max: 50.0,
                          divisions: 49,
                          label: '${controller.searchRadius.value.round()} km',
                          onChanged: controller.updateSearchRadius,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildMobileEventList() {
    return ListView.builder(
      padding: responsive.responsivePadding(all: 16),
      itemCount: controller.events.length + 1,
      itemBuilder: (context, index) {
        if (index == controller.events.length) {
          if (controller.hasMore.value) {
            controller.loadEvents();
            return Center(
              child: Padding(
                padding: responsive.responsivePadding(all: 8),
                child: CircularProgressIndicator(
                  strokeWidth: responsive.responsiveValue(
                    mobile: 2,
                    tablet: 3,
                  ),
                ),
              ),
            );
          }
          return const SizedBox();
        }

        final event = controller.events[index];
        return EventCard(event: event);
      },
    );
  }

  Widget _buildTabletEventGrid() {
    return GridView.builder(
      padding: responsive.responsivePadding(all: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: responsive.responsiveValue(
          mobile: 1.5,
          tablet: 1.5,
        ),
        crossAxisSpacing: responsive.responsiveValue(
          mobile: 24,
          tablet: 24,
        ),
        mainAxisSpacing: responsive.responsiveValue(
          mobile: 24,
          tablet: 24,
        ),
      ),
      itemCount: controller.events.length + 1,
      itemBuilder: (context, index) {
        if (index == controller.events.length) {
          if (controller.hasMore.value) {
            controller.loadEvents();
            return Center(
              child: Padding(
                padding: responsive.responsivePadding(all: 8),
                child: CircularProgressIndicator(
                  strokeWidth: responsive.responsiveValue(
                    mobile: 2,
                    tablet: 3,
                  ),
                ),
              ),
            );
          }
          return const SizedBox();
        }

        final event = controller.events[index];
        return EventCard(event: event);
      },
    );
  }
}

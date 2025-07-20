import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/event/event_discovery_controller.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/controllers/responsive_controller.dart';
import 'package:devshabitat/app/widgets/event/event_card.dart';

class EventDiscoveryView extends GetView<EventDiscoveryController> {
  const EventDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveController.to;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Etkinlik Keşfet',
          style: TextStyle(fontSize: 20 * responsive.textScaleFactor),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60 * responsive.textScaleFactor),
          child: Padding(
            padding: responsive.responsivePadding(all: 8),
            child: TextField(
              style: TextStyle(fontSize: 16 * responsive.textScaleFactor),
              decoration: InputDecoration(
                hintText: 'Etkinlik ara...',
                hintStyle: TextStyle(fontSize: 16 * responsive.textScaleFactor),
                prefixIcon: Icon(
                  Icons.search,
                  size: 24 * responsive.iconScaleFactor,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8 * responsive.textScaleFactor),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: responsive.responsivePadding(all: 16),
              ),
              onChanged: controller.updateSearchQuery,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => controller.loadEvents(refresh: true),
                      child: GridView.builder(
                        padding: responsive.responsivePadding(all: 8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: responsive.gridColumns,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: responsive.gridSpacing,
                          mainAxisSpacing: responsive.gridSpacing,
                        ),
                        itemCount: controller.events.length + 1,
                        itemBuilder: (context, index) {
                          if (index == controller.events.length) {
                            if (controller.hasMore.value) {
                              controller.loadEvents();
                              return Center(
                                child: Padding(
                                  padding: responsive.responsivePadding(all: 8),
                                  child: const CircularProgressIndicator(),
                                ),
                              );
                            }
                            return const SizedBox();
                          }

                          final event = controller.events[index];
                          return EventCard(event: event);
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final responsive = ResponsiveController.to;

    return Container(
      padding: responsive.responsivePadding(all: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Online',
                  selected: controller.showOnlineOnly.value,
                  onSelected: controller.toggleOnlineOnly,
                ),
                SizedBox(width: 8 * responsive.textScaleFactor),
                _buildFilterChip(
                  label: 'Yüz yüze',
                  selected: controller.showOfflineOnly.value,
                  onSelected: controller.toggleOfflineOnly,
                ),
                SizedBox(width: 8 * responsive.textScaleFactor),
                _buildFilterChip(
                  label: 'Yaklaşan',
                  selected: controller.showUpcomingOnly.value,
                  onSelected: controller.toggleUpcomingOnly,
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * responsive.textScaleFactor),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: EventType.values.map((type) {
                return Padding(
                  padding: responsive.responsivePadding(right: 8),
                  child: _buildFilterChip(
                    label: _getEventTypeText(type),
                    selected: controller.selectedType.value == type,
                    onSelected: (selected) {
                      controller.updateEventType(selected ? type : null);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    final responsive = ResponsiveController.to;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(fontSize: 14 * responsive.textScaleFactor),
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Get.theme.primaryColor.withOpacity(0.2),
      padding: responsive.responsivePadding(horizontal: 8, vertical: 4),
    );
  }

  String _getEventTypeText(EventType type) {
    switch (type) {
      case EventType.meetup:
        return 'Meetup';
      case EventType.workshop:
        return 'Workshop';
      case EventType.hackathon:
        return 'Hackathon';
      case EventType.conference:
        return 'Konferans';
      case EventType.other:
        return 'Diğer';
    }
  }
}

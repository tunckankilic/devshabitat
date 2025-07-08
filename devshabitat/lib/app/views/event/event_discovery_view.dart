import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/event/event_discovery_controller.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/routes/app_pages.dart';

class EventDiscoveryView extends GetView<EventDiscoveryController> {
  const EventDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlik Keşfet'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Etkinlik ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
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
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(8),
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
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Yüz yüze',
                  selected: controller.showOfflineOnly.value,
                  onSelected: controller.toggleOfflineOnly,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Yaklaşan',
                  selected: controller.showUpcomingOnly.value,
                  onSelected: controller.toggleUpcomingOnly,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: EventType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
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
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Get.theme.primaryColor.withOpacity(0.2),
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
      default:
        return 'Diğer';
    }
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.eventDetails,
          arguments: event,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    event.location == EventLocation.online
                        ? Icons.computer
                        : Icons.location_on,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.location == EventLocation.online
                        ? 'Online'
                        : event.venueAddress ?? 'Konum belirtilmemiş',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  Icon(
                    _getEventTypeIcon(event.type),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getEventTypeText(event.type),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(event.startDate),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${event.currentParticipants}/${event.participantLimit}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.meetup:
        return Icons.groups;
      case EventType.workshop:
        return Icons.build;
      case EventType.hackathon:
        return Icons.code;
      case EventType.conference:
        return Icons.business;
      case EventType.other:
        return Icons.event;
    }
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

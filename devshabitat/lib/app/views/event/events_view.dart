// ignore_for_file: must_be_immutable

import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/event/event_controller.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/routes/app_pages.dart';
import 'package:devshabitat/app/utils/performance_optimizer.dart';

class EventsView extends GetView<EventController> with PerformanceOptimizer {
  EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return optimizeWidgetTree(
      Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.events),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => Get.toNamed(AppRoutes.eventDiscovery),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.toNamed(AppRoutes.eventCreate),
            ),
          ],
        ),
        body: Obx(
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
                      return _buildEventCard(event);
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return wrapWithRepaintBoundary(
      EventCard(event: event),
    );
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
                    event.type == EventType.online
                        ? Icons.computer
                        : Icons.location_on,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.type == EventType.online
                        ? AppStrings.online
                        : event.venueAddress ?? AppStrings.noLocation,
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
                    '${event.participants.length}/${event.participantLimit}',
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
      case EventType.inPerson:
        return Icons.location_on;
      case EventType.online:
        return Icons.computer;
    }
  }

  String _getEventTypeText(EventType type) {
    switch (type) {
      case EventType.inPerson:
        return AppStrings.inPerson;
      case EventType.online:
        return AppStrings.online;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

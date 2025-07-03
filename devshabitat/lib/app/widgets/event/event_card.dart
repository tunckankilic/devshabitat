import 'package:flutter/material.dart';
import '../../models/event/event_model.dart';
import '../../routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.EVENT_DETAIL,
          arguments: event,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Icon(
                    event.location == EventLocation.online
                        ? Icons.computer
                        : Icons.location_on,
                    size: 16.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    event.location == EventLocation.online
                        ? 'Online'
                        : event.venueAddress ?? 'Konum belirtilmemiş',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR')
                        .format(event.startDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Katılımcı: ${event.currentParticipants}/${event.participantLimit}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Chip(
                    label: Text(
                      event.type.toString().split('.').last,
                      style: const TextStyle(fontSize: 12.0),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

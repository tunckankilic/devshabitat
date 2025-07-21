import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/event/event_model.dart';
import '../../routes/app_pages.dart';
import '../../controllers/responsive_controller.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveController.to;

    return Card(
      elevation: responsive.responsiveValue(
        mobile: 2.0,
        tablet: 3.0,
        desktop: 4.0,
      ),
      margin: responsive.responsivePadding(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.EVENT_DETAIL,
          arguments: event,
        ),
        child: Padding(
          padding: responsive.responsivePadding(all: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18 * responsive.textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 8 * responsive.textScaleFactor),
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14 * responsive.textScaleFactor,
                    ),
              ),
              SizedBox(height: 16 * responsive.textScaleFactor),
              Row(
                children: [
                  Icon(
                    event.location == EventLocation.online
                        ? Icons.computer
                        : Icons.location_on,
                    size: 16 * responsive.iconScaleFactor,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4 * responsive.textScaleFactor),
                  Text(
                    event.location == EventLocation.online
                        ? 'Online'
                        : event.venueAddress ?? 'Konum belirtilmemiş',
                    style: TextStyle(
                      fontSize: 14 * responsive.textScaleFactor,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _getEventTypeIcon(event.type),
                    size: 16 * responsive.iconScaleFactor,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4 * responsive.textScaleFactor),
                  Text(
                    _getEventTypeText(event.type),
                    style: TextStyle(
                      fontSize: 14 * responsive.textScaleFactor,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * responsive.textScaleFactor),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16 * responsive.iconScaleFactor,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4 * responsive.textScaleFactor),
                  Text(
                    DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR')
                        .format(event.startDate),
                    style: TextStyle(
                      fontSize: 14 * responsive.textScaleFactor,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.person,
                    size: 16 * responsive.iconScaleFactor,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4 * responsive.textScaleFactor),
                  Text(
                    '${event.currentParticipants}/${event.participantLimit}',
                    style: TextStyle(
                      fontSize: 14 * responsive.textScaleFactor,
                      color: Colors.grey,
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
}

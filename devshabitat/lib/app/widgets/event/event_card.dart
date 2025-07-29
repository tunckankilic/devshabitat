import 'package:devshabitat/app/constants/app_strings.dart';
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
                    event.type == EventType.online
                        ? Icons.computer
                        : Icons.location_on,
                    size: 16 * responsive.iconScaleFactor,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4 * responsive.textScaleFactor),
                  Text(
                    event.type == EventType.online
                        ? AppStrings.online
                        : event.venueAddress ?? AppStrings.locationNotSet,
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
                    '${event.participants.length}/${event.participantLimit}',
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
      case EventType.inPerson:
        return Icons.groups;
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
}

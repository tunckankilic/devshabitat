import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/routes/app_routes.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool showDetailedInfo;

  const EventCard({
    Key? key,
    required this.event,
    this.showDetailedInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.eventDetails,
          arguments: event,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.coverImageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  event.coverImageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildEventTypeChip(event.type),
                      const Spacer(),
                      _buildStatusChip(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showDetailedInfo) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: event.location == EventLocation.online
                        ? Icons.computer
                        : Icons.location_on,
                    text: event.location == EventLocation.online
                        ? 'Online'
                        : event.venueAddress ?? 'Konum belirtilmemiş',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    text: _formatDate(event.startDate),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.person,
                    text:
                        '${event.currentParticipants}/${event.participantLimit} katılımcı',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeChip(EventType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getEventTypeColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getEventTypeIcon(type),
            size: 16,
            color: _getEventTypeColor(type),
          ),
          const SizedBox(width: 4),
          Text(
            _getEventTypeText(type),
            style: TextStyle(
              color: _getEventTypeColor(type),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final now = DateTime.now();
    final isUpcoming = event.startDate.isAfter(now);
    final isOngoing =
        event.startDate.isBefore(now) && event.endDate.isAfter(now);

    Color color;
    String text;

    if (isOngoing) {
      color = Colors.green;
      text = 'Devam ediyor';
    } else if (isUpcoming) {
      color = Colors.blue;
      text = 'Yaklaşıyor';
    } else {
      color = Colors.grey;
      text = 'Tamamlandı';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.meetup:
        return Colors.purple;
      case EventType.workshop:
        return Colors.orange;
      case EventType.hackathon:
        return Colors.blue;
      case EventType.conference:
        return Colors.green;
    }
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
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

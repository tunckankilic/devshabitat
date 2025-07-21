import 'package:flutter/material.dart';

class EventMarkerWidget extends StatelessWidget {
  final String eventId;
  final String title;
  final DateTime dateTime;
  final int attendeeCount;
  final String eventType;
  final VoidCallback? onTap;

  const EventMarkerWidget({
    super.key,
    required this.eventId,
    required this.title,
    required this.dateTime,
    required this.attendeeCount,
    required this.eventType,
    this.onTap,
  });

  Color _getEventTypeColor() {
    switch (eventType.toLowerCase()) {
      case 'workshop':
        return Colors.blue;
      case 'meetup':
        return Colors.green;
      case 'conference':
        return Colors.purple;
      case 'hackathon':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getEventTypeColor(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  attendeeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:devshabitat/app/models/event/event_model.dart';

class EventCalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<EventModel> events;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const EventCalendarWidget({
    Key? key,
    required this.focusedDay,
    this.selectedDay,
    required this.events,
    required this.onDaySelected,
    required this.onPageChanged,
  }) : super(key: key);

  List<EventModel> _getEventsForDay(DateTime day) {
    return events.where((event) {
      return isSameDay(event.startDate, day) ||
          (event.startDate.isBefore(day) && event.endDate.isAfter(day));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TableCalendar<EventModel>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            calendarFormat: CalendarFormat.month,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            locale: 'tr_TR',
            onDaySelected: onDaySelected,
            onPageChanged: onPageChanged,
          ),
          if (selectedDay != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Etkinlikler - ${_formatDate(selectedDay!)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildEventList(_getEventsForDay(selectedDay!)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventList(List<EventModel> dayEvents) {
    if (dayEvents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Bu tarihte etkinlik bulunmuyor',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(
      children: dayEvents.map((event) => _buildEventTile(event)).toList(),
    );
  }

  Widget _buildEventTile(EventModel event) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getEventTypeColor(event.type).withOpacity(0.2),
        child: Icon(
          _getEventTypeIcon(event.type),
          color: _getEventTypeColor(event.type),
          size: 20,
        ),
      ),
      title: Text(
        event.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_formatTime(event.startDate)} - ${_formatTime(event.endDate)}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Icon(
        event.location == EventLocation.online
            ? Icons.computer
            : Icons.location_on,
        size: 16,
        color: Colors.grey,
      ),
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
      case EventType.other:
        return Colors.grey;
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
      case EventType.other:
        return Icons.event;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

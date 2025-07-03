import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/event/event_controller.dart';
import 'package:devshabitat/app/models/event/event_model.dart';

class EventDetailsView extends GetView<EventController> {
  const EventDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final event = Get.arguments as EventModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              'Etkinlik Tipi',
              _getEventTypeText(event.type),
              _getEventTypeIcon(event.type),
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              'Lokasyon',
              event.location == EventLocation.online
                  ? 'Online'
                  : event.venueAddress ?? 'Konum belirtilmemiş',
              event.location == EventLocation.online
                  ? Icons.computer
                  : Icons.location_on,
            ),
            if (event.location == EventLocation.online &&
                event.onlineMeetingUrl != null) ...[
              const SizedBox(height: 8),
              Text(
                'Toplantı Linki: ${event.onlineMeetingUrl}',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildInfoSection(
              'Tarih ve Saat',
              '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
              Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              'Katılımcı Sayısı',
              '${event.currentParticipants}/${event.participantLimit}',
              Icons.person,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: event.currentParticipants < event.participantLimit
                    ? () => controller.registerForEvent(event.id)
                    : null,
                child: const Text('Katıl'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
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

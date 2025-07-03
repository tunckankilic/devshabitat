import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/models/event/event_model.dart';

class EventFilterWidget extends StatelessWidget {
  final bool showOnlineOnly;
  final bool showOfflineOnly;
  final bool showUpcomingOnly;
  final EventType? selectedType;
  final Function(bool) onOnlineFilterChanged;
  final Function(bool) onOfflineFilterChanged;
  final Function(bool) onUpcomingFilterChanged;
  final Function(EventType?) onEventTypeChanged;

  const EventFilterWidget({
    Key? key,
    required this.showOnlineOnly,
    required this.showOfflineOnly,
    required this.showUpcomingOnly,
    required this.selectedType,
    required this.onOnlineFilterChanged,
    required this.onOfflineFilterChanged,
    required this.onUpcomingFilterChanged,
    required this.onEventTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtreler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'Online',
                selected: showOnlineOnly,
                onSelected: onOnlineFilterChanged,
                icon: Icons.computer,
              ),
              _buildFilterChip(
                label: 'Yüz yüze',
                selected: showOfflineOnly,
                onSelected: onOfflineFilterChanged,
                icon: Icons.location_on,
              ),
              _buildFilterChip(
                label: 'Yaklaşan',
                selected: showUpcomingOnly,
                onSelected: onUpcomingFilterChanged,
                icon: Icons.upcoming,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Etkinlik Türü',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EventType.values.map((type) {
              return _buildFilterChip(
                label: _getEventTypeText(type),
                selected: selectedType == type,
                onSelected: (selected) {
                  onEventTypeChanged(selected ? type : null);
                },
                icon: _getEventTypeIcon(type),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
    required IconData icon,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey[800],
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Get.theme.primaryColor,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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

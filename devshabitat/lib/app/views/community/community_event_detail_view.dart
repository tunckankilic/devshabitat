import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/controllers/community/community_event_controller.dart';
import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/models/event/event_model.dart';

class CommunityEventDetailView extends GetView<CommunityEventController> {
  const CommunityEventDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final event = Get.arguments as EventModel;
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          Obx(() {
            final currentUser = authController.currentUser;
            if (currentUser != null && event.createdBy == currentUser.uid) {
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Get.toNamed('/event-edit', arguments: event);
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildEventInfo(event),
            const SizedBox(height: 24),
            _buildParticipantSection(event, authController),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo(EventModel event) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(AppStrings.dateAndTime),
              subtitle: Text('${event.startDate} - ${event.endDate}'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(AppStrings.location),
              subtitle: Text(event.type == EventType.online
                  ? event.onlineMeetingUrl ?? AppStrings.noLocation
                  : event.venueAddress ?? AppStrings.noLocation),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: Text(AppStrings.participantCount),
              subtitle: Text(
                  '${event.participants.length}/${event.participantLimit}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantSection(
      EventModel event, AuthController authController) {
    final currentUser = authController.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    final isParticipant = event.isParticipant(currentUser.uid);

    if (event.hasEnded) {
      return Center(
        child: Text(
          AppStrings.eventEnded,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      );
    }

    if (event.isFull && !isParticipant) {
      return Center(
        child: Text(
          AppStrings.quotaFull,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      );
    }

    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (isParticipant) {
            controller.leaveEvent(event.id);
          } else {
            controller.joinEvent(event.id);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isParticipant ? Colors.red : Theme.of(Get.context!).primaryColor,
        ),
        child: Text(
          isParticipant ? AppStrings.cancelRegistration : AppStrings.joinEvent,
        ),
      ),
    );
  }
}

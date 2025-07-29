import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/community/community_event_controller.dart';
import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import '../../routes/app_pages.dart';

class CommunityEventView extends GetView<CommunityEventController> {
  const CommunityEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildEventsList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.eventCreate),
        tooltip: AppStrings.createEvent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventsList() {
    if (controller.events.isEmpty) {
      return Center(
        child: Text(AppStrings.noEvents),
      );
    }

    return ListView.builder(
      itemCount: controller.events.length,
      itemBuilder: (context, index) {
        final event = controller.events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            const SizedBox(height: 4),
            Text(
              '${AppStrings.eventDate}: ${event.startDate.toString()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => Get.toNamed(
            AppRoutes.EVENT_DETAIL,
            arguments: event,
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/event/event_create_controller.dart';
import 'package:devshabitat/app/models/event/event_model.dart';

class EventCreateView extends GetView<EventCreateController> {
  const EventCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.createEvent),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isFormValid ? controller.createEvent : null,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(AppStrings.create),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: AppStrings.eventTitle,
                border: OutlineInputBorder(),
              ),
              onChanged: controller.updateTitle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: AppStrings.eventDescription,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: controller.updateDescription,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EventType>(
              decoration: const InputDecoration(
                labelText: AppStrings.eventType,
                border: OutlineInputBorder(),
              ),
              value: controller.type.value,
              items: EventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getEventTypeText(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.updateType(value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EventLocation>(
              decoration: const InputDecoration(
                labelText: AppStrings.eventLocation,
                border: OutlineInputBorder(),
              ),
              value: controller.location.value,
              items: EventLocation.values.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(
                    location == EventLocation.online
                        ? AppStrings.online
                        : AppStrings.inPerson,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.updateLocation(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Obx(
              () => controller.location.value == EventLocation.online
                  ? TextFormField(
                      decoration: const InputDecoration(
                        labelText: AppStrings.onlineMeetingUrl,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: controller.updateOnlineMeetingUrl,
                    )
                  : TextFormField(
                      decoration: const InputDecoration(
                        labelText: AppStrings.eventAddress,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: controller.updateVenueAddress,
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: AppStrings.startDate,
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: controller.startDate.value != null
                          ? _formatDate(controller.startDate.value!)
                          : '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          controller.updateStartDate(DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          ));
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: AppStrings.endDate,
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: controller.endDate.value != null
                          ? _formatDate(controller.endDate.value!)
                          : '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: controller.startDate.value ??
                            DateTime.now().add(const Duration(hours: 1)),
                        firstDate: controller.startDate.value ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          controller.updateEndDate(DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          ));
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: AppStrings.participantLimit,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  controller.updateParticipantLimit(int.tryParse(value) ?? 0),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.categories,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.selectedCategories.map((categoryId) {
                  return Chip(
                    label: Text(controller.getCategoryName(categoryId)),
                    onDeleted: () => controller.toggleCategory(categoryId),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEventTypeText(EventType type) {
    switch (type) {
      case EventType.meetup:
        return AppStrings.meetup;
      case EventType.workshop:
        return AppStrings.workshop;
      case EventType.hackathon:
        return AppStrings.hackathon;
      case EventType.conference:
        return AppStrings.conference;
      case EventType.other:
        return AppStrings.other;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

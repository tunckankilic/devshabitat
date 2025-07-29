import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/controllers/community/community_event_controller.dart';
import 'package:devshabitat/app/models/event/event_model.dart';

class CommunityEventCreateView extends GetView<CommunityEventController> {
  const CommunityEventCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final venueController = TextEditingController();
    final urlController = TextEditingController();
    final participantLimitController = TextEditingController();
    final selectedType = EventType.online.obs;
    final startDate = Rxn<DateTime>();
    final endDate = Rxn<DateTime>();
    final selectedCategories = <String>[].obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.createEvent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: AppStrings.eventTitle,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppStrings.eventDescription,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<EventType>(
                  value: selectedType.value,
                  decoration: InputDecoration(
                    labelText: AppStrings.eventType,
                    border: const OutlineInputBorder(),
                  ),
                  items: EventType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type == EventType.online
                          ? AppStrings.online
                          : AppStrings.inPerson),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedType.value = value;
                  },
                )),
            const SizedBox(height: 16),
            Obx(() => selectedType.value == EventType.online
                ? TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      labelText: AppStrings.onlineMeetingUrl,
                      border: const OutlineInputBorder(),
                    ),
                  )
                : TextField(
                    controller: venueController,
                    decoration: InputDecoration(
                      labelText: AppStrings.eventAddress,
                      border: const OutlineInputBorder(),
                    ),
                  )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => ListTile(
                        title: Text(AppStrings.startDate),
                        subtitle: Text(startDate.value?.toString() ??
                            AppStrings.notSelected),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) startDate.value = date;
                        },
                      )),
                ),
                Expanded(
                  child: Obx(() => ListTile(
                        title: Text(AppStrings.endDate),
                        subtitle: Text(endDate.value?.toString() ??
                            AppStrings.notSelected),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate.value ?? DateTime.now(),
                            firstDate: startDate.value ?? DateTime.now(),
                            lastDate: (startDate.value ?? DateTime.now())
                                .add(const Duration(days: 365)),
                          );
                          if (date != null) endDate.value = date;
                        },
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: participantLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.participantLimit,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_validateForm(
                    titleController.text,
                    descriptionController.text,
                    startDate.value,
                    endDate.value,
                    participantLimitController.text,
                  )) {
                    final event = EventModel(
                      id: '',
                      title: titleController.text,
                      description: descriptionController.text,
                      type: selectedType.value,
                      onlineMeetingUrl: selectedType.value == EventType.online
                          ? urlController.text
                          : null,
                      venueAddress: selectedType.value == EventType.inPerson
                          ? venueController.text
                          : null,
                      startDate: startDate.value!,
                      endDate: endDate.value!,
                      participantLimit:
                          int.parse(participantLimitController.text),
                      categories: selectedCategories,
                      participants: [],
                      createdBy: '',
                      createdAt: DateTime.now(),
                    );

                    controller.createEvent(event);
                    Get.back();
                  }
                },
                child: Text(AppStrings.create),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm(
    String title,
    String description,
    DateTime? start,
    DateTime? end,
    String limit,
  ) {
    if (title.isEmpty ||
        description.isEmpty ||
        start == null ||
        end == null ||
        limit.isEmpty) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.errorValidation,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final participantLimit = int.tryParse(limit);
    if (participantLimit == null || participantLimit <= 0) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.invalidCapacity,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (end.isBefore(start)) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.invalidDateFormat,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }
}

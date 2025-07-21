import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/event/event_discovery_controller.dart';
import 'package:devshabitat/app/widgets/event/event_card_widget.dart';
import 'package:devshabitat/app/widgets/event/event_calendar_widget.dart';

class MyEventsView extends GetView<EventDiscoveryController> {
  const MyEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.myEvents),
          bottom: const TabBar(
            tabs: [
              Tab(text: AppStrings.upcoming),
              Tab(text: AppStrings.past),
              Tab(text: AppStrings.calendar),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEventList(true),
            _buildEventList(false),
            _buildCalendarView(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(bool isUpcoming) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final events = controller.events.where((event) {
        final now = DateTime.now();
        return isUpcoming
            ? event.startDate.isAfter(now)
            : event.endDate.isBefore(now);
      }).toList();

      if (events.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUpcoming ? Icons.event_available : Icons.event_busy,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                isUpcoming
                    ? AppStrings.noUpcomingEvents
                    : AppStrings.noPastEvents,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadEvents(refresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return EventCard(
              event: events[index],
              showDetailedInfo: true,
            );
          },
        ),
      );
    });
  }

  Widget _buildCalendarView() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              EventCalendarWidget(
                focusedDay: controller.selectedDay.value ?? DateTime.now(),
                selectedDay: controller.selectedDay.value,
                events: controller.events,
                onDaySelected: (selectedDay, focusedDay) {
                  controller.selectedDay.value = selectedDay;
                },
                onPageChanged: (focusedDay) {
                  controller.selectedDay.value = null;
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}

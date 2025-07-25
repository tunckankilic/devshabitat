import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/event/event_controller.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import '../base/base_view.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveText, ResponsiveSafeArea;
import '../../widgets/responsive/animated_responsive_layout.dart';

class EventDetailsView extends BaseView<EventController> {
  const EventDetailsView({super.key});

  @override
  Widget buildView(BuildContext context) {
    final event = Get.arguments as EventModel;

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          event.title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
      ),
      body: ResponsiveSafeArea(
        child: ResponsiveOverflowHandler(
          child: AnimatedResponsiveLayout(
            mobile: _buildMobileEventDetails(event, context),
            tablet: _buildTabletEventDetails(event, context),
            animationDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileEventDetails(EventModel event, BuildContext context) {
    return SingleChildScrollView(
      padding: responsive.responsivePadding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventHeader(event),
          SizedBox(
              height: responsive.responsiveValue(
            mobile: 16,
            tablet: 24,
          )),
          _buildEventDescription(event),
          SizedBox(
              height: responsive.responsiveValue(
            mobile: 24,
            tablet: 32,
          )),
          _buildEventInfo(event),
          SizedBox(
              height: responsive.responsiveValue(
            mobile: 24,
            tablet: 32,
          )),
          _buildParticipationButton(event),
        ],
      ),
    );
  }

  Widget _buildTabletEventDetails(EventModel event, BuildContext context) {
    return SingleChildScrollView(
      padding: responsive.responsivePadding(all: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventHeader(event),
                SizedBox(
                    height: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 32,
                )),
                _buildEventDescription(event),
              ],
            ),
          ),
          SizedBox(
              width: responsive.responsiveValue(
            mobile: 32,
            tablet: 48,
          )),
          Expanded(
            child: Column(
              children: [
                _buildEventInfo(event),
                SizedBox(
                    height: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 32,
                )),
                _buildParticipationButton(event),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventHeader(EventModel event) {
    return ResponsiveText(
      event.title,
      style: TextStyle(
        fontSize: responsive.responsiveValue(
          mobile: 24,
          tablet: 28,
        ),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEventDescription(EventModel event) {
    return ResponsiveText(
      event.description,
      style: TextStyle(
        fontSize: responsive.responsiveValue(
          mobile: 16,
          tablet: 18,
        ),
      ),
    );
  }

  Widget _buildEventInfo(EventModel event) {
    return Column(
      children: [
        _buildInfoSection(
          AppStrings.eventType,
          _getEventTypeText(event.type),
          _getEventTypeIcon(event.type),
        ),
        SizedBox(
            height: responsive.responsiveValue(
          mobile: 16,
          tablet: 24,
        )),
        _buildInfoSection(
          AppStrings.location,
          event.location == EventLocation.online
              ? AppStrings.online
              : event.venueAddress ?? AppStrings.noLocation,
          event.location == EventLocation.online
              ? Icons.computer
              : Icons.location_on,
        ),
        if (event.location == EventLocation.online &&
            event.onlineMeetingUrl != null) ...[
          SizedBox(
              height: responsive.responsiveValue(
            mobile: 8,
            tablet: 12,
          )),
          ResponsiveText(
            '${AppStrings.onlineMeetingUrl}: ${event.onlineMeetingUrl}',
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 14,
                tablet: 16,
              ),
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
        SizedBox(
            height: responsive.responsiveValue(
          mobile: 16,
          tablet: 24,
        )),
        _buildInfoSection(
          AppStrings.dateAndTime,
          '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
          Icons.calendar_today,
        ),
        SizedBox(
            height: responsive.responsiveValue(
          mobile: 16,
          tablet: 24,
        )),
        _buildInfoSection(
          AppStrings.participantCount,
          '${event.currentParticipants}/${event.participantLimit}',
          Icons.person,
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: responsive.responsiveValue(
            mobile: 24,
            tablet: 28,
          ),
        ),
        SizedBox(
            width: responsive.responsiveValue(
          mobile: 8,
          tablet: 12,
        )),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                title,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14,
                    tablet: 16,
                  ),
                  color: Colors.grey,
                ),
              ),
              ResponsiveText(
                content,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipationButton(EventModel event) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: event.currentParticipants < event.participantLimit
            ? () => controller.registerForEvent(event.id)
            : null,
        style: ElevatedButton.styleFrom(
          padding: responsive.responsivePadding(
            vertical: 16,
            horizontal: 24,
          ),
        ),
        child: ResponsiveText(
          'Katıl',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
          ),
        ),
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

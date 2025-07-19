import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:devshabitat/app/controllers/event/event_controller.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import '../base/base_view.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveText, ResponsiveSafeArea;
import '../../widgets/responsive/animated_responsive_layout.dart';

class EventDetailsView extends BaseView<EventController> {
  const EventDetailsView({Key? key}) : super(key: key);

  @override
  Widget buildView(BuildContext context) {
    final event = Get.arguments as EventModel;

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          event.title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18.sp,
              tablet: 22.sp,
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
          SizedBox(height: 16.h),
          _buildEventDescription(event),
          SizedBox(height: 24.h),
          _buildEventInfo(event),
          SizedBox(height: 24.h),
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
                SizedBox(height: 24.h),
                _buildEventDescription(event),
              ],
            ),
          ),
          SizedBox(width: 32.w),
          Expanded(
            child: Column(
              children: [
                _buildEventInfo(event),
                SizedBox(height: 24.h),
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
          mobile: 24.sp,
          tablet: 28.sp,
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
          mobile: 16.sp,
          tablet: 18.sp,
        ),
      ),
    );
  }

  Widget _buildEventInfo(EventModel event) {
    return Column(
      children: [
        _buildInfoSection(
          'Etkinlik Tipi',
          _getEventTypeText(event.type),
          _getEventTypeIcon(event.type),
        ),
        SizedBox(height: 16.h),
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
          SizedBox(height: 8.h),
          ResponsiveText(
            'Toplantı Linki: ${event.onlineMeetingUrl}',
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 14.sp,
                tablet: 16.sp,
              ),
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
        SizedBox(height: 16.h),
        _buildInfoSection(
          'Tarih ve Saat',
          '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
          Icons.calendar_today,
        ),
        SizedBox(height: 16.h),
        _buildInfoSection(
          'Katılımcı Sayısı',
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
            mobile: 24.sp,
            tablet: 28.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                title,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14.sp,
                    tablet: 16.sp,
                  ),
                  color: Colors.grey,
                ),
              ),
              ResponsiveText(
                content,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16.sp,
                    tablet: 18.sp,
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
              mobile: 16.sp,
              tablet: 18.sp,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

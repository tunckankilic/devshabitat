import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../base/base_view.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveText, ResponsiveSafeArea;
import '../../widgets/responsive/animated_responsive_layout.dart';

class NotificationsView extends BaseView<HomeController> {
  const NotificationsView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          AppStrings.notifications,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
        actions: [
          AdaptiveTouchTarget(
            onTap: () => controller.markAllNotificationsAsRead(),
            child: Icon(
              Icons.check_circle_outline,
              size: responsive.minTouchTarget,
            ),
          ),
        ],
      ),
      body: ResponsiveSafeArea(
        child: ResponsiveOverflowHandler(
          child: AnimatedResponsiveLayout(
            mobile: _buildMobileNotifications(),
            tablet: _buildTabletNotifications(),
            animationDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNotifications() {
    return Obx(
      () => ListView.builder(
        padding: responsive.responsivePadding(all: 16),
        itemCount: controller.notifications.length,
        itemBuilder: (context, index) {
          final notification = controller.notifications[index];
          return _buildNotificationTile(notification);
        },
      ),
    );
  }

  Widget _buildTabletNotifications() {
    return Obx(
      () => Center(
        child: Container(
          constraints: BoxConstraints(
              maxWidth: responsive.responsiveValue(mobile: 800, tablet: 1000)),
          padding: responsive.responsivePadding(all: 24),
          child: ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _buildNotificationTile(notification);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(dynamic notification) {
    return Card(
      margin: responsive.responsivePadding(
        bottom: responsive.responsiveValue(
          mobile: 8,
          tablet: 12,
        ),
      ),
      child: ListTile(
        contentPadding: responsive.responsivePadding(all: 16),
        leading: CircleAvatar(
          radius: responsive.responsiveValue(
            mobile: 24,
            tablet: 32,
          ),
          child: Icon(
            Icons.notifications,
            size: responsive.responsiveValue(
              mobile: 24,
              tablet: 28,
            ),
          ),
        ),
        title: ResponsiveText(
          notification.title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: ResponsiveText(
          notification.body,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 14,
              tablet: 16,
            ),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: ResponsiveText(
          AppStrings.hoursAgo(
              notification.createdAt.difference(DateTime.now()).inHours.abs()),
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 12,
              tablet: 14,
            ),
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/notification_service.dart';

class NotificationSettingsView extends GetView<NotificationService> {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.notificationSettings),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.generalSettings,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildGeneralSettings(),
              const SizedBox(height: 24),
              Text(
                AppStrings.notificationCategories,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildCategorySettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Column(
        children: [
          Obx(
            () => SwitchListTile(
              title: Text(AppStrings.pushNotifications),
              subtitle: Text(AppStrings.pushNotificationsSubtitle),
              value: controller.isPushEnabled.value,
              onChanged: (value) => controller.updatePushPreference(value),
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: Text(AppStrings.inAppNotifications),
              subtitle: Text(AppStrings.inAppNotificationsSubtitle),
              value: controller.isInAppEnabled.value,
              onChanged: (value) => controller.updateInAppPreference(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySettings() {
    return Card(
      child: Column(
        children: [
          Obx(
            () => SwitchListTile(
              title: Text(AppStrings.eventNotifications),
              subtitle: Text(AppStrings.eventNotificationsSubtitle),
              value: controller.categoryPreferences['events']?.value ?? true,
              onChanged: (value) =>
                  controller.updateCategoryPreference('events', value),
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: Text(AppStrings.messageNotifications),
              subtitle: Text(AppStrings.messageNotificationsSubtitle),
              value: controller.categoryPreferences['messages']?.value ?? true,
              onChanged: (value) =>
                  controller.updateCategoryPreference('messages', value),
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: Text(AppStrings.communityNotifications),
              subtitle: Text(AppStrings.communityNotificationsSubtitle),
              value: controller.categoryPreferences['community']?.value ?? true,
              onChanged: (value) =>
                  controller.updateCategoryPreference('community', value),
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: Text(AppStrings.connectionNotifications),
              subtitle: Text(AppStrings.connectionNotificationsSubtitle),
              value:
                  controller.categoryPreferences['connections']?.value ?? true,
              onChanged: (value) =>
                  controller.updateCategoryPreference('connections', value),
            ),
          ),
        ],
      ),
    );
  }
}

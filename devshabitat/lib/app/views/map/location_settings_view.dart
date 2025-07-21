import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/location/map_controller.dart';

class LocationSettingsView extends GetView<MapController> {
  const LocationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.locationSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLocationPermissionSection(),
          const Divider(),
          _buildLocationTrackingSection(context),
          const Divider(),
          _buildNotificationSection(),
          const Divider(),
          _buildPrivacySection(),
        ],
      ),
    );
  }

  Widget _buildLocationPermissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.locationPermissions,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: Text(AppStrings.locationAccess),
          subtitle: Text(AppStrings.allowLocationAccess),
          trailing: Obx(() {
            return Switch(
              value: controller.locationPermissionGranted.value,
              onChanged: controller.requestLocationPermission,
            );
          }),
        ),
        ListTile(
          title: Text(AppStrings.backgroundLocation),
          subtitle: Text(AppStrings.allowBackgroundLocation),
          trailing: Obx(() {
            return Switch(
              value: controller.backgroundLocationEnabled.value,
              onChanged: controller.locationPermissionGranted.value
                  ? controller.toggleBackgroundLocation
                  : null,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLocationTrackingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.locationTracking,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: Text(AppStrings.locationUpdates),
          subtitle: Text(AppStrings.selectUpdateInterval),
          onTap: () => _showUpdateIntervalDialog(context),
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
          title: Text(AppStrings.batteryOptimization),
          subtitle: Text(AppStrings.adjustLocationAccuracy),
          onTap: () => _showAccuracyDialog(context),
          trailing: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.notifications,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: Text(AppStrings.nearbyEvents),
          subtitle: Text(AppStrings.receiveNotificationsForNearbyEvents),
          trailing: Obx(() {
            return Switch(
              value: controller.nearbyEventNotifications.value,
              onChanged: controller.toggleNearbyEventNotifications,
            );
          }),
        ),
        ListTile(
          title: Text(AppStrings.nearbyDevelopers),
          subtitle: Text(AppStrings.receiveNotificationsForNearbyDevelopers),
          trailing: Obx(() {
            return Switch(
              value: controller.nearbyDeveloperNotifications.value,
              onChanged: controller.toggleNearbyDeveloperNotifications,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.privacy,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: Text(AppStrings.locationSharing),
          subtitle: Text(AppStrings.shareLocationWithOthers),
          trailing: Obx(() {
            return Switch(
              value: controller.locationSharingEnabled.value,
              onChanged: controller.toggleLocationSharing,
            );
          }),
        ),
        ListTile(
          title: Text(AppStrings.locationHistory),
          subtitle: Text(AppStrings.manageLocationHistory),
          onTap: () => Get.toNamed('/location-history'),
          trailing: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void _showUpdateIntervalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.updateInterval),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: Text(AppStrings.high),
              value: 5,
              groupValue: controller.updateInterval.value,
              onChanged: (value) {
                controller.updateInterval.value = value!;
                Get.back();
              },
            ),
            RadioListTile<int>(
              title: Text(AppStrings.normal),
              value: 15,
              groupValue: controller.updateInterval.value,
              onChanged: (value) {
                controller.updateInterval.value = value!;
                Get.back();
              },
            ),
            RadioListTile<int>(
              title: Text(AppStrings.low),
              value: 30,
              groupValue: controller.updateInterval.value,
              onChanged: (value) {
                controller.updateInterval.value = value!;
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAccuracyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.locationAccuracy),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(AppStrings.high),
              subtitle: Text(AppStrings.moreBatteryUsage),
              value: 'high',
              groupValue: controller.locationAccuracy.value,
              onChanged: (value) {
                controller.locationAccuracy.value = value!;
                Get.back();
              },
            ),
            RadioListTile<String>(
              title: Text(AppStrings.balanced),
              subtitle: Text(AppStrings.recommended),
              value: 'balanced',
              groupValue: controller.locationAccuracy.value,
              onChanged: (value) {
                controller.locationAccuracy.value = value!;
                Get.back();
              },
            ),
            RadioListTile<String>(
              title: Text(AppStrings.low),
              subtitle: Text(AppStrings.batterySaving),
              value: 'low',
              groupValue: controller.locationAccuracy.value,
              onChanged: (value) {
                controller.locationAccuracy.value = value!;
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/privacy_controller.dart';
import '../../controllers/responsive_controller.dart';

class PrivacySettingsScreen extends GetView<PrivacyController> {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.privacySettings,
            style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20))),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: responsive.responsivePadding(all: 16),
                children: [
                  Card(
                    child: Padding(
                      padding: responsive.responsivePadding(all: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.profilePrivacy,
                            style: TextStyle(
                              fontSize: responsive.responsiveValue(
                                  mobile: 18, tablet: 20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                              height: responsive.responsiveValue(
                                  mobile: 16, tablet: 20)),
                          _buildPrivacyOption(
                            AppStrings.profileVisibility,
                            'Profilinizi kimlerin görebileceğini seçin',
                            Icons.visibility,
                            responsive,
                          ),
                          SizedBox(
                              height: responsive.responsiveValue(
                                  mobile: 8, tablet: 12)),
                          _buildPrivacyOption(
                            AppStrings.connectionRequests,
                            'Kimlerden bağlantı isteği alabileceğinizi seçin',
                            Icons.person_add,
                            responsive,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                  Card(
                    child: Padding(
                      padding: responsive.responsivePadding(all: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.notificationSettings,
                            style: TextStyle(
                              fontSize: responsive.responsiveValue(
                                  mobile: 18, tablet: 20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                              height: responsive.responsiveValue(
                                  mobile: 16, tablet: 20)),
                          _buildNotificationOption(
                            AppStrings.connectionRequests,
                            AppStrings.newConnectionRequests,
                            responsive,
                          ),
                          SizedBox(
                              height: responsive.responsiveValue(
                                  mobile: 8, tablet: 12)),
                          _buildNotificationOption(
                            AppStrings.messages,
                            AppStrings.newMessages,
                            responsive,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                  Card(
                    child: Padding(
                      padding: responsive.responsivePadding(all: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.blockManagement,
                            style: TextStyle(
                              fontSize: responsive.responsiveValue(
                                  mobile: 18, tablet: 20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                              height: responsive.responsiveValue(
                                  mobile: 16, tablet: 20)),
                          _buildPrivacyOption(
                            AppStrings.blockedUsers,
                            AppStrings.manageBlockedUsers,
                            Icons.block,
                            responsive,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPrivacyOption(String title, String subtitle, IconData icon,
      ResponsiveController responsive) {
    return ListTile(
      leading:
          Icon(icon, size: responsive.responsiveValue(mobile: 24, tablet: 28)),
      title: Text(title,
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 16, tablet: 18))),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16))),
      trailing: Icon(Icons.chevron_right,
          size: responsive.responsiveValue(mobile: 24, tablet: 28)),
      onTap: () {
        if (title == AppStrings.blockedUsers) {
          _showBlockedUsers(responsive);
        } else {
          _showVisibilityOptions(responsive);
        }
      },
    );
  }

  Widget _buildNotificationOption(
      String title, String subtitle, ResponsiveController responsive) {
    return SwitchListTile(
      title: Text(title,
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 16, tablet: 18))),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16))),
      value: true,
      onChanged: (value) {
        _showNotificationSettings(responsive);
      },
    );
  }

  void _showVisibilityOptions(ResponsiveController responsive) {
    Get.bottomSheet(
      Container(
        padding: responsive.responsivePadding(all: 16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                responsive.responsiveValue(mobile: 16, tablet: 20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.profileVisibility,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            ListTile(
              leading: Icon(Icons.public,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.public,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                AppStrings.everyoneCanSee,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16)),
              ),
              onTap: () {
                Get.back();
                // Herkese açık ayarı
              },
            ),
            ListTile(
              leading: Icon(Icons.group,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.onlyConnections,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                AppStrings.onlyConnectionsCanSee,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16)),
              ),
              onTap: () {
                Get.back();
                // Sadece bağlantılar ayarı
              },
            ),
            ListTile(
              leading: Icon(Icons.lock,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.private,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                AppStrings.yourProfileIsPrivate,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16)),
              ),
              onTap: () {
                Get.back();
                // Gizli ayarı
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockedUsers(ResponsiveController responsive) {
    Get.bottomSheet(
      Container(
        padding: responsive.responsivePadding(all: 16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                responsive.responsiveValue(mobile: 16, tablet: 20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.blockedUsers,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Örnek veri
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius:
                          responsive.responsiveValue(mobile: 20, tablet: 24),
                      child: Text(
                        'K$index',
                        style: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 14, tablet: 16)),
                      ),
                    ),
                    title: Text(
                      'User ${index + 1}',
                      style: TextStyle(
                          fontSize: responsive.responsiveValue(
                              mobile: 16, tablet: 18)),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        // Engeli kaldır
                      },
                      child: Text(
                        AppStrings.removeBlock,
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                              mobile: 14, tablet: 16),
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(ResponsiveController responsive) {
    Get.bottomSheet(
      Container(
        padding: responsive.responsivePadding(all: 16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                responsive.responsiveValue(mobile: 16, tablet: 20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.notificationSettings,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            SwitchListTile(
              title: Text(
                AppStrings.connectionRequests,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                AppStrings.newConnectionRequests,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16)),
              ),
              value: true,
              onChanged: (value) {
                // Bildirim ayarını güncelle
              },
            ),
            SwitchListTile(
              title: Text(
                AppStrings.messages,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                AppStrings.newMessages,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16)),
              ),
              value: true,
              onChanged: (value) {
                // Bildirim ayarını güncelle
              },
            ),
            SwitchListTile(
              title: Text(
                AppStrings.interactions,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                AppStrings.interactionsWithYourProfile,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16)),
              ),
              value: true,
              onChanged: (value) {
                // Bildirim ayarını güncelle
              },
            ),
          ],
        ),
      ),
    );
  }
}

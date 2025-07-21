import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings/privacy_settings_controller.dart';

class PrivacySettingsView extends GetView<PrivacySettingsController> {
  const PrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.privacySettings),
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              AppStrings.profileVisibility,
              [
                SwitchListTile(
                  title: Text(AppStrings.makeProfilePublic),
                  subtitle: const Text(
                    AppStrings.profileVisibilitySubtitle,
                  ),
                  value: controller.settings.value.isProfilePublic,
                  onChanged: (value) => controller.updateSettings(
                    isProfilePublic: value,
                  ),
                ),
                SwitchListTile(
                  title: Text(AppStrings.showLocation),
                  value: controller.settings.value.showLocation,
                  onChanged: (value) => controller.updateSettings(
                    showLocation: value,
                  ),
                ),
              ],
            ),
            _buildSection(
              AppStrings.connectionRequests,
              [
                SwitchListTile(
                  title: Text(AppStrings.allowConnectionRequests),
                  value: controller.settings.value.allowConnectionRequests,
                  onChanged: (value) => controller.updateSettings(
                    allowConnectionRequests: value,
                  ),
                ),
                SwitchListTile(
                  title: Text(AppStrings.allowMentorshipRequests),
                  value: controller.settings.value.allowMentorshipRequests,
                  onChanged: (value) => controller.updateSettings(
                    allowMentorshipRequests: value,
                  ),
                ),
              ],
            ),
            _buildSection(
              AppStrings.profileDetails,
              [
                SwitchListTile(
                  title: Text(AppStrings.showTechnologies),
                  value: controller.settings.value.showTechnologies,
                  onChanged: (value) => controller.updateSettings(
                    showTechnologies: value,
                  ),
                ),
                SwitchListTile(
                  title: Text(AppStrings.showBio),
                  value: controller.settings.value.showBio,
                  onChanged: (value) => controller.updateSettings(
                    showBio: value,
                  ),
                ),
              ],
            ),
            _buildSection(
              AppStrings.blockedUsers,
              [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.settings.value.blockedUsers.length,
                  itemBuilder: (context, index) {
                    final userId =
                        controller.settings.value.blockedUsers[index];
                    return ListTile(
                      title: Text(userId),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => controller.unblockUser(userId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: Get.textTheme.titleMedium,
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

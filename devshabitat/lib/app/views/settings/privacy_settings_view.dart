import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings/privacy_settings_controller.dart';

class PrivacySettingsView extends GetView<PrivacySettingsController> {
  const PrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Ayarları'),
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              'Profil Görünürlüğü',
              [
                SwitchListTile(
                  title: const Text('Profili Herkese Açık Yap'),
                  subtitle: const Text(
                    'Profiliniz tüm kullanıcılar tarafından görüntülenebilir',
                  ),
                  value: controller.settings.value.isProfilePublic,
                  onChanged: (value) => controller.updateSettings(
                    isProfilePublic: value,
                  ),
                ),
                SwitchListTile(
                  title: const Text('Konum Bilgisini Göster'),
                  value: controller.settings.value.showLocation,
                  onChanged: (value) => controller.updateSettings(
                    showLocation: value,
                  ),
                ),
              ],
            ),
            _buildSection(
              'Bağlantı İstekleri',
              [
                SwitchListTile(
                  title: const Text('Bağlantı İsteklerine İzin Ver'),
                  value: controller.settings.value.allowConnectionRequests,
                  onChanged: (value) => controller.updateSettings(
                    allowConnectionRequests: value,
                  ),
                ),
                SwitchListTile(
                  title: const Text('Mentorluk İsteklerine İzin Ver'),
                  value: controller.settings.value.allowMentorshipRequests,
                  onChanged: (value) => controller.updateSettings(
                    allowMentorshipRequests: value,
                  ),
                ),
              ],
            ),
            _buildSection(
              'Profil Detayları',
              [
                SwitchListTile(
                  title: const Text('Teknolojileri Göster'),
                  value: controller.settings.value.showTechnologies,
                  onChanged: (value) => controller.updateSettings(
                    showTechnologies: value,
                  ),
                ),
                SwitchListTile(
                  title: const Text('Biyografiyi Göster'),
                  value: controller.settings.value.showBio,
                  onChanged: (value) => controller.updateSettings(
                    showBio: value,
                  ),
                ),
              ],
            ),
            _buildSection(
              'Engellenen Kullanıcılar',
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

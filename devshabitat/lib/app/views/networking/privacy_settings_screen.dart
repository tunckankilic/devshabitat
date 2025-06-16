import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/privacy_controller.dart';

class PrivacySettingsScreen extends GetView<PrivacyController> {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Ayarları'),
        elevation: 0,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSectionTitle('Profil Görünürlüğü'),
                  _buildVisibilityCard(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Bağlantı İstekleri'),
                  _buildConnectionRequestCard(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Çevrimiçi Durum'),
                  _buildOnlineStatusCard(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Engellenen Kullanıcılar'),
                  _buildBlockedUsersCard(),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVisibilityCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Profil Görünürlüğü'),
            subtitle: const Text('Profilinizi kimlerin görebileceğini seçin'),
            trailing: Switch(
              value: controller.isProfilePublic.value,
              onChanged: controller.updateProfileVisibility,
            ),
          ),
          ListTile(
            title: const Text('Son Görülme'),
            subtitle: const Text('Son görülme zamanınızı göster'),
            trailing: Switch(
              value: controller.showLastSeen.value,
              onChanged: controller.updateLastSeenVisibility,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionRequestCard() {
    return Card(
      child: ListTile(
        title: const Text('Bağlantı İsteklerine İzin Ver'),
        subtitle:
            const Text('Diğer kullanıcılar size bağlantı isteği gönderebilir'),
        trailing: Switch(
          value: controller.allowConnectionRequests.value,
          onChanged: controller.updateConnectionRequestSetting,
        ),
      ),
    );
  }

  Widget _buildOnlineStatusCard() {
    return Card(
      child: ListTile(
        title: const Text('Çevrimiçi Durumu Göster'),
        subtitle:
            const Text('Çevrimiçi olduğunuzu diğer kullanıcılara gösterin'),
        trailing: Switch(
          value: controller.showOnlineStatus.value,
          onChanged: controller.updateOnlineStatusVisibility,
        ),
      ),
    );
  }

  Widget _buildBlockedUsersCard() {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Engellenen Kullanıcılar (${controller.blockedUsers.length})',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (controller.blockedUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Engellenen kullanıcı bulunmuyor'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.blockedUsers.length,
              itemBuilder: (context, index) {
                final userId = controller.blockedUsers[index];
                return ListTile(
                  title: Text('Kullanıcı $userId'),
                  trailing: TextButton(
                    onPressed: () => controller.unblockUser(userId),
                    child: const Text('Engeli Kaldır'),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

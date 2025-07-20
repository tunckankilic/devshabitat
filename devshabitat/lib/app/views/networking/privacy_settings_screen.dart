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
        title: Text('Gizlilik Ayarları',
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
                            'Profil Gizliliği',
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
                            'Profil Görünürlüğü',
                            'Profilinizi kimlerin görebileceğini seçin',
                            Icons.visibility,
                            responsive,
                          ),
                          SizedBox(
                              height: responsive.responsiveValue(
                                  mobile: 8, tablet: 12)),
                          _buildPrivacyOption(
                            'Bağlantı İstekleri',
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
                            'Bildirim Ayarları',
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
                            'Bağlantı İstekleri',
                            'Yeni bağlantı istekleri için bildirim al',
                            responsive,
                          ),
                          SizedBox(
                              height: responsive.responsiveValue(
                                  mobile: 8, tablet: 12)),
                          _buildNotificationOption(
                            'Mesajlar',
                            'Yeni mesajlar için bildirim al',
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
                            'Engelleme Yönetimi',
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
                            'Engellenen Kullanıcılar',
                            'Engellediğiniz kullanıcıları yönetin',
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
        if (title == 'Engellenen Kullanıcılar') {
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
              'Profil Görünürlüğü',
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
                'Herkese Açık',
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                'Profilinizi herkes görebilir',
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
                'Sadece Bağlantılar',
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                'Profilinizi sadece bağlantılarınız görebilir',
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
                'Gizli',
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                'Profiliniz gizlidir',
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
              'Engellenen Kullanıcılar',
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
                      'Kullanıcı ${index + 1}',
                      style: TextStyle(
                          fontSize: responsive.responsiveValue(
                              mobile: 16, tablet: 18)),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        // Engeli kaldır
                      },
                      child: Text(
                        'Engeli Kaldır',
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
              'Bildirim Ayarları',
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            SwitchListTile(
              title: Text(
                'Bağlantı İstekleri',
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                'Yeni bağlantı istekleri için bildirim al',
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
                'Mesajlar',
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                'Yeni mesajlar için bildirim al',
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
                'Etkileşimler',
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              subtitle: Text(
                'Profilinizle ilgili etkileşimler için bildirim al',
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/privacy_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacySettingsScreen extends GetView<PrivacyController> {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gizlilik Ayarları', style: TextStyle(fontSize: 18.sp)),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.all(16.r),
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profil Gizliliği',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildPrivacyOption(
                            'Profil Görünürlüğü',
                            'Profilinizi kimlerin görebileceğini seçin',
                            Icons.visibility,
                          ),
                          SizedBox(height: 8.h),
                          _buildPrivacyOption(
                            'Bağlantı İstekleri',
                            'Kimlerden bağlantı isteği alabileceğinizi seçin',
                            Icons.person_add,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bildirim Ayarları',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildNotificationOption(
                            'Bağlantı İstekleri',
                            'Yeni bağlantı istekleri için bildirim al',
                          ),
                          SizedBox(height: 8.h),
                          _buildNotificationOption(
                            'Mesajlar',
                            'Yeni mesajlar için bildirim al',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Engelleme Yönetimi',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildPrivacyOption(
                            'Engellenen Kullanıcılar',
                            'Engellediğiniz kullanıcıları yönetin',
                            Icons.block,
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

  Widget _buildPrivacyOption(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 24.sp),
      title: Text(title, style: TextStyle(fontSize: 16.sp)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 14.sp)),
      trailing: Icon(Icons.chevron_right, size: 24.sp),
      onTap: () {
        if (title == 'Engellenen Kullanıcılar') {
          _showBlockedUsers();
        } else {
          _showVisibilityOptions();
        }
      },
    );
  }

  Widget _buildNotificationOption(String title, String subtitle) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: 16.sp)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 14.sp)),
      value: true,
      onChanged: (value) {
        _showNotificationSettings();
      },
    );
  }

  void _showVisibilityOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profil Görünürlüğü',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.public, size: 24.sp),
              title: Text(
                'Herkese Açık',
                style: TextStyle(fontSize: 16.sp),
              ),
              subtitle: Text(
                'Profilinizi herkes görebilir',
                style: TextStyle(fontSize: 14.sp),
              ),
              onTap: () {
                Get.back();
                // Herkese açık ayarı
              },
            ),
            ListTile(
              leading: Icon(Icons.group, size: 24.sp),
              title: Text(
                'Sadece Bağlantılar',
                style: TextStyle(fontSize: 16.sp),
              ),
              subtitle: Text(
                'Profilinizi sadece bağlantılarınız görebilir',
                style: TextStyle(fontSize: 14.sp),
              ),
              onTap: () {
                Get.back();
                // Sadece bağlantılar ayarı
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, size: 24.sp),
              title: Text(
                'Gizli',
                style: TextStyle(fontSize: 16.sp),
              ),
              subtitle: Text(
                'Profiliniz gizlidir',
                style: TextStyle(fontSize: 14.sp),
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

  void _showBlockedUsers() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Engellenen Kullanıcılar',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Örnek veri
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20.r,
                      child: Text(
                        'K$index',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    title: Text(
                      'Kullanıcı ${index + 1}',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        // Engeli kaldır
                      },
                      child: Text(
                        'Engeli Kaldır',
                        style: TextStyle(
                          fontSize: 14.sp,
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

  void _showNotificationSettings() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bildirim Ayarları',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            SwitchListTile(
              title: Text(
                'Bağlantı İstekleri',
                style: TextStyle(fontSize: 16.sp),
              ),
              subtitle: Text(
                'Yeni bağlantı istekleri için bildirim al',
                style: TextStyle(fontSize: 14.sp),
              ),
              value: true,
              onChanged: (value) {
                // Bildirim ayarını güncelle
              },
            ),
            SwitchListTile(
              title: Text(
                'Mesajlar',
                style: TextStyle(fontSize: 16.sp),
              ),
              subtitle: Text(
                'Yeni mesajlar için bildirim al',
                style: TextStyle(fontSize: 14.sp),
              ),
              value: true,
              onChanged: (value) {
                // Bildirim ayarını güncelle
              },
            ),
            SwitchListTile(
              title: Text(
                'Etkileşimler',
                style: TextStyle(fontSize: 16.sp),
              ),
              subtitle: Text(
                'Profilinizle ilgili etkileşimler için bildirim al',
                style: TextStyle(fontSize: 14.sp),
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

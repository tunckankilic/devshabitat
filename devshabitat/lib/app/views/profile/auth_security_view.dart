import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_state_controller.dart';
import '../base/base_view.dart';
import '../../widgets/responsive/responsive_text.dart';

class AuthSecurityView extends BaseView<AuthStateController> {
  const AuthSecurityView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Güvenlik Ayarları',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSecurityOverview(context),
            const SizedBox(height: 24),
            _buildActiveSessions(context),
            const SizedBox(height: 24),
            _buildLoginHistory(context),
            const SizedBox(height: 24),
            _buildSecurityActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOverview(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                ResponsiveText(
                  'Güvenlik Durumu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => ListTile(
                  leading: Icon(
                    controller.currentUser?.emailVerified == true
                        ? Icons.verified_user
                        : Icons.warning,
                    color: controller.currentUser?.emailVerified == true
                        ? Colors.green
                        : Colors.orange,
                  ),
                  title: ResponsiveText('E-posta Doğrulama'),
                  subtitle: ResponsiveText(
                    controller.currentUser?.emailVerified == true
                        ? 'E-posta doğrulanmış'
                        : 'E-posta doğrulanmamış',
                  ),
                  trailing: controller.currentUser?.emailVerified != true
                      ? TextButton(
                          onPressed: () => controller.verifyEmail(),
                          child: ResponsiveText('Doğrula'),
                        )
                      : null,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                ResponsiveText(
                  'Aktif Oturumlar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.phone_android),
              title: ResponsiveText('Bu Cihaz'),
              subtitle: ResponsiveText('Aktif • Şimdi'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginHistory(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                ResponsiveText(
                  'Giriş Geçmişi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.access_time),
              title: ResponsiveText('Son Giriş'),
              subtitle: ResponsiveText(
                controller.currentUser?.metadata.lastSignInTime?.toString() ??
                    'Bilinmiyor',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityActions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                ResponsiveText(
                  'Güvenlik İşlemleri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.password, color: Colors.blue),
              title: ResponsiveText('Şifre Değiştir'),
              onTap: () => _showPasswordChangeDialog(context),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.orange),
              title: ResponsiveText('Tüm Cihazlardan Çıkış Yap'),
              onTap: () => _showSignOutFromAllDevicesDialog(context),
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red),
              title: ResponsiveText('Hesabı Sil'),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordChangeDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText('Şifre Değiştir'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Mevcut Şifre',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mevcut şifre gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Yeni Şifre',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Yeni şifre gerekli';
                  }
                  if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Yeni Şifre (Tekrar)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Şifreler eşleşmiyor';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ResponsiveText('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                // Password change functionality
                Get.snackbar(
                  'Bilgi',
                  'Şifre değiştirme özelliği yakında eklenecek',
                  backgroundColor: Colors.blue.withOpacity(0.8),
                  colorText: Colors.white,
                );
              }
            },
            child: ResponsiveText('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText('Hesabı Sil'),
        content: ResponsiveText(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ResponsiveText('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: ResponsiveText(
              'Hesabı Sil',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutFromAllDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText('Tüm Cihazlardan Çıkış Yap'),
        content: ResponsiveText(
          'Tüm cihazlardan çıkış yapmak istediğinizden emin misiniz? Bu işlem tüm oturumlarınızı sonlandıracaktır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ResponsiveText('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await controller.signOutFromAllDevices();
                Get.snackbar(
                  'Başarılı',
                  'Tüm cihazlardan çıkış yapıldı',
                  backgroundColor: Colors.green.withOpacity(0.8),
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Hata',
                  'Çıkış yapılırken bir hata oluştu',
                  backgroundColor: Colors.red.withOpacity(0.8),
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: ResponsiveText(
              'Çıkış Yap',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

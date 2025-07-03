import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/location/map_controller.dart';

class LocationSettingsView extends GetView<MapController> {
  const LocationSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Ayarları'),
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
          'Konum İzinleri',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Konum Erişimi'),
          subtitle: const Text('Uygulamanın konumunuza erişmesine izin verin'),
          trailing: Obx(() {
            return Switch(
              value: controller.locationPermissionGranted.value,
              onChanged: controller.requestLocationPermission,
            );
          }),
        ),
        ListTile(
          title: const Text('Arka Planda Konum'),
          subtitle: const Text(
              'Uygulama arka plandayken konum güncellemelerine izin verin'),
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
          'Konum Takibi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Konum Güncellemeleri'),
          subtitle:
              const Text('Ne sıklıkta konum güncellemesi alınacağını seçin'),
          onTap: () => _showUpdateIntervalDialog(context),
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
          title: const Text('Pil Optimizasyonu'),
          subtitle: const Text(
              'Pil kullanımını optimize etmek için konum hassasiyetini ayarlayın'),
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
          'Bildirimler',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Yakındaki Etkinlikler'),
          subtitle: const Text('Yakınınızdaki etkinlikler için bildirim alın'),
          trailing: Obx(() {
            return Switch(
              value: controller.nearbyEventNotifications.value,
              onChanged: controller.toggleNearbyEventNotifications,
            );
          }),
        ),
        ListTile(
          title: const Text('Yakındaki Geliştiriciler'),
          subtitle:
              const Text('Yakınınızdaki geliştiriciler için bildirim alın'),
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
          'Gizlilik',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Konum Paylaşımı'),
          subtitle: const Text('Konumunuzu diğer kullanıcılarla paylaşın'),
          trailing: Obx(() {
            return Switch(
              value: controller.locationSharingEnabled.value,
              onChanged: controller.toggleLocationSharing,
            );
          }),
        ),
        ListTile(
          title: const Text('Konum Geçmişi'),
          subtitle: const Text('Konum geçmişinizi yönetin'),
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
        title: const Text('Güncelleme Sıklığı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('Yüksek (5 saniye)'),
              value: 5,
              groupValue: controller.updateInterval.value,
              onChanged: (value) {
                controller.updateInterval.value = value!;
                Get.back();
              },
            ),
            RadioListTile<int>(
              title: const Text('Normal (15 saniye)'),
              value: 15,
              groupValue: controller.updateInterval.value,
              onChanged: (value) {
                controller.updateInterval.value = value!;
                Get.back();
              },
            ),
            RadioListTile<int>(
              title: const Text('Düşük (30 saniye)'),
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
        title: const Text('Konum Hassasiyeti'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Yüksek Hassasiyet'),
              subtitle: const Text('Daha fazla pil kullanımı'),
              value: 'high',
              groupValue: controller.locationAccuracy.value,
              onChanged: (value) {
                controller.locationAccuracy.value = value!;
                Get.back();
              },
            ),
            RadioListTile<String>(
              title: const Text('Dengeli'),
              subtitle: const Text('Önerilen'),
              value: 'balanced',
              groupValue: controller.locationAccuracy.value,
              onChanged: (value) {
                controller.locationAccuracy.value = value!;
                Get.back();
              },
            ),
            RadioListTile<String>(
              title: const Text('Düşük Hassasiyet'),
              subtitle: const Text('Pil tasarrufu'),
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

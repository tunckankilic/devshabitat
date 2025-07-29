import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/controllers/app_controller.dart';

class AppInfoView extends GetView<AppController> {
  const AppInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appInfo),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getSystemInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final info = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                AppStrings.appVersion,
                [
                  _buildInfoTile(AppStrings.appVersion, info['version']),
                  _buildInfoTile(AppStrings.buildNumber, info['buildNumber']),
                  _buildInfoTile(AppStrings.packageName, info['packageName']),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                AppStrings.systemStatus,
                [
                  _buildInfoTile(
                      AppStrings.networkStatus,
                      controller.isOnline
                          ? AppStrings.online
                          : AppStrings.offline),
                  _buildInfoTile(
                      AppStrings.themeMode,
                      controller.isDarkMode
                          ? AppStrings.darkMode
                          : AppStrings.lightMode),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                AppStrings.deviceInfo,
                [
                  _buildInfoTile(AppStrings.operatingSystem, info['os']),
                  _buildInfoTile(AppStrings.deviceModel, info['model']),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Get.textTheme.titleMedium?.copyWith(
                color: Get.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          Text(
            value,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getSystemInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
    final info = <String, dynamic>{};

    info['version'] = packageInfo.version;
    info['buildNumber'] = packageInfo.buildNumber;
    info['packageName'] = packageInfo.packageName;

    if (GetPlatform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      info['os'] = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      info['model'] = iosInfo.model;
    } else if (GetPlatform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      info['os'] = 'Android ${androidInfo.version.release}';
      info['model'] = androidInfo.model;
    } else if (GetPlatform.isMacOS) {
      final macOsInfo = await deviceInfo.macOsInfo;
      info['os'] = '${macOsInfo.hostName} ${macOsInfo.osRelease}';
      info['model'] = macOsInfo.model;
    } else {
      info['os'] = 'Unknown';
      info['model'] = 'Unknown';
    }

    return info;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../controllers/network_controller.dart';
import '../base/base_view.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/animated_responsive_layout.dart';

class NetworkStatusView extends BaseView<NetworkController> {
  const NetworkStatusView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Bağlantı Durumu',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.checkConnection(),
          ),
        ],
      ),
      body: AnimatedResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(
                responsive.responsiveValue(mobile: 16, tablet: 20)),
            child: Column(
              children: [
                _buildConnectionStatusCard(context),
                SizedBox(
                    height: responsive.responsiveValue(mobile: 16, tablet: 20)),
                _buildConnectionTypeCard(context),
                SizedBox(
                    height: responsive.responsiveValue(mobile: 16, tablet: 20)),
                _buildNetworkStatsCard(context),
                SizedBox(
                    height: responsive.responsiveValue(mobile: 16, tablet: 20)),
                _buildTroubleshootingCard(context),
                SizedBox(
                    height: responsive.responsiveValue(mobile: 16, tablet: 20)),
                _buildSyncStatusCard(context),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(
                responsive.responsiveValue(mobile: 16, tablet: 20)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildConnectionStatusCard(context),
                      SizedBox(
                          height: responsive.responsiveValue(
                              mobile: 16, tablet: 20)),
                      _buildConnectionTypeCard(context),
                      SizedBox(
                          height: responsive.responsiveValue(
                              mobile: 16, tablet: 20)),
                      _buildNetworkStatsCard(context),
                    ],
                  ),
                ),
                SizedBox(
                    width: responsive.responsiveValue(mobile: 16, tablet: 20)),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildTroubleshootingCard(context),
                      SizedBox(
                          height: responsive.responsiveValue(
                              mobile: 16, tablet: 20)),
                      _buildSyncStatusCard(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatusCard(BuildContext context) {
    return _buildModernCard(
      title: 'Bağlantı Durumu',
      icon: Icons.wifi,
      color: Colors.blue,
      context: context,
      children: [
        Obx(() {
          final isConnected = controller.isConnected;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ResponsiveText(
                      isConnected ? 'Bağlı' : 'Bağlantı Yok',
                      style: TextStyle(
                        fontSize:
                            responsive.responsiveValue(mobile: 16, tablet: 18),
                        fontWeight: FontWeight.w600,
                        color: isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildStatusIndicator(isConnected),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildConnectionTypeCard(BuildContext context) {
    return _buildModernCard(
      title: 'Bağlantı Tipi',
      icon: Icons.network_check,
      color: Colors.orange,
      context: context,
      children: [
        Obx(() {
          final connectionType = controller.connectionType;
          return Column(
            children: [
              _buildConnectionTypeTile(
                'Wi-Fi',
                Icons.wifi,
                controller.isWifi(),
                Colors.blue,
              ),
              SizedBox(height: 8),
              _buildConnectionTypeTile(
                'Mobil Veri',
                Icons.cell_tower,
                controller.isMobile(),
                Colors.green,
              ),
              SizedBox(height: 8),
              _buildConnectionTypeTile(
                'Ethernet',
                Icons.router,
                controller.isEthernet(),
                Colors.purple,
              ),
              SizedBox(height: 8),
              _buildConnectionTypeTile(
                'Bağlantı Yok',
                Icons.signal_wifi_off,
                connectionType == ConnectivityResult.none,
                Colors.red,
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: ResponsiveText(
                        'Aktif Bağlantı: ${_getConnectionTypeText()}',
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                              mobile: 12, tablet: 14),
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildNetworkStatsCard(BuildContext context) {
    return _buildModernCard(
      title: 'Ağ İstatistikleri',
      icon: Icons.analytics,
      color: Colors.green,
      context: context,
      children: [
        Obx(() => _buildStatTile(
            'Son Kontrol',
            controller.lastTestTime.isEmpty
                ? DateTime.now().toString().substring(0, 19)
                : controller.lastTestTime)),
        Obx(() =>
            _buildStatTile('Bağlantı Kalitesi', controller.connectionQuality)),
        Obx(() => _buildStatTile('Gecikme Süresi', '${controller.latency}ms')),
        Obx(() => _buildStatTile('İndirme Hızı',
            '${controller.downloadSpeed.toStringAsFixed(1)} Mbps')),
        Obx(() => _buildStatTile('Yükleme Hızı',
            '${controller.uploadSpeed.toStringAsFixed(1)} Mbps')),
      ],
    );
  }

  Widget _buildTroubleshootingCard(BuildContext context) {
    return _buildModernCard(
      title: 'Sorun Giderme',
      icon: Icons.build,
      color: Colors.red,
      context: context,
      children: [
        Obx(() => _buildTroubleshootingButton(
              controller.isTesting ? 'Test Ediliyor...' : 'Bağlantıyı Test Et',
              controller.isTesting
                  ? Icons.hourglass_empty
                  : Icons.network_check,
              controller.isTesting ? () {} : () => _testConnection(),
            )),
        SizedBox(height: 8),
        _buildTroubleshootingButton(
          'DNS Ayarlarını Sıfırla',
          Icons.refresh,
          () => _resetDNS(),
        ),
        SizedBox(height: 8),
        _buildTroubleshootingButton(
          'Ağ Ayarlarını Yenile',
          Icons.settings_backup_restore,
          () => _refreshNetworkSettings(),
        ),
        SizedBox(height: 8),
        _buildTroubleshootingButton(
          'Detaylı Rapor Oluştur',
          Icons.assessment,
          () => _generateNetworkReport(),
        ),
      ],
    );
  }

  Widget _buildSyncStatusCard(BuildContext context) {
    return _buildModernCard(
      title: 'Senkronizasyon Durumu',
      icon: Icons.sync,
      color: Colors.purple,
      context: context,
      children: [
        Obx(() {
          final syncStatus = controller.syncStatus;
          return Column(
            children: [
              _buildSyncStatusTile(
                  'Mesajlar', syncStatus['Mesajlar'] ?? false, 'Son 5 dakika'),
              _buildSyncStatusTile('Profil Verileri',
                  syncStatus['Profil Verileri'] ?? false, 'Güncel'),
              _buildSyncStatusTile(
                  'Topluluk Verileri',
                  syncStatus['Topluluk Verileri'] ?? false,
                  'Senkronizasyon bekliyor'),
              _buildSyncStatusTile('Etkinlik Verileri',
                  syncStatus['Etkinlik Verileri'] ?? false, 'Son 10 dakika'),
              _buildSyncStatusTile('Dosya Yüklemeleri',
                  syncStatus['Dosya Yüklemeleri'] ?? false, 'Tamamlandı'),
            ],
          );
        }),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _forceSync(),
                icon: Icon(Icons.sync),
                label: ResponsiveText('Zorla Senkronize Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required BuildContext context,
    Color? color,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding:
            EdgeInsets.all(responsive.responsiveValue(mobile: 16, tablet: 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (color ?? Theme.of(context).primaryColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color ?? Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ResponsiveText(
                    title,
                    style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isConnected) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Expanded(
            flex: isConnected ? 1 : 0,
            child: Container(
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionTypeTile(
      String title, IconData icon, bool isActive, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? color : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? color : Colors.grey[600],
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: ResponsiveText(
              title,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? color : Colors.grey[600],
              ),
            ),
          ),
          if (isActive)
            Icon(
              Icons.check_circle,
              color: color,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ResponsiveText(
            title,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
              color: Colors.grey[600],
            ),
          ),
          ResponsiveText(
            value,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingButton(
      String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: ResponsiveText(
          title,
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.grey[800],
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusTile(String title, bool isSynced, String status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isSynced ? Icons.check_circle : Icons.schedule,
            color: isSynced ? Colors.green : Colors.orange,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: ResponsiveText(
              title,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ResponsiveText(
            status,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _testConnection() {
    controller.testConnection();
  }

  void _resetDNS() {
    controller.resetDNS();
  }

  void _refreshNetworkSettings() {
    controller.checkConnection();
    Get.snackbar(
      'Yenilendi',
      'Ağ ayarları yenilendi',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _generateNetworkReport() {
    final report = controller.generateNetworkReport();

    Get.dialog(
      AlertDialog(
        title: ResponsiveText('Ağ Raporu'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveText('Bağlantı Durumu: ${report['bağlantıDurumu']}'),
              ResponsiveText('Bağlantı Tipi: ${report['bağlantıTipi']}'),
              ResponsiveText('Test Tarihi: ${report['testTarihi']}'),
              ResponsiveText(
                  'Uygulama Versiyonu: ${report['uygulamaVersiyonu']}'),
              ResponsiveText('Platform: ${report['platform']}'),
              ResponsiveText(
                  'Bağlantı Kalitesi: ${report['bağlantıKalitesi']}'),
              ResponsiveText('Gecikme Süresi: ${report['gecikmeSüresi']}'),
              ResponsiveText('İndirme Hızı: ${report['indirmeHızı']}'),
              ResponsiveText('Yükleme Hızı: ${report['yüklemeHızı']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              // Raporu paylaş
              Get.back();
              Get.snackbar(
                'Paylaşıldı',
                'Ağ raporu paylaşıldı',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: ResponsiveText('Paylaş'),
          ),
        ],
      ),
    );
  }

  void _forceSync() {
    controller.forceSync();
  }

  String _getConnectionTypeText() {
    switch (controller.connectionType) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobil Veri';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'Bağlantı Yok';
      default:
        return 'Bilinmiyor';
    }
  }
}

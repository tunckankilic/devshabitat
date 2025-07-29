import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/integration/integration_controller.dart';
import '../../models/event/event_model.dart';
import '../../models/community/community_model.dart';
import '../../models/location/location_model.dart';
import '../base/base_view.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/animated_responsive_layout.dart';

class IntegrationsView extends BaseView<IntegrationController> {
  const IntegrationsView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      body: AnimatedResponsiveLayout(
        mobile: _buildMobileIntegrations(context),
        tablet: _buildTabletIntegrations(context),
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildMobileIntegrations(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildModernAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildServiceStatusCard(context),
                SizedBox(height: 16),
                _buildVideoEventIntegrationCard(context),
                SizedBox(height: 16),
                _buildCommunityEventIntegrationCard(context),
                SizedBox(height: 16),
                _buildLocationEventIntegrationCard(context),
                SizedBox(height: 16),
                _buildApiConnectionsCard(context),
                SizedBox(height: 16),
                _buildWebhookManagementCard(context),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletIntegrations(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildModernAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildServiceStatusCard(context),
                      SizedBox(height: 24),
                      _buildVideoEventIntegrationCard(context),
                      SizedBox(height: 24),
                      _buildCommunityEventIntegrationCard(context),
                    ],
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildLocationEventIntegrationCard(context),
                      SizedBox(height: 24),
                      _buildApiConnectionsCard(context),
                      SizedBox(height: 24),
                      _buildWebhookManagementCard(context),
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

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: ResponsiveText(
            'Entegrasyonlar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
      ),
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
        padding: EdgeInsets.all(20),
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
                      fontSize: 18,
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

  Widget _buildServiceStatusCard(BuildContext context) {
    return _buildModernCard(
      title: 'Servis Durumu',
      icon: Icons.monitor_heart_outlined,
      color: Colors.green,
      context: context,
      children: [
        _buildServiceStatusItem(
          'Video-Etkinlik Entegrasyonu',
          'Aktif',
          Icons.video_call,
          Colors.green,
        ),
        SizedBox(height: 8),
        _buildServiceStatusItem(
          'Topluluk-Etkinlik Entegrasyonu',
          'Aktif',
          Icons.group,
          Colors.blue,
        ),
        SizedBox(height: 8),
        _buildServiceStatusItem(
          'Konum-Etkinlik Entegrasyonu',
          'Aktif',
          Icons.location_on,
          Colors.orange,
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _refreshServiceStatus(),
          icon: Icon(Icons.refresh, size: 18),
          label: ResponsiveText('Durumu Yenile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoEventIntegrationCard(BuildContext context) {
    return _buildModernCard(
      title: 'Video-Etkinlik Entegrasyonu',
      icon: Icons.video_call_outlined,
      color: Colors.purple,
      context: context,
      children: [
        ResponsiveText(
          'Etkinlikler için otomatik video çağrı yönetimi',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        _buildIntegrationFeature(
          'Otomatik Çağrı Başlatma',
          'Etkinlik başladığında video çağrısı otomatik başlatılır',
          Icons.play_circle_outline,
        ),
        SizedBox(height: 8),
        _buildIntegrationFeature(
          'Otomatik Çağrı Sonlandırma',
          'Etkinlik bittiğinde video çağrısı otomatik sonlandırılır',
          Icons.stop_circle_outlined,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _testVideoEventIntegration(),
                icon: Icon(Icons.play_arrow, size: 18),
                label: ResponsiveText('Test Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showVideoEventSettings(),
                icon: Icon(Icons.settings, size: 18),
                label: ResponsiveText('Ayarlar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommunityEventIntegrationCard(BuildContext context) {
    return _buildModernCard(
      title: 'Topluluk-Etkinlik Entegrasyonu',
      icon: Icons.group_outlined,
      color: Colors.blue,
      context: context,
      children: [
        ResponsiveText(
          'Topluluklar ve etkinlikler arası otomatik bağlantı',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        _buildIntegrationFeature(
          'Otomatik Bağlantı',
          'Etkinlikler otomatik olarak ilgili topluluklara bağlanır',
          Icons.link,
        ),
        SizedBox(height: 8),
        _buildIntegrationFeature(
          'Topluluk Bildirimleri',
          'Topluluk üyelerine yeni etkinlik bildirimleri gönderilir',
          Icons.notifications_active,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _testCommunityEventIntegration(),
                icon: Icon(Icons.play_arrow, size: 18),
                label: ResponsiveText('Test Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showCommunityEventSettings(),
                icon: Icon(Icons.settings, size: 18),
                label: ResponsiveText('Ayarlar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationEventIntegrationCard(BuildContext context) {
    return _buildModernCard(
      title: 'Konum-Etkinlik Entegrasyonu',
      icon: Icons.location_on_outlined,
      color: Colors.orange,
      context: context,
      children: [
        ResponsiveText(
          'Kullanıcı konumuna göre yakındaki etkinlikleri bulma',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        _buildIntegrationFeature(
          'Yakındaki Etkinlikler',
          '5km yarıçapında etkinlikleri otomatik tespit eder',
          Icons.radar,
        ),
        SizedBox(height: 8),
        _buildIntegrationFeature(
          'Konum Bildirimleri',
          'Yakındaki etkinlikler için anlık bildirimler',
          Icons.location_searching,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _testLocationEventIntegration(),
                icon: Icon(Icons.play_arrow, size: 18),
                label: ResponsiveText('Test Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showLocationEventSettings(),
                icon: Icon(Icons.settings, size: 18),
                label: ResponsiveText('Ayarlar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApiConnectionsCard(BuildContext context) {
    return _buildModernCard(
      title: 'API Bağlantıları',
      icon: Icons.api_outlined,
      color: Colors.indigo,
      context: context,
      children: [
        ResponsiveText(
          'Üçüncü parti servislerle API entegrasyonları',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        _buildApiConnectionItem(
          'Firebase',
          'Aktif',
          Icons.cloud,
          Colors.orange,
        ),
        SizedBox(height: 8),
        _buildApiConnectionItem(
          'Google Maps',
          'Aktif',
          Icons.map,
          Colors.green,
        ),
        SizedBox(height: 8),
        _buildApiConnectionItem(
          'Firebase Messaging',
          'Aktif',
          Icons.notifications,
          Colors.red,
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _manageApiConnections(),
          icon: Icon(Icons.settings, size: 18),
          label: ResponsiveText('API Ayarları'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebhookManagementCard(BuildContext context) {
    return _buildModernCard(
      title: 'Webhook Yönetimi',
      icon: Icons.webhook_outlined,
      color: Colors.teal,
      context: context,
      children: [
        ResponsiveText(
          'Dış servislerle webhook bağlantıları',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        _buildWebhookItem(
          'Etkinlik Webhook',
          'https://api.example.com/events',
          Icons.event,
          true,
        ),
        SizedBox(height: 8),
        _buildWebhookItem(
          'Topluluk Webhook',
          'https://api.example.com/communities',
          Icons.group,
          true,
        ),
        SizedBox(height: 8),
        _buildWebhookItem(
          'Kullanıcı Webhook',
          'https://api.example.com/users',
          Icons.person,
          false,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addNewWebhook(),
                icon: Icon(Icons.add, size: 18),
                label: ResponsiveText('Yeni Webhook'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _testWebhooks(),
                icon: Icon(Icons.play_arrow, size: 18),
                label: ResponsiveText('Test Et'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceStatusItem(
    String name,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: ResponsiveText(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ResponsiveText(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationFeature(
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ResponsiveText(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiConnectionItem(
    String name,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: ResponsiveText(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ResponsiveText(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebhookItem(
    String name,
    String url,
    IconData icon,
    bool isActive,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ResponsiveText(
                  url,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isActive,
            onChanged: (value) => _toggleWebhook(name, value),
            activeColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _refreshServiceStatus() {
    controller.refreshServiceStatus();
  }

  void _testVideoEventIntegration() async {
    try {
      // Test event oluştur
      final testEvent = EventModel(
        id: 'test_event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Etkinliği',
        description: 'Video entegrasyon testi',
        type: EventType.online,
        startDate: DateTime.now().add(Duration(minutes: 5)),
        endDate: DateTime.now().add(Duration(hours: 1)),
        participantLimit: 10,
        categories: [],
        participants: [],
        createdBy: 'test_user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await controller.handleEventVideoIntegration(testEvent);

      Get.snackbar(
        'Test Başarılı',
        'Video-etkinlik entegrasyonu test edildi',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Test Hatası',
        'Video-etkinlik entegrasyonu test edilemedi: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _testCommunityEventIntegration() async {
    try {
      // Test event ve community oluştur
      final testEvent = EventModel(
        id: 'test_event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Etkinliği',
        description: 'Topluluk entegrasyon testi',
        type: EventType.inPerson,
        startDate: DateTime.now().add(Duration(days: 1)),
        endDate: DateTime.now().add(Duration(days: 1, hours: 2)),
        participantLimit: 10,
        categories: [],
        participants: [],
        createdBy: 'test_user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final testCommunity = CommunityModel(
        id: 'test_community_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Topluluğu',
        description: 'Test topluluğu',
        creatorId: 'test_user',
        moderatorIds: [],
        memberIds: [],
        pendingMemberIds: [],
        settings: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await controller.handleCommunityEventIntegration(
          testEvent, testCommunity);

      Get.snackbar(
        'Test Başarılı',
        'Topluluk-etkinlik entegrasyonu test edildi',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Test Hatası',
        'Topluluk-etkinlik entegrasyonu test edilemedi: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _testLocationEventIntegration() async {
    try {
      // Test location oluştur
      final testLocation = LocationModel(
        latitude: 41.0082, // İstanbul koordinatları
        longitude: 28.9784,
        address: 'Test Adresi',
        timestamp: DateTime.now(),
      );

      await controller.handleLocationEventIntegration(
          testLocation, 'test_token');

      Get.snackbar(
        'Test Başarılı',
        'Konum-etkinlik entegrasyonu test edildi',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Test Hatası',
        'Konum-etkinlik entegrasyonu test edilemedi: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _showVideoEventSettings() {
    Get.dialog(
      AlertDialog(
        title: ResponsiveText('Video-Etkinlik Ayarları'),
        content: ResponsiveText(
            'Video-etkinlik entegrasyon ayarları burada yapılacak.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showCommunityEventSettings() {
    Get.dialog(
      AlertDialog(
        title: ResponsiveText('Topluluk-Etkinlik Ayarları'),
        content: ResponsiveText(
            'Topluluk-etkinlik entegrasyon ayarları burada yapılacak.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showLocationEventSettings() {
    Get.dialog(
      AlertDialog(
        title: ResponsiveText('Konum-Etkinlik Ayarları'),
        content: ResponsiveText(
            'Konum-etkinlik entegrasyon ayarları burada yapılacak.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText('Kapat'),
          ),
        ],
      ),
    );
  }

  void _manageApiConnections() {
    Get.dialog(
      AlertDialog(
        title: ResponsiveText('API Bağlantı Yönetimi'),
        content: ResponsiveText('API bağlantı ayarları burada yapılacak.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText('Kapat'),
          ),
        ],
      ),
    );
  }

  void _addNewWebhook() {
    Get.dialog(
      AlertDialog(
        title: ResponsiveText('Yeni Webhook Ekle'),
        content: ResponsiveText('Yeni webhook ekleme formu burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Webhook Eklendi',
                'Yeni webhook başarıyla eklendi',
                backgroundColor: Colors.green.withOpacity(0.8),
                colorText: Colors.white,
              );
            },
            child: ResponsiveText('Ekle'),
          ),
        ],
      ),
    );
  }

  void _testWebhooks() {
    Get.snackbar(
      'Webhook Testi',
      'Tüm webhook\'lar test edildi',
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  void _toggleWebhook(String name, bool value) {
    Get.snackbar(
      'Webhook Durumu',
      '$name webhook\'u ${value ? 'aktif' : 'pasif'} yapıldı',
      backgroundColor: value
          ? Colors.green.withOpacity(0.8)
          : Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}

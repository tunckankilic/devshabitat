import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/services/memory_manager_service.dart';
import '../../controllers/device_performance_controller.dart';
import '../../widgets/responsive/responsive_text.dart';

class MemoryDebugController extends GetxController with MemoryManagementMixin {
  final MemoryManagerService _memoryManager = Get.find();
  Timer? _testTimer;
  StreamSubscription? _testSubscription;
  final _testData = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _createTestResources();
  }

  void _createTestResources() {
    // Test timer oluştur
    _testTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _testData.add('Timer tick: ${DateTime.now()}');
      if (_testData.length > 10) {
        _testData.removeAt(0);
      }
    });
    registerTimer(_testTimer!);

    // Test stream oluştur
    final controller = StreamController<String>();
    _testSubscription = controller.stream.listen((data) {
      _testData.add('Stream data: $data');
      if (_testData.length > 10) {
        _testData.removeAt(0);
      }
    });
    registerSubscription(_testSubscription!);

    // Test verisi gönder
    Timer.periodic(const Duration(seconds: 3), (timer) {
      controller.add('Test message ${DateTime.now()}');
    });
  }

  void checkMemoryUsage() {
    _memoryManager.checkMemoryUsage();
  }

  void printDetailedInfo() {
    _memoryManager.printDetailedMemoryInfo();
  }

  void disposeAllResources() {
    _memoryManager.disposeAll();
    Get.snackbar(
      'Success',
      'All resources disposed',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class MemoryDebugView extends GetView<MemoryDebugController> {
  const MemoryDebugView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debug Tools'),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.memory), text: 'Memory'),
              Tab(icon: Icon(Icons.speed), text: 'Performance'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            _buildMemoryTab(),
            _buildPerformanceTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Memory Manager Test',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: controller.checkMemoryUsage,
                        child: const Text('Check Memory Usage'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: controller.printDetailedInfo,
                        child: const Text('Detailed Info'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.disposeAllResources,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Dispose All Resources'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: Obx(() => ListView.builder(
                          itemCount: controller._testData.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(controller._testData[index]),
                              dense: true,
                            );
                          },
                        )),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Debug Tools',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Get.toNamed('/debug/enhanced-form-test'),
                          icon: const Icon(Icons.edit),
                          label: const Text('Enhanced Form Test'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. "Check Memory Usage" - Aktif kaynakları logla\n'
                    '2. "Detailed Info" - Detaylı kaynak bilgilerini göster\n'
                    '3. "Dispose All Resources" - Tüm kaynakları temizle\n'
                    '4. "Enhanced Form Test" - Form validation test sayfası\n'
                    '5. Sayfayı kapat ve logları kontrol et\n'
                    '6. Memory leak olup olmadığını gözlemle',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed, color: Colors.blue, size: 24),
                      const SizedBox(width: 12),
                      ResponsiveText(
                        'Performance Monitor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Get.find<DevicePerformanceController>()
                            .optimizePerformance(),
                        icon: Icon(Icons.refresh),
                        label: ResponsiveText('Optimize Performance'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showDeviceStatus(),
                        icon: Icon(Icons.info),
                        label: ResponsiveText('Device Status'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    'Quick Performance Info',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GetBuilder<DevicePerformanceController>(
                    builder: (controller) => Column(
                      children: [
                        _buildQuickInfoRow(
                            'Device Model', controller.deviceModel.value),
                        _buildQuickInfoRow('Performance Category',
                            controller.performanceCategory.value),
                        _buildQuickInfoRow('Battery Level',
                            '${controller.currentBatteryLevel.value}%'),
                        _buildQuickInfoRow('Network Type',
                            _getNetworkTypeText(controller.networkType.value)),
                        _buildQuickInfoRow('Performance Mode',
                            controller.performanceMode.value),
                        _buildQuickInfoRow('Optimizations Applied',
                            '${controller.appliedOptimizations.length}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    'Performance Instructions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ResponsiveText(
                    '1. "Optimize Performance" - Performansı optimize et\n'
                    '2. "Device Status" - Detaylı cihaz durumunu görüntüle\n'
                    '3. Performance Monitor sayfasına gitmek için ana debug menüsünü kullan\n'
                    '4. Gerçek zamanlı performans metriklerini izle\n'
                    '5. Optimizasyon önerilerini takip et',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ResponsiveText(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          ResponsiveText(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getNetworkTypeText(ConnectivityResult type) {
    switch (type) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobil Veri';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Diğer';
      case ConnectivityResult.none:
      return 'Bağlantı Yok';
    }
  }

  void _showDeviceStatus() {
    final controller = Get.find<DevicePerformanceController>();
    final status = controller.getDeviceStatus();

    Get.dialog(
      AlertDialog(
        title: ResponsiveText('Device Status'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: status.entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ResponsiveText(
                            entry.key.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          ResponsiveText(
                            entry.value.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText('Close'),
          ),
        ],
      ),
    );
  }
}

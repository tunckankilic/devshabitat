import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../core/services/memory_manager_service.dart';

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
  const MemoryDebugView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Manager Debug'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
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
                      '4. Sayfayı kapat ve logları kontrol et\n'
                      '5. Memory leak olup olmadığını gözlemle',
                      style: TextStyle(fontSize: 12),
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
}

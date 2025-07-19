import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/responsive_controller.dart';
import 'package:devshabitat/app/utils/performance_optimizer.dart';
import 'package:devshabitat/app/services/navigation_service.dart';
import 'package:devshabitat/app/controllers/navigation_controller.dart';
import 'package:devshabitat/app/views/main_wrapper.dart';

class PerformanceMonitor {
  static final Map<String, List<double>> _fpsHistory = {};
  static final Map<String, List<int>> _memoryHistory = {};
  static final Map<String, List<double>> _renderTimeHistory = {};

  static void startMonitoring(String testName) {
    _fpsHistory[testName] = [];
    _memoryHistory[testName] = [];
    _renderTimeHistory[testName] = [];
  }

  static void recordMetrics(
    String testName, {
    required double fps,
    required int memoryUsage,
    required double renderTime,
  }) {
    _fpsHistory[testName]?.add(fps);
    _memoryHistory[testName]?.add(memoryUsage);
    _renderTimeHistory[testName]?.add(renderTime);
  }

  static Map<String, dynamic> getTestResults(String testName) {
    final fpsList = _fpsHistory[testName] ?? [];
    final memoryList = _memoryHistory[testName] ?? [];
    final renderTimeList = _renderTimeHistory[testName] ?? [];

    return {
      'testName': testName,
      'avgFPS': fpsList.isEmpty
          ? 0
          : fpsList.reduce((a, b) => a + b) / fpsList.length,
      'minFPS': fpsList.isEmpty ? 0 : fpsList.reduce((a, b) => a < b ? a : b),
      'maxFPS': fpsList.isEmpty ? 0 : fpsList.reduce((a, b) => a > b ? a : b),
      'avgMemory': memoryList.isEmpty
          ? 0
          : memoryList.reduce((a, b) => a + b) / memoryList.length,
      'maxMemory':
          memoryList.isEmpty ? 0 : memoryList.reduce((a, b) => a > b ? a : b),
      'avgRenderTime': renderTimeList.isEmpty
          ? 0
          : renderTimeList.reduce((a, b) => a + b) / renderTimeList.length,
      'maxRenderTime': renderTimeList.isEmpty
          ? 0
          : renderTimeList.reduce((a, b) => a > b ? a : b),
    };
  }

  static void printTestReport(String testName) {
    final results = getTestResults(testName);
    print('''
=== Performance Test Report: $testName ===
Average FPS: ${results['avgFPS'].toStringAsFixed(2)}
FPS Range: ${results['minFPS'].toStringAsFixed(2)} - ${results['maxFPS'].toStringAsFixed(2)}
Average Memory: ${results['avgMemory']} KB
Peak Memory: ${results['maxMemory']} KB
Average Render Time: ${results['avgRenderTime'].toStringAsFixed(2)}ms
Max Render Time: ${results['maxRenderTime'].toStringAsFixed(2)}ms
==========================================
''');
  }

  static void clearHistory() {
    _fpsHistory.clear();
    _memoryHistory.clear();
    _renderTimeHistory.clear();
  }
}

class ResponsivePerformanceTester {
  static Future<void> testScreenSizePerformance(
    String screenSize,
    Size dimensions,
    Widget Function() widgetBuilder,
  ) async {
    final testName = '${screenSize}_performance_test';
    PerformanceMonitor.startMonitoring(testName);

    // Simulate different screen sizes and measure performance
    for (int i = 0; i < 10; i++) {
      final stopwatch = Stopwatch()..start();

      // Build widget and measure render time
      final widget = widgetBuilder();
      final renderTime = stopwatch.elapsedMilliseconds.toDouble();

      // Simulate FPS (60 FPS target)
      final fps = 60.0 - (renderTime / 16.67); // 16.67ms per frame at 60fps

      // Simulate memory usage
      final memoryUsage = (dimensions.width * dimensions.height * 4 / 1024)
          .round(); // 4 bytes per pixel

      PerformanceMonitor.recordMetrics(
        testName,
        fps: fps.clamp(0, 60),
        memoryUsage: memoryUsage,
        renderTime: renderTime,
      );

      await Future.delayed(Duration(milliseconds: 100));
    }

    PerformanceMonitor.printTestReport(testName);
  }

  static Future<void> testResponsiveBreakpoints() async {
    final breakpoints = [
      {'name': 'small_phone', 'size': Size(360, 640)},
      {'name': 'large_phone', 'size': Size(480, 800)},
      {'name': 'tablet', 'size': Size(768, 1024)},
      {'name': 'desktop', 'size': Size(1024, 768)},
      {'name': 'large_desktop', 'size': Size(1440, 900)},
    ];

    for (final breakpoint in breakpoints) {
      await testScreenSizePerformance(
        breakpoint['name'] as String,
        breakpoint['size'] as Size,
        () => _buildTestWidget(),
      );
    }
  }

  static Widget _buildTestWidget() {
    return GetMaterialApp(
      home: Builder(
        builder: (context) {
          Get.put(ResponsiveController());
          Get.put(NavigationService());
          Get.put(NavigationController(Get.find<NavigationService>()));
          return MainWrapper();
        },
      ),
    );
  }
}

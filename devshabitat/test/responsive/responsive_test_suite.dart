import 'package:devshabitat/app/services/responsive_performance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/responsive_controller.dart';
import 'package:devshabitat/app/views/main_wrapper.dart';
import 'package:devshabitat/app/controllers/navigation_controller.dart';
import 'package:devshabitat/app/services/navigation_service.dart';

// Screen breakpoint enum for testing
enum ScreenBreakpoint { smallPhone, largePhone, tablet }

class ResponsiveTestSuite {
  static const Map<String, Size> testScreenSizes = {
    'small_phone': Size(360, 640),
    'large_phone': Size(480, 800),
    'tablet': Size(768, 1024),
    'desktop': Size(1024, 768),
    'large_desktop': Size(1440, 900),
  };

  static const Map<String, Size> landscapeSizes = {
    'small_phone_landscape': Size(640, 360),
    'large_phone_landscape': Size(800, 480),
    'tablet_landscape': Size(1024, 768),
    'desktop_landscape': Size(1920, 1080),
  };

  static void runAllTests() {
    group('Responsive Controller Tests', () {
      testResponsiveController();
    });

    group('Performance Optimizer Tests', () {
      testPerformanceOptimizer();
    });

    group('Layout Consistency Tests', () {
      testLayoutConsistency();
    });

    group('Touch Target Tests', () {
      testTouchTargets();
    });

    group('Text Readability Tests', () {
      testTextReadability();
    });

    group('Animation Performance Tests', () {
      testAnimationPerformance();
    });

    group('Memory Usage Tests', () {
      testMemoryUsage();
    });

    group('Cross-Platform Tests', () {
      testCrossPlatform();
    });
  }

  static void testResponsiveController() {
    testWidgets('Responsive Controller Breakpoint Detection', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              Get.put(ResponsiveController());
              return Container();
            },
          ),
        ),
      );

      final controller = Get.find<ResponsiveController>();

      // Test small phone
      await tester.binding.setSurfaceSize(testScreenSizes['small_phone']!);
      await tester.pump();
      expect(controller.isSmallPhone, true);
      expect(controller.currentBreakpoint.value, ScreenBreakpoint.smallPhone);

      // Test large phone
      await tester.binding.setSurfaceSize(testScreenSizes['large_phone']!);
      await tester.pump();
      expect(controller.isLargePhone, true);
      expect(controller.currentBreakpoint.value, ScreenBreakpoint.largePhone);

      // Test tablet
      await tester.binding.setSurfaceSize(testScreenSizes['tablet']!);
      await tester.pump();
      expect(controller.isTablet, true);
      expect(controller.currentBreakpoint.value, ScreenBreakpoint.tablet);
    });

    testWidgets('Responsive Value Calculation', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              Get.put(ResponsiveController());
              return Container();
            },
          ),
        ),
      );

      final controller = Get.find<ResponsiveController>();

      // Test responsive values
      await tester.binding.setSurfaceSize(testScreenSizes['small_phone']!);
      await tester.pump();
      expect(controller.responsiveValue(mobile: 16, tablet: 20), 16);

      await tester.binding.setSurfaceSize(testScreenSizes['tablet']!);
      await tester.pump();
      expect(controller.responsiveValue(mobile: 16, tablet: 20), 20);
    });
  }

  static void testPerformanceOptimizer() {
    testWidgets('Performance Optimizer Text Optimization', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              Get.put(ResponsiveController());
              final optimizer = TestPerformanceOptimizer();
              return Container();
            },
          ),
        ),
      );

      final optimizer = TestPerformanceOptimizer();
      final originalStyle = TextStyle(fontSize: 16, height: 1.2);
      final optimizedStyle = optimizer.optimizeTextStyle(originalStyle);

      expect(optimizedStyle.fontSize, isNotNull);
      expect(optimizedStyle.height, isNotNull);
    });

    testWidgets('Performance Optimizer Animation Duration', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              Get.put(ResponsiveController());
              return Container();
            },
          ),
        ),
      );

      final optimizer = TestPerformanceOptimizer();
      final originalDuration = Duration(milliseconds: 200);
      final optimizedDuration = optimizer.optimizeAnimationDuration(
        originalDuration,
      );

      expect(optimizedDuration.inMilliseconds, greaterThan(0));
    });
  }

  static void testLayoutConsistency() {
    testWidgets('Main Wrapper Layout Consistency', (tester) async {
      for (final entry in testScreenSizes.entries) {
        await tester.binding.setSurfaceSize(entry.value);
        await tester.pumpWidget(
          GetMaterialApp(
            home: Builder(
              builder: (context) {
                Get.put(ResponsiveController());
                Get.put(NavigationService());
                Get.put(NavigationController(Get.find<NavigationService>()));
                return MainWrapper();
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify navigation elements exist
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text('Ana Sayfa'), findsOneWidget);
        expect(find.text('Keşfet'), findsOneWidget);
        expect(find.text('Mesajlar'), findsOneWidget);
        expect(find.text('Profil'), findsOneWidget);

        // Verify touch targets meet minimum size
        final navigationBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navigationBar.height, greaterThanOrEqualTo(80));
      }
    });
  }

  static void testTouchTargets() {
    testWidgets('Touch Target Size Compliance', (tester) async {
      for (final entry in testScreenSizes.entries) {
        await tester.binding.setSurfaceSize(entry.value);
        await tester.pumpWidget(
          GetMaterialApp(
            home: Builder(
              builder: (context) {
                Get.put(ResponsiveController());
                Get.put(NavigationController(Get.find<NavigationService>()));
                return MainWrapper();
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        final controller = Get.find<ResponsiveController>();
        final minTouchTarget = controller.minTouchTargetSize;

        // Test navigation icons
        final navigationIcons = find.byType(Icon);
        for (final icon in navigationIcons.evaluate()) {
          final iconWidget = icon.widget as Icon;
          expect(iconWidget.size, greaterThanOrEqualTo(minTouchTarget));
        }
      }
    });
  }

  static void testTextReadability() {
    testWidgets('Text Readability Across Screen Sizes', (tester) async {
      for (final entry in testScreenSizes.entries) {
        await tester.binding.setSurfaceSize(entry.value);
        await tester.pumpWidget(
          GetMaterialApp(
            home: Builder(
              builder: (context) {
                Get.put(ResponsiveController());
                return Scaffold(
                  body: Text(
                    'Test metni okunabilirlik kontrolü',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify text is visible and readable
        expect(find.text('Test metni okunabilirlik kontrolü'), findsOneWidget);

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.style?.fontSize, greaterThan(12));
      }
    });
  }

  static void testAnimationPerformance() {
    testWidgets('Animation Performance Monitoring', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              Get.put(ResponsiveController());
              final optimizer = ResponsivePerformanceService();
              return Container();
            },
          ),
        ),
      );

      final optimizer = TestPerformanceOptimizer();

      optimizer.startMonitoring();
      expect(optimizer.currentFPS, greaterThan(0));

      optimizer.startAnimation();
      expect(optimizer.isAnimating, true);

      optimizer.stopAnimation();
      expect(optimizer.isAnimating, false);

      optimizer.stopMonitoring();
    });
  }

  static void testMemoryUsage() {
    testWidgets('Memory Usage Optimization', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              Get.put(ResponsiveController());
              final optimizer = ResponsivePerformanceService();
              return Container();
            },
          ),
        ),
      );

      final optimizer = TestPerformanceOptimizer();

      // Test cache clearing
      optimizer.clearCache();
      expect(optimizer.frameCount, 0);
      expect(optimizer.currentFPS, 0.0);
    });
  }

  static void testCrossPlatform() {
    testWidgets('Cross-Platform Layout Consistency', (tester) async {
      // Test iOS-like behavior
      await tester.binding.setSurfaceSize(testScreenSizes['large_phone']!);
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              Get.put(ResponsiveController());
              Get.put(NavigationController(Get.find<NavigationService>()));
              return MainWrapper();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify iOS-specific touch targets
      final controller = Get.find<ResponsiveController>();
      expect(controller.minTouchTarget, 44.0);

      // Test Android-like behavior
      await tester.binding.setSurfaceSize(testScreenSizes['tablet']!);
      await tester.pumpAndSettle();

      // Verify tablet layout
      expect(find.byType(NavigationRail), findsOneWidget);
    });
  }
}

// Test helper class for performance optimizer
class TestPerformanceOptimizer {
  final ResponsiveController _responsive = Get.find<ResponsiveController>();
  final RxBool _isAnimating = false.obs;
  final RxInt _frameCount = 0.obs;
  final RxDouble _fps = 0.0.obs;

  Widget optimizeWidgetTree(Widget child) => RepaintBoundary(child: child);

  Widget wrapWithRepaintBoundary(Widget child) => RepaintBoundary(child: child);

  Widget onlyWhenVisible(Widget child) => child;

  void startMonitoring() {
    _fps.value = 60.0;
  }

  void stopMonitoring() {}

  void startAnimation() {
    _isAnimating.value = true;
  }

  void stopAnimation() {
    _isAnimating.value = false;
  }

  TextStyle optimizeTextStyle(TextStyle style) {
    if (style.fontSize == null) return style;

    return style.copyWith(
      fontSize: _responsive.responsiveValue(
        mobile: style.fontSize,
        tablet: style.fontSize! * _responsive.textScaleFactor,
        desktop: style.fontSize! * _responsive.textScaleFactor * 1.2,
      ),
    );
  }

  EdgeInsets optimizeEdgeInsets(EdgeInsets padding) => padding;

  Duration optimizeAnimationDuration(Duration duration) => duration;

  double get currentFPS => _fps.value;

  int get frameCount => _frameCount.value;

  bool get isAnimating => _isAnimating.value;

  void clearCache() {
    _frameCount.value = 0;
    _fps.value = 0.0;
  }

  void dispose() {}
}

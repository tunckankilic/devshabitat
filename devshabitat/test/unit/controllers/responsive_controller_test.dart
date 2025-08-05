import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:devshabitat/app/controllers/responsive_controller.dart';
import 'package:devshabitat/app/widgets/responsive/animated_responsive_wrapper.dart';
import '../../../test/test_helper.dart';

void main() {
  late ResponsiveController controller;

  setUp(() async {
    await setupTestEnvironment();
    controller = ResponsiveController();
  });

  tearDown(() {
    Get.reset();
  });

  group('ResponsiveController - Temel Fonksiyonlar', () {
    test('başlangıç değerleri doğru olmalı', () {
      expect(controller.currentBreakpoint.value, ScreenBreakpoint.compact);
      expect(controller.screenWidth.value, 0.0);
      expect(controller.screenHeight.value, 0.0);
      expect(controller.devicePixelRatio.value, 1.0);
      expect(controller.orientation.value, Orientation.portrait);
    });

    test('breakpoint değerleri doğru tanımlanmalı', () {
      expect(controller.smallPhoneBreakpoint, 360.0);
      expect(controller.largePhoneBreakpoint, 480.0);
      expect(controller.tabletBreakpoint, 768.0);
      expect(controller.desktopBreakpoint, 1024.0);
      expect(controller.largeDesktopBreakpoint, 1440.0);
    });

    test('minimum touch target boyutu doğru olmalı', () {
      expect(controller.minTouchTarget, 44.0);
    });
  });

  group('ResponsiveController - Breakpoint Hesaplamaları', () {
    test('küçük telefon breakpoint hesaplaması', () {
      controller.screenWidth.value = 320.0;

      expect(controller.isSmallPhone, true);
      expect(controller.isLargePhone, false);
      expect(controller.isTablet, false);
      expect(controller.isDesktop, false);
      expect(controller.isLargeDesktop, false);
      expect(controller.isMobile, true);
    });

    test('büyük telefon breakpoint hesaplaması', () {
      controller.screenWidth.value = 480.0;

      expect(controller.isSmallPhone, false);
      expect(controller.isLargePhone, true);
      expect(controller.isTablet, false);
      expect(controller.isDesktop, false);
      expect(controller.isLargeDesktop, false);
      expect(controller.isMobile, true);
    });

    test('tablet breakpoint hesaplaması', () {
      controller.screenWidth.value = 768.0;

      expect(controller.isSmallPhone, false);
      expect(controller.isLargePhone, false);
      expect(controller.isTablet, true);
      expect(controller.isDesktop, false);
      expect(controller.isLargeDesktop, false);
      expect(controller.isMobile, false);
    });

    test('desktop breakpoint hesaplaması', () {
      controller.screenWidth.value = 1024.0;

      expect(controller.isSmallPhone, false);
      expect(controller.isLargePhone, false);
      expect(controller.isTablet, false);
      expect(controller.isDesktop, true);
      expect(controller.isLargeDesktop, false);
      expect(controller.isMobile, false);
    });

    test('büyük desktop breakpoint hesaplaması', () {
      controller.screenWidth.value = 1440.0;

      expect(controller.isSmallPhone, false);
      expect(controller.isLargePhone, false);
      expect(controller.isTablet, false);
      expect(controller.isDesktop, false);
      expect(controller.isLargeDesktop, true);
      expect(controller.isMobile, false);
    });
  });

  group('ResponsiveController - Orientation Yönetimi', () {
    test('portrait orientation', () {
      controller.orientation.value = Orientation.portrait;

      expect(controller.isPortrait, true);
      expect(controller.isLandscape, false);
    });

    test('landscape orientation', () {
      controller.orientation.value = Orientation.landscape;

      expect(controller.isPortrait, false);
      expect(controller.isLandscape, true);
    });
  });

  group('ResponsiveController - Responsive Value Hesaplamaları', () {
    test('responsiveValue mobile için', () {
      controller.screenWidth.value = 320.0; // Küçük telefon

      final result = controller.responsiveValue(
        mobile: 'mobile',
        tablet: 'tablet',
        desktop: 'desktop',
        largeDesktop: 'largeDesktop',
      );

      expect(result, 'mobile');
    });

    test('responsiveValue tablet için', () {
      controller.screenWidth.value = 768.0; // Tablet

      final result = controller.responsiveValue(
        mobile: 'mobile',
        tablet: 'tablet',
        desktop: 'desktop',
        largeDesktop: 'largeDesktop',
      );

      expect(result, 'tablet');
    });

    test('responsiveValue desktop için', () {
      controller.screenWidth.value = 1024.0; // Desktop

      final result = controller.responsiveValue(
        mobile: 'mobile',
        tablet: 'tablet',
        desktop: 'desktop',
        largeDesktop: 'largeDesktop',
      );

      expect(result, 'desktop');
    });

    test('responsiveValue large desktop için', () {
      controller.screenWidth.value = 1440.0; // Büyük desktop

      final result = controller.responsiveValue(
        mobile: 'mobile',
        tablet: 'tablet',
        desktop: 'desktop',
        largeDesktop: 'largeDesktop',
      );

      expect(result, 'largeDesktop');
    });

    test('responsiveValue desktop null olduğunda', () {
      controller.screenWidth.value = 1024.0; // Desktop

      final result = controller.responsiveValue(
        mobile: 'mobile',
        tablet: 'tablet',
        // desktop: null, // Null
        largeDesktop: 'largeDesktop',
      );

      expect(result, 'tablet'); // Tablet değerini döndürmeli
    });
  });

  group('ResponsiveController - Responsive Padding Hesaplamaları', () {
    test('responsivePadding all parametresi ile', () {
      controller.screenWidth.value = 320.0; // Mobile

      final padding = controller.responsivePadding(all: 16.0);

      expect(padding.left, 16.0);
      expect(padding.top, 16.0);
      expect(padding.right, 16.0);
      expect(padding.bottom, 16.0);
    });

    test('responsivePadding tablet için all parametresi', () {
      controller.screenWidth.value = 768.0; // Tablet

      final padding = controller.responsivePadding(all: 16.0);

      expect(padding.left, 24.0); // 16 * 1.5
      expect(padding.top, 24.0);
      expect(padding.right, 24.0);
      expect(padding.bottom, 24.0);
    });

    test('responsivePadding desktop için all parametresi', () {
      controller.screenWidth.value = 1024.0; // Desktop

      final padding = controller.responsivePadding(all: 16.0);

      expect(padding.left, 32.0); // 16 * 2
      expect(padding.top, 32.0);
      expect(padding.right, 32.0);
      expect(padding.bottom, 32.0);
    });

    test('responsivePadding horizontal ve vertical parametreleri ile', () {
      controller.screenWidth.value = 320.0; // Mobile

      final padding = controller.responsivePadding(
        horizontal: 16.0,
        vertical: 8.0,
      );

      expect(padding.left, 16.0);
      expect(padding.top, 8.0);
      expect(padding.right, 16.0);
      expect(padding.bottom, 8.0);
    });

    test('responsivePadding bireysel parametreler ile', () {
      controller.screenWidth.value = 320.0; // Mobile

      final padding = controller.responsivePadding(
        left: 16.0,
        top: 8.0,
        right: 12.0,
        bottom: 4.0,
      );

      expect(padding.left, 16.0);
      expect(padding.top, 8.0);
      expect(padding.right, 12.0);
      expect(padding.bottom, 4.0);
    });
  });

  group('ResponsiveController - Scale Factor Hesaplamaları', () {
    test('textScaleFactor mobile için', () {
      controller.screenWidth.value = 320.0; // Mobile

      expect(controller.textScaleFactor, 1.0);
    });

    test('textScaleFactor tablet için', () {
      controller.screenWidth.value = 768.0; // Tablet

      expect(controller.textScaleFactor, 1.1);
    });

    test('textScaleFactor desktop için', () {
      controller.screenWidth.value = 1024.0; // Desktop

      expect(controller.textScaleFactor, 1.2);
    });

    test('textScaleFactor large desktop için', () {
      controller.screenWidth.value = 1440.0; // Large desktop

      expect(controller.textScaleFactor, 1.3);
    });

    test('iconScaleFactor mobile için', () {
      controller.screenWidth.value = 320.0; // Mobile

      expect(controller.iconScaleFactor, 1.0);
    });

    test('iconScaleFactor tablet için', () {
      controller.screenWidth.value = 768.0; // Tablet

      expect(controller.iconScaleFactor, 1.2);
    });

    test('iconScaleFactor desktop için', () {
      controller.screenWidth.value = 1024.0; // Desktop

      expect(controller.iconScaleFactor, 1.4);
    });

    test('iconScaleFactor large desktop için', () {
      controller.screenWidth.value = 1440.0; // Large desktop

      expect(controller.iconScaleFactor, 1.6);
    });
  });

  group('ResponsiveController - Touch Target Optimizasyonu', () {
    test('minTouchTargetSize mobile için', () {
      controller.screenWidth.value = 320.0; // Mobile

      expect(controller.minTouchTargetSize, 44.0);
    });

    test('minTouchTargetSize tablet için', () {
      controller.screenWidth.value = 768.0; // Tablet

      expect(controller.minTouchTargetSize, 52.8); // 44 * 1.2
    });

    test('minTouchTargetSize desktop için', () {
      controller.screenWidth.value = 1024.0; // Desktop

      expect(controller.minTouchTargetSize, 61.6); // 44 * 1.4
    });
  });

  group('ResponsiveController - Animation ve Layout', () {
    test('transitionDuration mobile için', () {
      controller.screenWidth.value = 320.0; // Mobile

      expect(controller.transitionDuration.inMilliseconds, 200);
    });

    test('transitionDuration tablet için', () {
      controller.screenWidth.value = 768.0; // Tablet

      expect(controller.transitionDuration.inMilliseconds, 250);
    });

    test('transitionDuration desktop için', () {
      controller.screenWidth.value = 1024.0; // Desktop

      expect(controller.transitionDuration.inMilliseconds, 300);
    });

    test('gridSpacing mobile için', () {
      controller.screenWidth.value = 320.0; // Mobile

      expect(controller.gridSpacing, 8.0);
    });

    test('gridSpacing tablet için', () {
      controller.screenWidth.value = 768.0; // Tablet

      expect(controller.gridSpacing, 16.0);
    });

    test('gridSpacing desktop için', () {
      controller.screenWidth.value = 1024.0; // Desktop

      expect(controller.gridSpacing, 24.0);
    });

    test('gridColumns mobile için', () {
      controller.screenWidth.value = 320.0; // Mobile

      expect(controller.gridColumns, 2);
    });

    test('gridColumns tablet için', () {
      controller.screenWidth.value = 768.0; // Tablet

      expect(controller.gridColumns, 3);
    });

    test('gridColumns desktop için', () {
      controller.screenWidth.value = 1024.0; // Desktop

      expect(controller.gridColumns, 4);
    });

    test('gridColumns large desktop için', () {
      controller.screenWidth.value = 1440.0; // Large desktop

      expect(controller.gridColumns, 6);
    });
  });

  group('ResponsiveController - Screen Metrics Güncellemeleri', () {
    test('screen metrics değişikliklerinde breakpoint güncellenmeli', () {
      controller.screenWidth.value = 320.0;
      expect(controller.currentBreakpoint.value, ScreenBreakpoint.compact);

      controller.screenWidth.value = 768.0;
      expect(controller.currentBreakpoint.value, ScreenBreakpoint.medium);

      controller.screenWidth.value = 1024.0;
      expect(
        controller.currentBreakpoint.value,
        ScreenBreakpoint.expanded,
      ); // Tablet breakpoint'e kadar
    });

    test('threshold değeri ile gereksiz güncellemeler önlenmeli', () {
      controller.screenWidth.value = 320.0;
      final initialBreakpoint = controller.currentBreakpoint.value;

      // Küçük değişiklik (threshold altında)
      controller.screenWidth.value = 324.0; // 4px değişiklik, threshold 5px

      // Breakpoint değişmemeli
      expect(controller.currentBreakpoint.value, initialBreakpoint);
    });
  });

  group('ResponsiveController - Edge Cases', () {
    test('çok küçük ekran boyutu', () {
      controller.screenWidth.value = 100.0;

      expect(controller.isSmallPhone, true);
      expect(controller.isMobile, true);
    });

    test('çok büyük ekran boyutu', () {
      controller.screenWidth.value = 2000.0;

      expect(controller.isLargeDesktop, true);
      expect(controller.isMobile, false);
    });

    test('sıfır ekran boyutu', () {
      controller.screenWidth.value = 0.0;

      expect(controller.isSmallPhone, true);
      expect(controller.isMobile, true);
    });

    test('negatif ekran boyutu', () {
      controller.screenWidth.value = -100.0;

      expect(controller.isSmallPhone, true);
      expect(controller.isMobile, true);
    });
  });

  group('ResponsiveController - Performans Testleri', () {
    test('çoklu breakpoint değişiklikleri performanslı olmalı', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        controller.screenWidth.value = 320.0 + (i * 10);
        controller.responsiveValue(
          mobile: 'mobile',
          tablet: 'tablet',
          desktop: 'desktop',
        );
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('responsive padding hesaplamaları performanslı olmalı', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        controller.responsivePadding(all: 16.0);
        controller.responsivePadding(horizontal: 16.0, vertical: 8.0);
        controller.responsivePadding(
          left: 16.0,
          top: 8.0,
          right: 12.0,
          bottom: 4.0,
        );
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}

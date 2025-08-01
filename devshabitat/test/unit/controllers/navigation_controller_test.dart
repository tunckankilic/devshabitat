// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:devshabitat/app/controllers/navigation_controller.dart';
import 'package:devshabitat/app/services/navigation_service.dart';
import '../../../test/test_helper.dart';

@GenerateNiceMocks([MockSpec<NavigationService>()])
import 'navigation_controller_test.mocks.dart';

void main() {
  late NavigationController controller;
  late MockNavigationService mockNavigationService;

  setUp(() async {
    await setupTestEnvironment();
    mockNavigationService = MockNavigationService();
    controller = NavigationController(mockNavigationService);
  });

  tearDown(() {
    Get.reset();
  });

  group('NavigationController - Temel Fonksiyonlar', () {
    test('başlangıç değerleri doğru olmalı', () {
      expect(controller.currentIndex.value, 0);
    });

    test('changePage index değişikliği', () {
      controller.changePage(1);
      expect(controller.currentIndex.value, 1);

      controller.changePage(2);
      expect(controller.currentIndex.value, 2);

      controller.changePage(0);
      expect(controller.currentIndex.value, 0);
    });
  });

  group('NavigationController - Sayfa Navigasyonu', () {
    test('navigateToPage başarılı durumda', () async {
      when(mockNavigationService.navigateTo(any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await controller.navigateToPage('/home');

      verify(mockNavigationService.navigateTo('/home', arguments: null))
          .called(1);
    });

    test('navigateToPage arguments ile', () async {
      when(mockNavigationService.navigateTo(any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      final arguments = {'id': '123', 'title': 'Test'};
      await controller.navigateToPage('/detail', arguments: arguments);

      verify(mockNavigationService.navigateTo('/detail', arguments: arguments))
          .called(1);
    });

    test('navigateToPage hata durumunda', () async {
      when(mockNavigationService.navigateTo(any,
              arguments: anyNamed('arguments')))
          .thenThrow(Exception('Navigation hatası'));

      expect(() => controller.navigateToPage('/error'), throwsException);
    });

    test('navigateToPage boş route ile', () async {
      expect(
          () => controller.navigateToPage(''), throwsA(isA<ArgumentError>()));
    });
  });

  group('NavigationController - Geri Gitme', () {
    test('goBack başarılı durumda', () {
      when(mockNavigationService.goBack()).thenReturn(null);

      controller.goBack();

      verify(mockNavigationService.goBack()).called(1);
    });

    test('goBack hata durumunda', () {
      when(mockNavigationService.goBack())
          .thenThrow(Exception('Geri gitme hatası'));

      expect(() => controller.goBack(), throwsException);
    });
  });

  group('NavigationController - Navigate To And Remove Until', () {
    test('navigateToAndRemoveUntil başarılı durumda', () async {
      when(mockNavigationService.navigateToAndRemoveUntil(any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await controller.navigateToAndRemoveUntil('/home');

      verify(mockNavigationService.navigateToAndRemoveUntil('/home',
              arguments: null))
          .called(1);
    });

    test('navigateToAndRemoveUntil arguments ile', () async {
      when(mockNavigationService.navigateToAndRemoveUntil(any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      final arguments = {'clear': true};
      await controller.navigateToAndRemoveUntil('/login', arguments: arguments);

      verify(mockNavigationService.navigateToAndRemoveUntil('/login',
              arguments: arguments))
          .called(1);
    });

    test('navigateToAndRemoveUntil hata durumunda', () async {
      when(mockNavigationService.navigateToAndRemoveUntil(any,
              arguments: anyNamed('arguments')))
          .thenThrow(Exception('Navigation hatası'));

      expect(
          () => controller.navigateToAndRemoveUntil('/error'), throwsException);
    });
  });

  group('NavigationController - Navigate To And Replace', () {
    test('navigateToAndReplace başarılı durumda', () async {
      when(mockNavigationService.navigateToAndReplace(any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await controller.navigateToAndReplace('/new-page');

      verify(mockNavigationService.navigateToAndReplace('/new-page',
              arguments: null))
          .called(1);
    });

    test('navigateToAndReplace arguments ile', () async {
      when(mockNavigationService.navigateToAndReplace(any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      final arguments = {'replace': true};
      await controller.navigateToAndReplace('/replacement',
          arguments: arguments);

      verify(mockNavigationService.navigateToAndReplace('/replacement',
              arguments: arguments))
          .called(1);
    });

    test('navigateToAndReplace hata durumunda', () async {
      when(mockNavigationService.navigateToAndReplace(any,
              arguments: anyNamed('arguments')))
          .thenThrow(Exception('Replace hatası'));

      expect(() => controller.navigateToAndReplace('/error'), throwsException);
    });
  });

  group('NavigationController - Pop Until', () {
    test('popUntil başarılı durumda', () {
      when(mockNavigationService.popUntil(any)).thenReturn(null);

      controller.popUntil('/home');

      verify(mockNavigationService.popUntil('/home')).called(1);
    });

    test('popUntil hata durumunda', () {
      when(mockNavigationService.popUntil(any))
          .thenThrow(Exception('Pop until hatası'));

      expect(() => controller.popUntil('/error'), throwsException);
    });

    test('popUntil boş route ile', () {
      expect(() => controller.popUntil(''), throwsA(isA<ArgumentError>()));
    });
  });

  group('NavigationController - Custom Dialog', () {
    test('showCustomDialog başarılı durumda', () async {
      final testWidget = Container(child: Text('Test Dialog'));
      when(mockNavigationService.showCustomDialog(
        child: anyNamed('child'),
        barrierDismissible: anyNamed('barrierDismissible'),
      )).thenAnswer((_) async => 'dialog_result');

      final result = await controller.showCustomDialog<String>(
        child: testWidget,
        barrierDismissible: true,
      );

      expect(result, 'dialog_result');
      verify(mockNavigationService.showCustomDialog(
        child: testWidget,
        barrierDismissible: true,
      )).called(1);
    });

    test('showCustomDialog barrierDismissible false ile', () async {
      final testWidget = Container(child: Text('Test Dialog'));
      when(mockNavigationService.showCustomDialog(
        child: anyNamed('child'),
        barrierDismissible: anyNamed('barrierDismissible'),
      )).thenAnswer((_) async => null);

      await controller.showCustomDialog(
        child: testWidget,
        barrierDismissible: false,
      );

      verify(mockNavigationService.showCustomDialog(
        child: testWidget,
        barrierDismissible: false,
      )).called(1);
    });

    test('showCustomDialog hata durumunda', () async {
      final testWidget = Container(child: Text('Test Dialog'));
      when(mockNavigationService.showCustomDialog(
        child: anyNamed('child'),
        barrierDismissible: anyNamed('barrierDismissible'),
      )).thenThrow(Exception('Dialog hatası'));

      expect(() => controller.showCustomDialog(child: testWidget),
          throwsException);
    });

    test('showCustomDialog boş child ile', () async {
      expect(() => controller.showCustomDialog(child: Container()),
          returnsNormally);
    });
  });

  group('NavigationController - Custom Bottom Sheet', () {
    test('showCustomBottomSheet başarılı durumda', () async {
      final testWidget = Container(child: Text('Test Bottom Sheet'));
      when(mockNavigationService.showCustomBottomSheet(
        child: anyNamed('child'),
        isDismissible: anyNamed('isDismissible'),
        enableDrag: anyNamed('enableDrag'),
        backgroundColor: anyNamed('backgroundColor'),
      )).thenAnswer((_) async => 'bottom_sheet_result');

      final result = await controller.showCustomBottomSheet<String>(
        child: testWidget,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.white,
      );

      expect(result, 'bottom_sheet_result');
      verify(mockNavigationService.showCustomBottomSheet(
        child: testWidget,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.white,
      )).called(1);
    });

    test('showCustomBottomSheet varsayılan parametreler ile', () async {
      final testWidget = Container(child: Text('Test Bottom Sheet'));
      when(mockNavigationService.showCustomBottomSheet(
        child: anyNamed('child'),
        isDismissible: anyNamed('isDismissible'),
        enableDrag: anyNamed('enableDrag'),
        backgroundColor: anyNamed('backgroundColor'),
      )).thenAnswer((_) async => null);

      await controller.showCustomBottomSheet(child: testWidget);

      verify(mockNavigationService.showCustomBottomSheet(
        child: testWidget,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: null,
      )).called(1);
    });

    test('showCustomBottomSheet özel parametreler ile', () async {
      final testWidget = Container(child: Text('Test Bottom Sheet'));
      when(mockNavigationService.showCustomBottomSheet(
        child: anyNamed('child'),
        isDismissible: anyNamed('isDismissible'),
        enableDrag: anyNamed('enableDrag'),
        backgroundColor: anyNamed('backgroundColor'),
      )).thenAnswer((_) async => null);

      await controller.showCustomBottomSheet(
        child: testWidget,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.black,
      );

      verify(mockNavigationService.showCustomBottomSheet(
        child: testWidget,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.black,
      )).called(1);
    });

    test('showCustomBottomSheet hata durumunda', () async {
      final testWidget = Container(child: Text('Test Bottom Sheet'));
      when(mockNavigationService.showCustomBottomSheet(
        child: anyNamed('child'),
        isDismissible: anyNamed('isDismissible'),
        enableDrag: anyNamed('enableDrag'),
        backgroundColor: anyNamed('backgroundColor'),
      )).thenThrow(Exception('Bottom sheet hatası'));

      expect(() => controller.showCustomBottomSheet(child: testWidget),
          throwsException);
    });

    test('showCustomBottomSheet boş child ile', () async {
      expect(() => controller.showCustomBottomSheet(child: Container()),
          returnsNormally);
    });
  });

  group('NavigationController - State Management', () {
    test('currentIndex değişikliklerini izleme', () {
      int callCount = 0;
      controller.currentIndex.listen((index) {
        callCount++;
        expect(index, isA<int>());
      });

      controller.changePage(1);
      controller.changePage(2);
      controller.changePage(0);

      expect(callCount, 3);
    });

    test('aynı index değişikliği tekrar çağrılmamalı', () {
      int callCount = 0;
      controller.currentIndex.listen((index) {
        callCount++;
      });

      controller.changePage(1);
      controller.changePage(1); // Aynı index
      controller.changePage(2);

      expect(callCount, 2); // Sadece farklı değerler için çağrılmalı
    });
  });

  group('NavigationController - Edge Cases', () {
    test('negatif index değişikliği', () {
      expect(() => controller.changePage(-1), returnsNormally);
      expect(controller.currentIndex.value, -1);
    });

    test('çok büyük index değişikliği', () {
      expect(() => controller.changePage(999999), returnsNormally);
      expect(controller.currentIndex.value, 999999);
    });

    test('boş route string', () async {
      when(mockNavigationService.navigateTo(any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await controller.navigateToPage('');

      verify(mockNavigationService.navigateTo('', arguments: null)).called(1);
    });

    test('çok uzun route string', () async {
      final longRoute = '/${'a' * 1000}';
      when(mockNavigationService.navigateTo(any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await controller.navigateToPage(longRoute);

      verify(mockNavigationService.navigateTo(longRoute, arguments: null))
          .called(1);
    });
  });

  group('NavigationController - Performans Testleri', () {
    test('çoklu navigasyon işlemleri performanslı olmalı', () async {
      when(mockNavigationService.navigateTo(any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        await controller.navigateToPage('/page_$i');
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('çoklu index değişiklikleri performanslı olmalı', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        controller.changePage(i % 5);
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('NavigationController - Error Handling', () {
    test('navigation service geçersiz olduğunda', () {
      expect(
          () => NavigationController(mockNavigationService), returnsNormally);
    });

    test('navigation service dispose edildiğinde', () async {
      when(mockNavigationService.navigateTo(any,
              arguments: anyNamed('arguments')))
          .thenThrow(StateError('Service disposed'));

      expect(
          () => controller.navigateToPage('/test'), throwsA(isA<StateError>()));
    });
  });
}

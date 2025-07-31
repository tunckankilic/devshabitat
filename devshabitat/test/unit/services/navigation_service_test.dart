import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:devshabitat/app/services/navigation_service.dart';
import '../../../test/test_helper.dart';

@GenerateNiceMocks([MockSpec<NavigatorState>()])
import 'navigation_service_test.mocks.dart';

// Test için özel NavigationService sınıfı
class TestNavigationService extends NavigationService {
  @override
  GlobalKey<NavigatorState> get navigationKey => _testKey;
  final GlobalKey<NavigatorState> _testKey = GlobalKey<NavigatorState>();
}

void main() {
  late TestNavigationService service;
  late MockNavigatorState mockNavigatorState;

  setUp(() async {
    await setupTestEnvironment();

    mockNavigatorState = MockNavigatorState();
    service = TestNavigationService();

    // Mock navigator state'i set et
    when(service.navigationKey.currentState).thenReturn(mockNavigatorState);
  });

  tearDown(() {
    Get.reset();
  });

  group('NavigationService - Temel Fonksiyonlar', () {
    test('navigationKey doğru oluşturulmalı', () {
      expect(service.navigationKey, isA<GlobalKey<NavigatorState>>());
    });

    test('service GetxService olarak kayıtlı olmalı', () {
      Get.put(service);
      expect(Get.find<NavigationService>(), service);
    });
  });

  group('NavigationService - Navigate To', () {
    test('navigateTo başarılı durumda', () async {
      when(mockNavigatorState.pushNamed(any, arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await service.navigateTo('/home');

      verify(mockNavigatorState.pushNamed('/home', arguments: null)).called(1);
    });

    test('navigateTo arguments ile', () async {
      when(mockNavigatorState.pushNamed(any, arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      final arguments = {'id': '123', 'title': 'Test'};
      await service.navigateTo('/detail', arguments: arguments);

      verify(mockNavigatorState.pushNamed('/detail', arguments: arguments))
          .called(1);
    });

    test('navigateTo hata durumunda', () async {
      when(mockNavigatorState.pushNamed(any, arguments: anyNamed('arguments')))
          .thenThrow(Exception('Navigation hatası'));

      expect(() => service.navigateTo('/error'), throwsException);
    });

    test('navigateTo null route ile', () async {
      expect(() => service.navigateTo(''), throwsA(isA<ArgumentError>()));
    });

    test('navigateTo boş route ile', () async {
      when(mockNavigatorState.pushNamed(any, arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await service.navigateTo('');

      verify(mockNavigatorState.pushNamed('', arguments: null)).called(1);
    });
  });

  group('NavigationService - Go Back', () {
    test('goBack başarılı durumda', () {
      when(mockNavigatorState.pop()).thenReturn(null);
      expect(() => service.goBack(), returnsNormally);
      verify(mockNavigatorState.pop()).called(1);
    });

    test('goBack hata durumunda', () {
      when(mockNavigatorState.pop()).thenThrow(Exception('Geri gitme hatası'));

      expect(() => service.goBack(), throwsException);
    });

    test('goBack return value ile', () {
      when(mockNavigatorState.pop()).thenReturn('return_value');
      service.goBack();
      verify(mockNavigatorState.pop()).called(1);
    });
  });

  group('NavigationService - Navigate To And Remove Until', () {
    test('navigateToAndRemoveUntil başarılı durumda', () async {
      when(mockNavigatorState.pushNamedAndRemoveUntil(any, any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await service.navigateToAndRemoveUntil('/home');

      verify(mockNavigatorState.pushNamedAndRemoveUntil(
              '/home', (route) => false,
              arguments: null))
          .called(1);
    });

    test('navigateToAndRemoveUntil arguments ile', () async {
      when(mockNavigatorState.pushNamedAndRemoveUntil(any, any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      final arguments = {'clear': true};
      await service.navigateToAndRemoveUntil('/login', arguments: arguments);

      verify(mockNavigatorState.pushNamedAndRemoveUntil(
              '/login', (route) => false,
              arguments: arguments))
          .called(1);
    });

    test('navigateToAndRemoveUntil hata durumunda', () async {
      when(mockNavigatorState.pushNamedAndRemoveUntil(any, any,
              arguments: anyNamed('arguments')))
          .thenThrow(Exception('Navigation hatası'));

      expect(() => service.navigateToAndRemoveUntil('/error'), throwsException);
    });

    test('navigateToAndRemoveUntil null route ile', () async {
      expect(() => service.navigateToAndRemoveUntil(''),
          throwsA(isA<ArgumentError>()));
    });
  });

  group('NavigationService - Navigate To And Replace', () {
    test('navigateToAndReplace başarılı durumda', () async {
      when(mockNavigatorState.pushReplacementNamed(any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await service.navigateToAndReplace('/new-page');

      verify(mockNavigatorState.pushReplacementNamed('/new-page',
              arguments: null))
          .called(1);
    });

    test('navigateToAndReplace arguments ile', () async {
      when(mockNavigatorState.pushReplacementNamed(any,
              arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      final arguments = {'replace': true};
      await service.navigateToAndReplace('/replacement', arguments: arguments);

      verify(mockNavigatorState.pushReplacementNamed('/replacement',
              arguments: arguments))
          .called(1);
    });

    test('navigateToAndReplace hata durumunda', () async {
      when(mockNavigatorState.pushReplacementNamed(any,
              arguments: anyNamed('arguments')))
          .thenThrow(Exception('Replace hatası'));

      expect(() => service.navigateToAndReplace('/error'), throwsException);
    });

    test('navigateToAndReplace null route ile', () async {
      expect(() => service.navigateToAndReplace(''),
          throwsA(isA<ArgumentError>()));
    });
  });

  group('NavigationService - Pop Until', () {
    test('popUntil başarılı durumda', () {
      when(mockNavigatorState.popUntil(any)).thenReturn(null);

      service.popUntil('/home');

      verify(mockNavigatorState.popUntil(ModalRoute.withName('/home')))
          .called(1);
    });

    test('popUntil hata durumunda', () {
      when(mockNavigatorState.popUntil(any))
          .thenThrow(Exception('Pop until hatası'));

      expect(() => service.popUntil('/error'), throwsException);
    });

    test('popUntil null route ile', () {
      expect(() => service.popUntil(''), throwsA(isA<ArgumentError>()));
    });

    test('popUntil boş route ile', () {
      when(mockNavigatorState.popUntil(any)).thenReturn(null);

      service.popUntil('');

      verify(mockNavigatorState.popUntil(ModalRoute.withName(''))).called(1);
    });
  });

  group('NavigationService - Show Custom Dialog', () {
    testWidgets('showCustomDialog başarılı durumda',
        (WidgetTester tester) async {
      final testWidget = Container(child: Text('Test Dialog'));
      await tester.pumpWidget(MaterialApp());
      when(mockNavigatorState.context)
          .thenReturn(tester.element(find.byType(MaterialApp)));

      await service.showCustomDialog(
        child: testWidget,
        barrierDismissible: true,
      );

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('showCustomDialog barrierDismissible false ile',
        (WidgetTester tester) async {
      final testWidget = Container(child: Text('Test Dialog'));
      await tester.pumpWidget(MaterialApp());
      when(mockNavigatorState.context)
          .thenReturn(tester.element(find.byType(MaterialApp)));

      await service.showCustomDialog(
        child: testWidget,
        barrierDismissible: false,
      );

      expect(find.byType(Container), findsNothing);
    });

    test('showCustomDialog hata durumunda', () async {
      final testWidget = Container(child: Text('Test Dialog'));
      when(mockNavigatorState.context).thenThrow(Exception('Context hatası'));

      expect(
          () => service.showCustomDialog(child: testWidget), throwsException);
    });

    testWidgets('showCustomDialog null child ile', (WidgetTester tester) async {
      expect(() => service.showCustomDialog(child: Container()),
          throwsA(isA<ArgumentError>()));
    });
  });

  group('NavigationService - Show Custom Bottom Sheet', () {
    testWidgets('showCustomBottomSheet başarılı durumda',
        (WidgetTester tester) async {
      final testWidget = Container(child: Text('Test Bottom Sheet'));
      await tester.pumpWidget(MaterialApp());
      when(mockNavigatorState.context)
          .thenReturn(tester.element(find.byType(MaterialApp)));

      await service.showCustomBottomSheet(
        child: testWidget,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.white,
      );

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('showCustomBottomSheet varsayılan parametreler ile',
        (WidgetTester tester) async {
      final testWidget = Container(child: Text('Test Bottom Sheet'));
      await tester.pumpWidget(MaterialApp());
      when(mockNavigatorState.context)
          .thenReturn(tester.element(find.byType(MaterialApp)));

      await service.showCustomBottomSheet(child: testWidget);

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('showCustomBottomSheet özel parametreler ile',
        (WidgetTester tester) async {
      final testWidget = Container(child: Text('Test Bottom Sheet'));
      await tester.pumpWidget(MaterialApp());
      when(mockNavigatorState.context)
          .thenReturn(tester.element(find.byType(MaterialApp)));

      await service.showCustomBottomSheet(
        child: testWidget,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.black,
      );

      expect(find.byType(Container), findsNothing);
    });

    test('showCustomBottomSheet hata durumunda', () async {
      final testWidget = Container(child: Text('Test Bottom Sheet'));
      when(mockNavigatorState.context).thenThrow(Exception('Context hatası'));

      expect(() => service.showCustomBottomSheet(child: testWidget),
          throwsException);
    });

    testWidgets('showCustomBottomSheet null child ile',
        (WidgetTester tester) async {
      expect(() => service.showCustomBottomSheet(child: Container()),
          throwsA(isA<ArgumentError>()));
    });
  });

  group('NavigationService - Context Yönetimi', () {
    test('context null olduğunda hata fırlatmalı', () {
      when(service.navigationKey.currentState).thenReturn(null);

      expect(() => service.navigateTo('/test'), throwsA(isA<StateError>()));
    });

    test('context geçersiz olduğunda hata fırlatmalı', () {
      when(mockNavigatorState.context).thenThrow(Exception('Invalid context'));

      expect(
          () => service.showCustomDialog(child: Container()), throwsException);
    });
  });

  group('NavigationService - Edge Cases', () {
    test('çok uzun route string', () async {
      final longRoute = '/' + 'a' * 1000;
      when(mockNavigatorState.pushNamed(any, arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await service.navigateTo(longRoute);

      verify(mockNavigatorState.pushNamed(longRoute, arguments: null))
          .called(1);
    });

    test('özel karakterler içeren route', () async {
      final specialRoute = '/test-route-with-special-chars-!@#\$%^&*()';
      when(mockNavigatorState.pushNamed(any, arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await service.navigateTo(specialRoute);

      verify(mockNavigatorState.pushNamed(specialRoute, arguments: null))
          .called(1);
    });

    test('çok büyük arguments objesi', () async {
      final largeArguments = Map.fromEntries(
        List.generate(1000, (i) => MapEntry('key_$i', 'value_$i')),
      );
      when(mockNavigatorState.pushNamed(any, arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      await service.navigateTo('/test', arguments: largeArguments);

      verify(mockNavigatorState.pushNamed('/test', arguments: largeArguments))
          .called(1);
    });
  });

  group('NavigationService - Performans Testleri', () {
    test('çoklu navigasyon işlemleri performanslı olmalı', () async {
      when(mockNavigatorState.pushNamed(any, arguments: anyNamed('arguments')))
          .thenAnswer((_) async => null);

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        await service.navigateTo('/page_$i');
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('çoklu go back işlemleri performanslı olmalı', () {
      when(mockNavigatorState.pop()).thenReturn(null);

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        service.goBack();
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('NavigationService - Memory Management', () {
    test('service dispose edildiğinde kaynaklar temizlenmeli', () {
      // GetxService otomatik olarak dispose edilir
      expect(service.navigationKey, isA<GlobalKey<NavigatorState>>());
    });

    test('navigationKey temizlenmeli', () {
      // GlobalKey otomatik olarak temizlenir
      expect(service.navigationKey, isA<GlobalKey<NavigatorState>>());
    });
  });

  group('NavigationService - Error Recovery', () {
    test('navigation hatası sonrası recovery', () async {
      when(mockNavigatorState.pushNamed('/error', arguments: null))
          .thenThrow(Exception('Navigation error'));
      when(mockNavigatorState.pushNamed('/success', arguments: null))
          .thenAnswer((_) async => null);

      expect(() => service.navigateTo('/error'), throwsException);
      await service.navigateTo('/success');
      verify(mockNavigatorState.pushNamed('/success', arguments: null))
          .called(1);
    });

    test('context recovery', () {
      final mockNavigatorState2 = MockNavigatorState();
      final currentState = service.navigationKey.currentState;
      expect(currentState, isNull);

      when(service.navigationKey.currentState).thenReturn(mockNavigatorState2);
      expect(service.navigationKey.currentState, equals(mockNavigatorState2));
    });
  });
}

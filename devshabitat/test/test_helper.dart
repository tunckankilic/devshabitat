import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:devshabitat/app/controllers/responsive_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:devshabitat/app/core/services/error_handler_service.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAppPlatform>(),
  MockSpec<DocumentReference>(),
  MockSpec<CollectionReference>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<Connectivity>(),
  MockSpec<SharedPreferences>(),
  MockSpec<NavigatorState>(),
  MockSpec<GlobalKey<NavigatorState>>(),
  MockSpec<ErrorHandlerService>(),
])
import 'test_helper.mocks.dart';

// Mock sınıflarını import et
import 'test_helper.mocks.dart' as mocks;

class MockFirebasePlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = '[DEFAULT]']) {
    return mocks.MockFirebaseAppPlatform();
  }

  @override
  List<FirebaseAppPlatform> get apps => [];

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return mocks.MockFirebaseAppPlatform();
  }
}

class MockFirebaseApp extends Mock implements FirebaseApp {
  @override
  String get name => '[DEFAULT]';

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'mock-api-key',
        appId: 'mock-app-id',
        messagingSenderId: 'mock-sender-id',
        projectId: 'mock-project-id',
      );
}

Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  // Firebase Core mock'u
  final mockPlatform = MockFirebasePlatform();
  FirebasePlatform.instance = mockPlatform;

  // ResponsiveController'ı test için yükle
  Get.put(ResponsiveController());
}

// Test için yardımcı fonksiyonlar
class TestHelpers {
  static void setupConnectivityMock(mocks.MockConnectivity mockConnectivity) {
    when(mockConnectivity.checkConnectivity()).thenAnswer(
      (_) async => [ConnectivityResult.wifi],
    );
    when(mockConnectivity.onConnectivityChanged).thenAnswer(
      (_) => Stream.value([ConnectivityResult.wifi]),
    );
  }

  static void setupSharedPreferencesMock(
      mocks.MockSharedPreferences mockPrefs) {
    when(mockPrefs.getBool(any)).thenReturn(false);
    when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.getString(any)).thenReturn(null);
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
  }

  static void setupNavigatorMock(mocks.MockNavigatorState mockNavigator) {
    when(mockNavigator.pushNamed(any, arguments: anyNamed('arguments')))
        .thenAnswer((_) async => null);
    when(mockNavigator.pushReplacementNamed(any,
            arguments: anyNamed('arguments')))
        .thenAnswer((_) async => null);
    when(mockNavigator.pushNamedAndRemoveUntil(any, any,
            arguments: anyNamed('arguments')))
        .thenAnswer((_) async => null);
    when(mockNavigator.pop()).thenReturn(null);
    when(mockNavigator.popUntil(any)).thenReturn(null);
  }
}

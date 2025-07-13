import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAppPlatform>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<FirebaseFirestore>(),
])
import 'test_helper.mocks.dart';

// Mock sınıflarını import et
import 'test_helper.mocks.dart' as mocks;

class MockFirebasePlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = '[DEFAULT]']) {
    return MockFirebaseAppPlatform();
  }

  @override
  List<FirebaseAppPlatform> get apps => [];

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseAppPlatform();
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

  // Firebase App mock'u
  final mockApp = mocks.MockFirebaseAppPlatform();
  when(mockPlatform.app()).thenReturn(mockApp);
}

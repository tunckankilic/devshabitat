import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/auth_state_controller.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../test_helper.dart';

@GenerateNiceMocks([
  MockSpec<AuthRepository>(),
  MockSpec<User>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
])
import 'auth_state_controller_test.mocks.dart';

void main() {
  late AuthStateController controller;
  late MockAuthRepository mockAuthRepository;
  late MockUser mockUser;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollectionRef;
  late MockDocumentReference mockDocRef;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUser = MockUser();
    mockFirestore = MockFirebaseFirestore();
    mockCollectionRef = MockCollectionReference();
    mockDocRef = MockDocumentReference();

    // Mock user özellikleri
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.photoURL).thenReturn(null);

    // Mock Firestore davranışları
    when(mockFirestore.collection(any)).thenReturn(
        mockCollectionRef as CollectionReference<Map<String, dynamic>>);
    when(mockCollectionRef.doc(any)).thenReturn(mockDocRef);
    when(mockDocRef.set(any, any)).thenAnswer((_) => Future.value());

    // Firestore instance'ını ayarla - bu satırı kaldırıyoruz çünkü instance set edilemez

    controller = AuthStateController(
      authRepository: mockAuthRepository,
    );
  });

  group('AuthStateController Tests', () {
    test('initial values should be correct', () {
      expect(controller.authState, AuthState.initial);
      expect(controller.userProfile, null);
      expect(controller.currentUser, null);
    });

    test('verifyEmail should call repository', () async {
      when(mockAuthRepository.verifyEmail()).thenAnswer((_) => Future.value());

      await controller.verifyEmail();

      verify(mockAuthRepository.verifyEmail()).called(1);
    });

    test('signOut should update auth state and call repository', () async {
      when(mockAuthRepository.signOut()).thenAnswer((_) => Future.value());

      await controller.signOut();

      verify(mockAuthRepository.signOut()).called(1);
      expect(controller.authState, AuthState.loading);
    });

    test('deleteAccount should update auth state and call repository',
        () async {
      when(mockAuthRepository.deleteAccount())
          .thenAnswer((_) => Future.value());

      await controller.deleteAccount();

      verify(mockAuthRepository.deleteAccount()).called(1);
      expect(controller.authState, AuthState.loading);
    });

    test('_initializeAuthState should handle authenticated user', () async {
      final testProfile = {'name': 'Test User', 'email': 'test@example.com'};

      when(mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      when(mockAuthRepository.getUserProfile(any))
          .thenAnswer((_) => Future.value(testProfile));

      controller.onInit();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.authState, AuthState.authenticated);
      expect(controller.userProfile, testProfile);
      expect(controller.currentUser, mockUser);
      verify(mockFirestore.collection('users')).called(1);
      verify(mockCollectionRef.doc(any)).called(1);
      verify(mockDocRef.set(any, any)).called(1);
    });

    test('_initializeAuthState should handle unauthenticated user', () async {
      when(mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(null));

      controller.onInit();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.authState, AuthState.unauthenticated);
      expect(controller.userProfile, null);
      expect(controller.currentUser, null);
    });
  });
}

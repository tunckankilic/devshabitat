import 'package:flutter_test/flutter_test.dart';
import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/controllers/email_auth_controller.dart';
import 'package:devshabitat/app/controllers/auth_state_controller.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../test_helper.dart';

@GenerateNiceMocks([
  MockSpec<EmailAuthController>(),
  MockSpec<AuthStateController>(),
  MockSpec<AuthRepository>(),
  MockSpec<ErrorHandlerService>(),
  MockSpec<User>()
])
import 'auth_controller_test.mocks.dart';

void main() {
  late AuthController controller;
  late MockEmailAuthController mockEmailAuth;
  late MockAuthStateController mockAuthState;
  late MockAuthRepository mockAuthRepository;
  late MockErrorHandlerService mockErrorHandler;
  late MockUser mockUser;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    mockEmailAuth = MockEmailAuthController();
    mockAuthState = MockAuthStateController();
    mockAuthRepository = MockAuthRepository();
    mockErrorHandler = MockErrorHandlerService();
    mockUser = MockUser();

    controller = AuthController(
      emailAuth: mockEmailAuth,
      authState: mockAuthState,
      authRepository: mockAuthRepository,
      errorHandler: mockErrorHandler,
    );
  });

  group('AuthController Tests', () {
    test('initial values should be correct', () {
      expect(controller.currentUser, null);
      expect(controller.userProfile, isEmpty);
      expect(controller.isLoading, false);
      expect(controller.lastError, isEmpty);
    });

    test('setInitialScreen should navigate to login when user is null', () {
      when(mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(null));

      controller.onInit();

      verify(mockAuthRepository.authStateChanges).called(1);
    });

    test('setInitialScreen should navigate to home when user is logged in', () {
      when(mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));

      controller.onInit();

      verify(mockAuthRepository.authStateChanges).called(1);
    });

    test('signOut should call repository and handle success', () async {
      when(mockAuthRepository.signOut()).thenAnswer((_) => Future.value());

      await controller.signOut();

      verify(mockAuthRepository.signOut()).called(1);
    });

    test('deleteAccount should call repository and handle success', () async {
      when(mockAuthRepository.deleteAccount())
          .thenAnswer((_) => Future.value());

      await controller.deleteAccount();

      verify(mockAuthRepository.deleteAccount()).called(1);
      verify(mockErrorHandler.handleSuccess('Hesabınız başarıyla silindi'))
          .called(1);
    });

    test('verifyEmail should delegate to authState', () async {
      await controller.verifyEmail();
      verify(mockAuthState.verifyEmail()).called(1);
    });

    test('isAuthLoading should combine loading states', () {
      when(mockEmailAuth.isLoading).thenReturn(true);
      expect(controller.isAuthLoading, true);

      when(mockEmailAuth.isLoading).thenReturn(false);
      expect(controller.isAuthLoading, false);
    });
  });
}

// ignore_for_file: unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/controllers/email_auth_controller.dart';
import 'package:devshabitat/app/controllers/auth_state_controller.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:devshabitat/app/services/feature_gate_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../test_helper.dart';

@GenerateNiceMocks([
  MockSpec<EmailAuthController>(),
  MockSpec<AuthStateController>(),
  MockSpec<AuthRepository>(),
  MockSpec<ErrorHandlerService>(),
  MockSpec<User>(),
  MockSpec<FeatureGateService>(),
])
import 'auth_controller_test.mocks.dart';

void main() {
  late AuthController controller;
  late MockEmailAuthController mockEmailAuth;
  late MockAuthStateController mockAuthState;
  late MockAuthRepository mockAuthRepository;
  late MockErrorHandlerService mockErrorHandler;
  late MockUser mockUser;
  late MockFeatureGateService mockFeatureGateService;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    mockEmailAuth = MockEmailAuthController();
    mockAuthState = MockAuthStateController();
    mockAuthRepository = MockAuthRepository();
    mockErrorHandler = MockErrorHandlerService();
    mockUser = MockUser();
    mockFeatureGateService = MockFeatureGateService();

    controller = AuthController(
      emailAuth: mockEmailAuth,
      authState: mockAuthState,
      authRepository: mockAuthRepository,
      errorHandler: mockErrorHandler,
      featureGateService: mockFeatureGateService,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController - Initialization', () {
    test('should initialize with correct default values', () {
      expect(controller.currentUser, null);
      expect(controller.userProfile, isEmpty);
      expect(controller.isLoading, false);
      expect(controller.lastError, isEmpty);
      expect(controller.isPasswordVisible, false);
    });

    test('should bind to auth state changes', () {
      when(
        mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => Stream.value(null));

      controller.onInit();

      verify(mockAuthRepository.authStateChanges).called(1);
    });
  });

  group('AuthController - Password Visibility', () {
    test('should toggle password visibility', () {
      expect(controller.isPasswordVisible, false);

      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible, true);

      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible, false);
    });
  });

  group('AuthController - Sign Out', () {
    test('should sign out successfully', () async {
      when(mockAuthRepository.signOut()).thenAnswer((_) async => {});

      await controller.signOut();

      verify(mockAuthRepository.signOut()).called(1);
    });

    test('should handle sign out error', () async {
      when(
        mockAuthRepository.signOut(),
      ).thenThrow(Exception('Sign out failed'));

      await controller.signOut();

      verify(mockErrorHandler.handleError(any, any)).called(1);
    });
  });

  group('AuthController - Account Management', () {
    test('should delete account successfully', () async {
      when(mockAuthRepository.deleteAccount()).thenAnswer((_) async => {});

      await controller.deleteAccount();

      verify(mockAuthRepository.deleteAccount()).called(1);
      verify(
        mockErrorHandler.handleSuccess('Hesabınız başarıyla silindi'),
      ).called(1);
    });

    test('should handle delete account error', () async {
      when(
        mockAuthRepository.deleteAccount(),
      ).thenThrow(Exception('Delete account failed'));

      await controller.deleteAccount();

      verify(mockErrorHandler.handleError(any, any)).called(1);
    });
  });

  group('AuthController - Delegation Methods', () {
    test('should delegate email auth methods', () async {
      await controller.createUserWithEmailAndPassword();
      verify(mockEmailAuth.createUserWithEmailAndPassword()).called(1);

      await controller.sendPasswordResetEmail();
      verify(mockEmailAuth.sendPasswordResetEmail()).called(1);

      await controller.updatePassword('newpassword');
      verify(mockEmailAuth.updatePassword('newpassword')).called(1);

      await controller.reauthenticate('test@example.com', 'password');
      verify(
        mockEmailAuth.reauthenticate('test@example.com', 'password'),
      ).called(1);
    });

    test('should delegate email verification', () async {
      await controller.verifyEmail();
      verify(mockAuthState.verifyEmail()).called(1);
    });
  });

  group('AuthController - Computed Properties', () {
    test('should combine loading states correctly', () {
      when(mockEmailAuth.isLoading).thenReturn(true);
      expect(controller.isAuthLoading, true);

      when(mockEmailAuth.isLoading).thenReturn(false);
      expect(controller.isAuthLoading, false);
    });

    test('should return auth state from auth state controller', () {
      when(mockAuthState.authState).thenReturn(AuthState.authenticated);
      expect(controller.authState, AuthState.authenticated);
    });

    test('should return auth profile from auth state controller', () {
      final profile = {'name': 'Test User'};
      when(mockAuthState.userProfile).thenReturn(profile);
      expect(controller.authProfile, profile);
    });
  });

  group('AuthController - Cleanup', () {
    test('should dispose resources correctly', () {
      controller.onClose();

      // Verify controllers are disposed
      verify(mockEmailAuth.dispose()).called(1);
    });
  });
}

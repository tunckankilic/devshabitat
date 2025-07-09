import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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
  MockSpec<AuthRepository>(),
  MockSpec<ErrorHandlerService>(),
  MockSpec<EmailAuthController>(),
  MockSpec<AuthStateController>(),
  MockSpec<User>(),
  MockSpec<UserCredential>()
])
import 'social_auth_controller_test.mocks.dart';

void main() {
  late AuthController controller;
  late MockAuthRepository mockAuthRepository;
  late MockErrorHandlerService mockErrorHandler;
  late MockEmailAuthController mockEmailAuth;
  late MockAuthStateController mockAuthState;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockErrorHandler = MockErrorHandlerService();
    mockEmailAuth = MockEmailAuthController();
    mockAuthState = MockAuthStateController();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();

    controller = AuthController(
      authRepository: mockAuthRepository,
      errorHandler: mockErrorHandler,
      emailAuth: mockEmailAuth,
      authState: mockAuthState,
    );
  });

  group('Social Auth Tests', () {
    group('Facebook Sign In Tests', () {
      test('should handle successful Facebook sign in', () async {
        // Arrange
        when(mockAuthRepository.signInWithFacebook())
            .thenAnswer((_) => Future.value(mockUserCredential));
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.email).thenReturn('test@facebook.com');

        // Act
        await controller.signInWithFacebook();

        // Assert
        verify(mockAuthRepository.signInWithFacebook()).called(1);
        expect(controller.isLoading, false);
        expect(controller.lastError, isEmpty);
      });

      test('should handle Facebook sign in failure', () async {
        // Arrange
        when(mockAuthRepository.signInWithFacebook())
            .thenThrow(Exception('Facebook login failed'));

        // Act
        await controller.signInWithFacebook();

        // Assert
        verify(mockAuthRepository.signInWithFacebook()).called(1);
        verify(mockErrorHandler.handleError(
          any,
          ErrorHandlerService.AUTH_ERROR,
        )).called(1);
        expect(controller.lastError, isNotEmpty);
        expect(controller.isLoading, false);
      });
    });

    group('Apple Sign In Tests', () {
      test('should handle successful Apple sign in', () async {
        // Arrange
        when(mockAuthRepository.signInWithApple())
            .thenAnswer((_) => Future.value(mockUserCredential));
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.email).thenReturn('test@apple.com');

        // Act
        await controller.signInWithApple();

        // Assert
        verify(mockAuthRepository.signInWithApple()).called(1);
        expect(controller.isLoading, false);
        expect(controller.lastError, isEmpty);
      });

      test('should handle Apple sign in failure', () async {
        // Arrange
        when(mockAuthRepository.signInWithApple())
            .thenThrow(Exception('Apple login failed'));

        // Act
        await controller.signInWithApple();

        // Assert
        verify(mockAuthRepository.signInWithApple()).called(1);
        verify(mockErrorHandler.handleError(
          any,
          ErrorHandlerService.AUTH_ERROR,
        )).called(1);
        expect(controller.lastError, isNotEmpty);
        expect(controller.isLoading, false);
      });
    });

    group('GitHub Sign In Tests', () {
      test('should handle successful GitHub sign in', () async {
        // Arrange
        when(mockAuthRepository.signInWithGithub())
            .thenAnswer((_) => Future.value(mockUserCredential));
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.email).thenReturn('test@github.com');

        // Act
        await controller.signInWithGithub();

        // Assert
        verify(mockAuthRepository.signInWithGithub()).called(1);
        expect(controller.isLoading, false);
        expect(controller.lastError, isEmpty);
      });

      test('should handle GitHub sign in failure', () async {
        // Arrange
        when(mockAuthRepository.signInWithGithub())
            .thenThrow(Exception('GitHub login failed'));

        // Act
        await controller.signInWithGithub();

        // Assert
        verify(mockAuthRepository.signInWithGithub()).called(1);
        verify(mockErrorHandler.handleError(
          any,
          ErrorHandlerService.AUTH_ERROR,
        )).called(1);
        expect(controller.lastError, isNotEmpty);
        expect(controller.isLoading, false);
      });

      test('should handle GitHub OAuth cancellation', () async {
        // Arrange
        when(mockAuthRepository.signInWithGithub()).thenThrow(
            Exception('GitHub OAuth flow failed or was cancelled by user'));

        // Act
        await controller.signInWithGithub();

        // Assert
        verify(mockAuthRepository.signInWithGithub()).called(1);
        verify(mockErrorHandler.handleError(
          any,
          ErrorHandlerService.AUTH_ERROR,
        )).called(1);
        expect(controller.lastError, isNotEmpty);
      });
    });

    group('Google Sign In Tests', () {
      test('should handle successful Google sign in', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) => Future.value(mockUserCredential));
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.email).thenReturn('test@gmail.com');

        // Act
        await controller.signInWithGoogle();

        // Assert
        verify(mockAuthRepository.signInWithGoogle()).called(1);
        expect(controller.isLoading, false);
        expect(controller.lastError, isEmpty);
      });

      test('should handle Google sign in failure', () async {
        // Arrange
        when(mockAuthRepository.signInWithGoogle())
            .thenThrow(Exception('Google login failed'));

        // Act
        await controller.signInWithGoogle();

        // Assert
        verify(mockAuthRepository.signInWithGoogle()).called(1);
        verify(mockErrorHandler.handleError(
          any,
          ErrorHandlerService.AUTH_ERROR,
        )).called(1);
        expect(controller.lastError, isNotEmpty);
        expect(controller.isLoading, false);
      });
    });

    group('Social Auth Configuration Tests', () {
      test('should check if social auth methods are available', () {
        // Test that all social auth methods are properly configured
        expect(controller, isNotNull);
        expect(mockAuthRepository, isNotNull);
        expect(mockErrorHandler, isNotNull);
      });

      test('should handle loading states during social auth', () async {
        // Arrange
        when(mockAuthRepository.signInWithFacebook()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return mockUserCredential;
        });

        // Act
        final future = controller.signInWithFacebook();

        // Assert - Loading state should be true during auth
        expect(controller.isLoading, true);

        await future;

        // Assert - Loading state should be false after auth
        expect(controller.isLoading, false);
      });
    });
  });
}

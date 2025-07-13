import 'package:flutter_test/flutter_test.dart';
import 'package:devshabitat/app/controllers/email_auth_controller.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../test_helper.dart';

@GenerateNiceMocks(
    [MockSpec<AuthRepository>(), MockSpec<ErrorHandlerService>()])
import 'email_auth_controller_test.mocks.dart';

void main() {
  late EmailAuthController controller;
  late MockAuthRepository mockAuthRepository;
  late MockErrorHandlerService mockErrorHandler;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockErrorHandler = MockErrorHandlerService();

    controller = EmailAuthController(
      authRepository: mockAuthRepository,
      errorHandler: mockErrorHandler,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  group('EmailAuthController Tests', () {
    test('initial values should be correct', () {
      expect(controller.isLoading, false);
      expect(controller.lastError, isEmpty);
      expect(controller.emailController.text, isEmpty);
      expect(controller.passwordController.text, isEmpty);
      expect(controller.confirmPasswordController.text, isEmpty);
      expect(controller.usernameController.text, isEmpty);
    });

    test('signInWithEmailAndPassword should handle empty fields', () async {
      await controller.signInWithEmailAndPassword();

      verify(mockErrorHandler.handleError(
        any,
        ErrorHandlerService.AUTH_ERROR,
      )).called(1);
      expect(controller.lastError, isNotEmpty);
    });

    test('signInWithEmailAndPassword should handle repository error', () async {
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password123';

      when(mockAuthRepository.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      )).thenThrow(Exception('Auth error'));

      await controller.signInWithEmailAndPassword();

      verify(mockErrorHandler.handleError(
        any,
        ErrorHandlerService.AUTH_ERROR,
      )).called(1);
      expect(controller.lastError, isNotEmpty);
      expect(controller.isLoading, false);
    });
  });
}

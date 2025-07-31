// ignore_for_file: unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/controllers/registration_controller.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/services/github_oauth_service.dart';
import '../../test_helper.dart';

@GenerateNiceMocks([
  MockSpec<AuthRepository>(),
  MockSpec<ErrorHandlerService>(),
  MockSpec<AuthController>(),
  MockSpec<GitHubOAuthService>(),
  MockSpec<User>(),
  MockSpec<UserCredential>(),
  MockSpec<DocumentReference>(),
  MockSpec<CollectionReference>(),
  MockSpec<FirebaseFirestore>(),
])
import 'registration_controller_test.mocks.dart';

void main() {
  late RegistrationController controller;
  late MockAuthRepository mockAuthRepository;
  late MockErrorHandlerService mockErrorHandler;
  late MockAuthController mockAuthController;
  late MockGitHubOAuthService mockGithubOAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late MockDocumentReference mockDocRef;
  late MockCollectionReference mockCollectionRef;
  late MockFirebaseFirestore mockFirestore;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockErrorHandler = MockErrorHandlerService();
    mockAuthController = MockAuthController();
    mockGithubOAuth = MockGitHubOAuthService();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    mockDocRef = MockDocumentReference();
    mockCollectionRef = MockCollectionReference();
    mockFirestore = MockFirebaseFirestore();

    controller = RegistrationController(
      authRepository: mockAuthRepository,
      errorHandler: mockErrorHandler,
      authController: mockAuthController,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('RegistrationController - Initialization', () {
    test('should initialize with correct default values', () {
      expect(controller.currentStep, RegistrationStep.basicInfo);
      expect(controller.isLoading, false);
      expect(controller.lastError, null);
      expect(controller.currentPageIndex, 0);
      expect(controller.isFirstPage, true);
      expect(controller.isLastPage, false);
    });

    test('should have empty form controllers initially', () {
      expect(controller.emailController.text, isEmpty);
      expect(controller.passwordController.text, isEmpty);
      expect(controller.confirmPasswordController.text, isEmpty);
      expect(controller.displayNameController.text, isEmpty);
    });
  });

  group('RegistrationController - Email Validation', () {
    test('should validate correct email format', () {
      controller.emailController.text = 'test@example.com';
      controller.emailController.notifyListeners();

      expect(controller.isEmailValid, true);
    });

    test('should reject invalid email format', () {
      controller.emailController.text = 'invalid-email';
      controller.emailController.notifyListeners();

      expect(controller.isEmailValid, false);
    });

    test('should reject empty email', () {
      controller.emailController.text = '';
      controller.emailController.notifyListeners();

      expect(controller.isEmailValid, false);
    });
  });

  group('RegistrationController - Password Validation', () {
    test('should validate strong password', () {
      controller.passwordController.text = 'StrongPass123!';
      controller.passwordController.notifyListeners();

      expect(controller.hasMinLength, true);
      expect(controller.hasUppercase, true);
      expect(controller.hasLowercase, true);
      expect(controller.hasNumber, true);
      expect(controller.hasSpecialChar, true);
    });

    test('should reject weak password', () {
      controller.passwordController.text = 'weak';
      controller.passwordController.notifyListeners();

      expect(controller.hasMinLength, false);
      expect(controller.hasUppercase, false);
      expect(controller.hasLowercase, true);
      expect(controller.hasNumber, false);
      expect(controller.hasSpecialChar, false);
    });

    test('should validate password confirmation match', () {
      controller.passwordController.text = 'Password123!';
      controller.confirmPasswordController.text = 'Password123!';
      controller.confirmPasswordController.notifyListeners();

      expect(controller.passwordsMatch, true);
    });

    test('should reject password confirmation mismatch', () {
      controller.passwordController.text = 'Password123!';
      controller.confirmPasswordController.text = 'DifferentPass123!';
      controller.confirmPasswordController.notifyListeners();

      expect(controller.passwordsMatch, false);
    });
  });

  group('RegistrationController - Display Name Validation', () {
    test('should validate correct display name', () {
      controller.displayNameController.text = 'John Doe';
      controller.displayNameController.notifyListeners();

      expect(controller.isDisplayNameValid, true);
    });

    test('should reject short display name', () {
      controller.displayNameController.text = 'Jo';
      controller.displayNameController.notifyListeners();

      expect(controller.isDisplayNameValid, false);
    });

    test('should reject empty display name', () {
      controller.displayNameController.text = '';
      controller.displayNameController.notifyListeners();

      expect(controller.isDisplayNameValid, false);
    });
  });

  group('RegistrationController - Navigation', () {
    test('should not allow next when basic info is incomplete', () {
      controller.emailController.text = '';
      controller.displayNameController.text = '';
      controller.passwordController.text = '';
      controller.confirmPasswordController.text = '';

      expect(controller.canGoNext, false);
    });

    test('should allow next when basic info is complete', () {
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';
      // GitHub bağlantısını simüle et
      when(mockAuthController.signInWithGithub())
          .thenAnswer((_) async => 'mock_token');

      expect(controller.canGoNext, true);
    });

    test('should navigate to next page when allowed', () {
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';
      when(mockAuthController.signInWithGithub())
          .thenAnswer((_) async => 'mock_token');

      controller.nextPage();

      expect(controller.currentPageIndex, 1);
    });

    test('should navigate to previous page', () {
      // İkinci sayfaya geç
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';
      when(mockAuthController.signInWithGithub())
          .thenAnswer((_) async => 'mock_token');
      controller.nextPage();

      controller.previousPage();

      expect(controller.currentPageIndex, 0);
    });

    test('should not navigate to previous page when on first page', () {
      controller.previousPage();

      expect(controller.currentPageIndex, 0);
    });
  });

  group('RegistrationController - GitHub Integration', () {
    test('should connect to GitHub successfully', () async {
      when(mockAuthController.signInWithGithub())
          .thenAnswer((_) async => 'mock_token');
      when(mockGithubOAuth.getUserInfo('mock_token')).thenAnswer(
          (_) async => {'login': 'testuser', 'email': 'test@example.com'});

      await controller.connectGithub();

      expect(controller.isGithubConnected, true);
      expect(controller.githubUsername, 'testuser');
    });

    test('should handle GitHub connection error', () async {
      when(mockAuthController.signInWithGithub())
          .thenThrow(Exception('GitHub connection failed'));

      await controller.connectGithub();

      expect(controller.isGithubConnected, false);
      verify(mockErrorHandler.handleError(any, any)).called(1);
    });
  });

  group('RegistrationController - Registration Process', () {
    test('should complete registration successfully', () async {
      // Setup complete user data
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';
      controller.bioController.text = 'Test bio';
      controller.locationController.text = 'Test Location';
      controller.titleController.text = 'Software Developer';
      controller.companyController.text = 'Test Company';
      controller.yearsOfExperienceController.text = '5';

      when(mockAuthRepository.createUserWithEmailAndPassword(
        any,
        any,
        any,
      )).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-user-id');

      // Son sayfaya geç ve kayıt işlemini başlat
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';
      when(mockAuthController.signInWithGithub())
          .thenAnswer((_) async => 'mock_token');

      // İlk sayfadan son sayfaya kadar ilerle
      controller.nextPage(); // personal info
      controller.nextPage(); // professional info
      controller.nextPage(); // skills info - bu kayıt işlemini tetikler

      verify(mockAuthRepository.createUserWithEmailAndPassword(
        'test@example.com',
        'StrongPass123!',
        'John Doe',
      )).called(1);
    });

    test('should handle registration error', () async {
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';

      when(mockAuthRepository.createUserWithEmailAndPassword(
        any,
        any,
        any,
      )).thenThrow(Exception('Registration failed'));
      when(mockAuthController.signInWithGithub())
          .thenAnswer((_) async => 'mock_token');

      // Son sayfaya geç
      controller.nextPage();
      controller.nextPage();
      controller.nextPage();

      verify(mockErrorHandler.handleError(any, any)).called(1);
    });
  });

  group('RegistrationController - Edge Cases', () {
    test('should handle network timeout during registration', () async {
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';

      when(mockAuthRepository.createUserWithEmailAndPassword(
        any,
        any,
        any,
      )).thenAnswer((_) => Future.delayed(Duration(seconds: 10)));
      when(mockAuthController.signInWithGithub())
          .thenAnswer((_) async => 'mock_token');

      controller.nextPage();
      controller.nextPage();
      controller.nextPage();

      expect(controller.isLoading, true);
    });

    test('should handle empty optional fields', () async {
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';

      // Optional fields are empty
      controller.bioController.text = '';
      controller.locationController.text = '';
      controller.titleController.text = '';

      when(mockAuthController.signInWithGithub())
          .thenAnswer((_) async => 'mock_token');

      expect(controller.canGoNext, true);
    });
  });

  group('RegistrationController - Error Handling', () {
    test('should handle Firebase Auth errors', () async {
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';

      when(mockAuthRepository.createUserWithEmailAndPassword(
        any,
        any,
        any,
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      when(mockAuthController.signInWithGithub())
          .thenAnswer((_) async => 'mock_token');

      controller.nextPage();
      controller.nextPage();
      controller.nextPage();

      verify(mockErrorHandler.handleError(any, any)).called(1);
    });
  });
}

// ignore_for_file: unused_local_variable

import 'package:devshabitat/app/core/services/step_navigation_service.dart';
import 'package:flutter/material.dart';
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
import 'package:devshabitat/app/views/auth/register/steps/basic_info_step.dart';
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
      expect(
        controller.currentStep,
        StepConfiguration(
          id: 'basicInfo',
          title: 'basicInfo',
          description: 'basicInfo',
          isRequired: true,
          canSkip: false,
          optionalFields: [],
        ),
      );
      expect(controller.isLoading, false);
      expect(controller.lastError, null);
      expect(controller.currentStepIndex, 0);
      expect(controller.isFirstStep, true);
      expect(controller.isLastStep, false);
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
      when(
        mockAuthController.signInWithGithub(),
      ).thenAnswer((_) async => 'mock_token');

      expect(controller.canGoNext, true);
    });

    test('should navigate to next page when allowed', () {
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';
      when(
        mockAuthController.signInWithGithub(),
      ).thenAnswer((_) async => 'mock_token');

      controller.nextPage();

      expect(controller.currentStepIndex, 1);
    });

    test('should navigate to previous page', () {
      // İkinci sayfaya geç
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';
      when(
        mockAuthController.signInWithGithub(),
      ).thenAnswer((_) async => 'mock_token');
      controller.nextPage();

      controller.previousPage();

      expect(controller.currentStepIndex, 0);
    });

    test('should not navigate to previous page when on first page', () {
      controller.previousPage();

      expect(controller.currentStepIndex, 0);
    });
  });

  /*
  group('RegistrationController - GitHub Integration', () {
    test('should connect to GitHub successfully', () async {
      // Mock GitHub OAuth token
      when(mockGithubOAuth.getGithubAccessToken())
          .thenAnswer((_) async => 'mock_token');

      // Mock GitHub API responses
      when(mockGithubOAuth.getUserInfo('mock_token')).thenAnswer(
        (_) async => {
          'login': 'testuser',
          'email': 'test@example.com',
          'name': 'Test User',
          'bio': 'Test bio',
          'company': 'Test Company',
          'location': 'Test Location',
        },
      );

      when(mockGithubOAuth.getUserEmails('mock_token')).thenAnswer(
        (_) async => ['test@example.com', 'test2@example.com'],
      );

      when(mockGithubOAuth.getUserRepositories('mock_token')).thenAnswer(
        (_) async => [
          {
            'name': 'test-repo',
            'description': 'Test repository',
            'language': 'Dart',
          }
        ],
      );

      // Test GitHub veri entegrasyonu
      await controller.importGithubData();

      // Doğrulamalar
      expect(controller.isGithubConnected.value, true);
      expect(controller.githubData['login'], 'testuser');
      expect(controller.githubData['primaryEmail'], 'test@example.com');
      expect(controller.githubData['repositories'], isNotEmpty);
      
      // Form alanlarının doldurulduğunu kontrol et
      expect(controller.emailController.text, 'test@example.com');
      expect(controller.displayNameController.text, 'Test User');
    });

    test('should handle GitHub connection error', () async {
      when(mockGithubOAuth.getGithubAccessToken())
          .thenThrow(Exception('GitHub connection failed'));

      await controller.importGithubData();

      expect(controller.isGithubConnected.value, false);
      verify(mockErrorHandler.handleError(any, any)).called(1);
    });

    test('should handle partial GitHub data', () async {
      when(mockGithubOAuth.getGithubAccessToken())
          .thenAnswer((_) async => 'mock_token');

      // Sadece temel bilgileri döndür
      when(mockGithubOAuth.getUserInfo('mock_token')).thenAnswer(
        (_) async => {'login': 'testuser'},
      );

      // Boş email ve repo listesi
      when(mockGithubOAuth.getUserEmails('mock_token'))
          .thenAnswer((_) async => []);
      when(mockGithubOAuth.getUserRepositories('mock_token'))
          .thenAnswer((_) async => []);

      await controller.importGithubData();

      expect(controller.isGithubConnected.value, true);
      expect(controller.githubData['login'], 'testuser');
      expect(controller.githubData['primaryEmail'], isNull);
      expect(controller.githubData['repositories'], isEmpty);
    });

    test('should handle network timeout', () async {
      when(mockGithubOAuth.getGithubAccessToken()).thenAnswer(
        (_) => Future.delayed(Duration(seconds: 10)),
      );

      await controller.importGithubData();

      expect(controller.isGithubConnected.value, false);
      verify(mockErrorHandler.handleError(any, any)).called(1);
    });
  });
*/
  group('RegistrationController - Registration Process', () {
    test('should complete registration successfully', () async {
      // Setup complete user data
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';
      controller.bioController.text = 'Test bio';
      controller.locationTextController.text = 'Test Location';
      controller.titleController.text = 'Software Developer';
      controller.companyController.text = 'Test Company';
      controller.yearsOfExperienceController.text = '5';

      when(
        mockAuthRepository.createUserWithEmailAndPassword(any, any, any),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-user-id');

      // Son sayfaya geç ve kayıt işlemini başlat
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';
      when(
        mockAuthController.signInWithGithub(),
      ).thenAnswer((_) async => 'mock_token');

      // İlk sayfadan son sayfaya kadar ilerle
      controller.nextPage(); // personal info
      controller.nextPage(); // professional info
      controller.nextPage(); // skills info - bu kayıt işlemini tetikler

      verify(
        mockAuthRepository.createUserWithEmailAndPassword(
          'test@example.com',
          'StrongPass123!',
          'John Doe',
        ),
      ).called(1);
    });

    test('should handle registration error', () async {
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';

      when(
        mockAuthRepository.createUserWithEmailAndPassword(any, any, any),
      ).thenThrow(Exception('Registration failed'));
      when(
        mockAuthController.signInWithGithub(),
      ).thenAnswer((_) async => 'mock_token');

      // Son sayfaya geç
      controller.nextPage();
      controller.nextPage();
      controller.nextPage();

      verify(mockErrorHandler.handleError(any, any)).called(1);
    });
  });

  group('RegistrationController - Accessibility', () {
    testWidgets('should have proper semantic labels on form fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: BasicInfoStep())),
      );

      // Email alanı
      expect(
        find.bySemanticsLabel('E-posta adresi giriş alanı'),
        findsOneWidget,
      );

      // Görünen ad alanı
      expect(find.bySemanticsLabel('Görünen ad giriş alanı'), findsOneWidget);

      // Şifre alanı
      expect(find.bySemanticsLabel('Şifre giriş alanı'), findsOneWidget);

      // Şifre doğrulama alanı
      expect(
        find.bySemanticsLabel('Şifre doğrulama giriş alanı'),
        findsOneWidget,
      );
    });

    testWidgets('should have proper semantic labels on icons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: BasicInfoStep())),
      );

      // Icon semantik etiketleri
      expect(find.bySemanticsLabel('E-posta simgesi'), findsOneWidget);
      expect(find.bySemanticsLabel('Kullanıcı simgesi'), findsOneWidget);
      expect(find.bySemanticsLabel('Şifre simgesi'), findsOneWidget);
      expect(find.bySemanticsLabel('Şifre doğrulama simgesi'), findsOneWidget);
    });

    testWidgets('should have proper semantic labels on GitHub section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: BasicInfoStep())),
      );

      // GitHub bölümü semantik etiketleri
      expect(
        find.bySemanticsLabel('GitHub veri içe aktarma bölümü'),
        findsOneWidget,
      );

      // GitHub butonu semantik etiketleri
      expect(find.bySemanticsLabel('GitHub\'dan verileri al'), findsOneWidget);
    });

    testWidgets('should respect text scaling', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaleFactor: 1.5),
            child: Scaffold(body: BasicInfoStep()),
          ),
        ),
      );

      // Text widget'larının ölçeklendiğini kontrol et
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final textWidget in textWidgets) {
        if (textWidget.style?.fontSize != null) {
          expect(textWidget.style!.fontSize, textWidget.style!.fontSize! * 1.5);
        }
      }
    });
  });

  group('RegistrationController - Edge Cases', () {
    test('should handle network timeout during registration', () async {
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';

      when(
        mockAuthRepository.createUserWithEmailAndPassword(any, any, any),
      ).thenAnswer((_) => Future.delayed(Duration(seconds: 10)));
      when(
        mockAuthController.signInWithGithub(),
      ).thenAnswer((_) async => 'mock_token');

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
      controller.locationTextController.text = '';
      controller.titleController.text = '';

      when(
        mockAuthController.signInWithGithub(),
      ).thenAnswer((_) async => 'mock_token');

      expect(controller.canGoNext, true);
    });
  });

  group('RegistrationController - Performance', () {
    testWidgets('should minimize rebuilds during form validation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: BasicInfoStep())),
      );

      // Rebuild sayacı
      int rebuildCount = 0;
      final rebuildCounter = GetBuilder<RegistrationController>(
        builder: (controller) {
          rebuildCount++;
          return Container();
        },
      );

      // Form alanlarını doldur
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.pump();

      // Sadece gerekli widget'lar yeniden oluşturulmalı
      expect(rebuildCount, lessThan(3));
    });

    testWidgets('should handle rapid form input efficiently', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: BasicInfoStep())),
      );

      // Hızlı art arda form girişleri
      for (int i = 0; i < 10; i++) {
        await tester.enterText(
          find.byType(TextFormField).first,
          'test$i@example.com',
        );
        await tester.pump(Duration(milliseconds: 100));
      }

      // Son değer doğru olmalı
      expect(
        (find.byType(TextFormField).first.evaluate().single.widget
                as TextFormField)
            .controller!
            .text,
        'test9@example.com',
      );
    });

    testWidgets('should debounce password validation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: BasicInfoStep())),
      );

      // Şifre alanını bul
      final passwordField = find.byType(TextFormField).at(2);

      // Hızlı art arda şifre değişiklikleri
      for (int i = 0; i < 5; i++) {
        await tester.enterText(passwordField, 'Password$i');
        await tester.pump(Duration(milliseconds: 100));
      }

      // Debounce süresi sonunda son değer doğru olmalı
      await tester.pump(Duration(milliseconds: 500));
      expect(
        (passwordField.evaluate().single.widget as TextFormField)
            .controller!
            .text,
        'Password4',
      );
    });

    testWidgets('should handle GitHub data loading efficiently', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: BasicInfoStep())),
      );

      // GitHub bağlantı butonunu bul
      final githubButton = find.byType(ElevatedButton);

      // GitHub verilerini yükle
      await tester.tap(githubButton);
      await tester.pump();

      // Yükleme göstergesi görünmeli
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Veriler yüklendiğinde form alanları doldurulmalı
      await tester.pump(Duration(seconds: 2));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('RegistrationController - Error Handling', () {
    test('should handle Firebase Auth errors', () async {
      controller.emailController.text = 'test@example.com';
      controller.displayNameController.text = 'John Doe';
      controller.passwordController.text = 'StrongPass123!';
      controller.confirmPasswordController.text = 'StrongPass123!';

      when(
        mockAuthRepository.createUserWithEmailAndPassword(any, any, any),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      when(
        mockAuthController.signInWithGithub(),
      ).thenAnswer((_) async => 'mock_token');

      controller.nextPage();
      controller.nextPage();
      controller.nextPage();

      verify(mockErrorHandler.handleError(any, any)).called(1);
    });
  });
}

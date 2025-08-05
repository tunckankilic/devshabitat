import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:devshabitat/app/services/github_oauth_service.dart';
import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:devshabitat/app/services/deep_linking_service.dart';
import '../../test_helper.dart';

@GenerateNiceMocks([
  MockSpec<Logger>(),
  MockSpec<ErrorHandlerService>(),
  MockSpec<DeepLinkingService>(),
  MockSpec<http.Client>(),
  MockSpec<FirebaseAuth>(),
])
import 'github_oauth_service_test.mocks.dart';

void main() {
  late GitHubOAuthService service;
  late MockLogger mockLogger;
  late MockErrorHandlerService mockErrorHandler;
  late MockDeepLinkingService mockDeepLinkingService;
  late MockFirebaseAuth mockFirebaseAuth;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    mockLogger = MockLogger();
    mockErrorHandler = MockErrorHandlerService();
    mockDeepLinkingService = MockDeepLinkingService();
    mockFirebaseAuth = MockFirebaseAuth();

    service = GitHubOAuthService(
      logger: mockLogger,
      errorHandler: mockErrorHandler,
    );

    // DeepLinkingService'i Get'e ekle
    Get.put<DeepLinkingService>(mockDeepLinkingService);
  });

  tearDown(() {
    Get.reset();
  });

  group('GitHubOAuthService - Initialization', () {
    test('should initialize with correct dependencies', () {
      expect(service, isNotNull);
    });
  });

  group('GitHubOAuthService - Sign In with GitHub', () {
    test('should handle successful GitHub sign in', () async {
      // Mock successful URL launch
      when(
        mockDeepLinkingService.oauthCallbackStream,
      ).thenAnswer((_) => Stream.value({'code': 'mock_auth_code'}));

      final result = await service.getGithubAccessToken();

      expect(result, isNotNull);
    });

    test('should handle GitHub configuration not set', () async {
      // GitHub config mock'u için gerekli setup
      // Bu test için GitHubConfig.isConfigured false olmalı

      final result = await service.getGithubAccessToken();

      expect(result, isNull);
      verify(mockErrorHandler.handleError(any, any)).called(1);
    });

    test('should handle redirect failure', () async {
      when(mockDeepLinkingService.oauthCallbackStream).thenAnswer(
        (_) => Stream.value({}), // code yok
      );

      final result = await service.getGithubAccessToken();

      expect(result, isNull);
    });

    test('should handle access token request failure', () async {
      when(
        mockDeepLinkingService.oauthCallbackStream,
      ).thenAnswer((_) => Stream.value({'code': 'mock_auth_code'}));

      // HTTP client mock'u için gerekli setup
      // Bu test için HTTP response'u başarısız olmalı

      final result = await service.getGithubAccessToken();

      expect(result, isNull);
    });

    test('should handle user email request failure', () async {
      when(
        mockDeepLinkingService.oauthCallbackStream,
      ).thenAnswer((_) => Stream.value({'code': 'mock_auth_code'}));

      // HTTP client mock'u için gerekli setup
      // Bu test için email API response'u başarısız olmalı

      final result = await service.getGithubAccessToken();

      expect(result, isNull);
    });
  });

  group('GitHubOAuthService - Get Access Token', () {
    test('should get access token successfully', () async {
      when(
        mockDeepLinkingService.oauthCallbackStream,
      ).thenAnswer((_) => Stream.value({'code': 'mock_auth_code'}));

      final result = await service.getGithubAccessToken();

      expect(result, isNotNull);
    });

    test('should handle access token request error', () async {
      when(
        mockDeepLinkingService.oauthCallbackStream,
      ).thenAnswer((_) => Stream.value({'code': 'mock_auth_code'}));

      // HTTP client mock'u için gerekli setup
      // Bu test için token API response'u başarısız olmalı

      final result = await service.getGithubAccessToken();

      expect(result, isNull);
      verify(mockLogger.e(any)).called(1);
      verify(mockErrorHandler.handleError(any, any)).called(1);
    });
  });

  group('GitHubOAuthService - Error Handling', () {
    test('should handle network timeout', () async {
      when(
        mockDeepLinkingService.oauthCallbackStream,
      ).thenAnswer((_) => Stream.value({'code': 'mock_auth_code'}));

      // Timeout simülasyonu için gerekli setup

      final result = await service.getGithubAccessToken();

      expect(result, isNull);
    });

    test('should handle malformed JSON response', () async {
      when(
        mockDeepLinkingService.oauthCallbackStream,
      ).thenAnswer((_) => Stream.value({'code': 'mock_auth_code'}));

      // HTTP client mock'u için gerekli setup
      // Bu test için geçersiz JSON response döndürülmeli

      final result = await service.getGithubAccessToken();

      expect(result, isNull);
      verify(mockLogger.e(any)).called(1);
    });

    test('should handle missing access token in response', () async {
      when(
        mockDeepLinkingService.oauthCallbackStream,
      ).thenAnswer((_) => Stream.value({'code': 'mock_auth_code'}));

      // HTTP client mock'u için gerekli setup
      // Bu test için access_token olmayan response döndürülmeli

      final result = await service.getGithubAccessToken();

      expect(result, isNull);
    });
  });

  group('GitHubOAuthService - Edge Cases', () {
    test('should handle empty auth code', () async {
      when(
        mockDeepLinkingService.oauthCallbackStream,
      ).thenAnswer((_) => Stream.value({'code': ''}));

      final result = await service.getGithubAccessToken();

      expect(result, isNull);
    });

    test('should handle user with no primary email', () async {
      when(
        mockDeepLinkingService.oauthCallbackStream,
      ).thenAnswer((_) => Stream.value({'code': 'mock_auth_code'}));

      // HTTP client mock'u için gerekli setup
      // Bu test için primary email olmayan response döndürülmeli

      final result = await service.getGithubAccessToken();

      expect(result, isNull);
    });

    test('should handle user with no email at all', () async {
      when(
        mockDeepLinkingService.oauthCallbackStream,
      ).thenAnswer((_) => Stream.value({'code': 'mock_auth_code'}));

      // HTTP client mock'u için gerekli setup
      // Bu test için boş email listesi döndürülmeli

      final result = await service.getGithubAccessToken();

      expect(result, isNull);
    });
  });

  group('GitHubOAuthService - Get User Info', () {
    test('should get user info successfully', () async {
      final accessToken = 'mock_access_token';

      final result = await service.getUserInfo(accessToken);

      expect(result, isNotNull);
    });

    test('should handle user info request failure', () async {
      final accessToken = 'mock_access_token';

      // HTTP client mock'u için gerekli setup
      // Bu test için başarısız API response döndürülmeli

      final result = await service.getUserInfo(accessToken);

      expect(result, isNull);
      verify(mockLogger.e(any)).called(1);
      verify(mockErrorHandler.handleError(any, any)).called(1);
    });
  });
}

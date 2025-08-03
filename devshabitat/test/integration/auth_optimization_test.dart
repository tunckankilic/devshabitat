import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:devshabitat/app/services/profile_completion_service.dart';
import 'package:devshabitat/app/services/feature_gate_service.dart';
import 'package:devshabitat/app/services/user_service.dart';
import 'package:devshabitat/app/models/enhanced_user_model.dart';
import 'package:devshabitat/app/models/profile_completion_model.dart';

void main() {
  group('Authentication Optimization Integration Tests', () {
    late ProfileCompletionService profileCompletionService;
    late FeatureGateService featureGateService;

    setUp(() async {
      Get.testMode = true;
      Get.put<ProfileCompletionService>(ProfileCompletionService());
      Get.put<UserService>(UserService());
      Get.put<FeatureGateService>(
        FeatureGateService(
          profileCompletionService: Get.find(),
          userService: Get.find(),
        ),
      );

      profileCompletionService = Get.find<ProfileCompletionService>();
      featureGateService = Get.find<FeatureGateService>();
    });

    tearDown(() {
      Get.reset();
    });

    group('Profile Completion Service', () {
      test(
        'Should calculate correct completion levels for different user types',
        () {
          // Test minimal user
          final minimalUser = EnhancedUserModel(
            uid: 'test_minimal',
            email: 'test@example.com',
            displayName: 'Test User',
          );

          final minimalStatus = profileCompletionService
              .calculateCompletionLevel(minimalUser);
          expect(minimalStatus.level, ProfileCompletionLevel.minimal);
          expect(minimalStatus.percentage, 15.0);

          // Test basic user
          final basicUser = EnhancedUserModel(
            uid: 'test_basic',
            email: 'test@example.com',
            displayName: 'Test User',
            bio: 'I am a developer with experience in mobile development',
            skills: ['Flutter', 'Dart', 'Firebase'],
          );

          final basicStatus = profileCompletionService.calculateCompletionLevel(
            basicUser,
          );
          expect(basicStatus.level, ProfileCompletionLevel.basic);
          expect(basicStatus.percentage, greaterThan(40.0));
        },
      );

      test('Should identify missing fields correctly', () {
        final user = EnhancedUserModel(
          uid: 'test_user',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        final missingFields = profileCompletionService
            .getMissingFieldsWithDetails(user, ProfileCompletionLevel.standard);

        final fieldNames = missingFields.map((f) => f.name).toList();
        expect(fieldNames, contains('bio'));
        expect(fieldNames, contains('skills'));
        expect(fieldNames, contains('githubUsername'));
      });
    });

    group('Feature Gate Service', () {
      test('Should correctly restrict access based on completion levels', () {
        final minimalUser = EnhancedUserModel(
          uid: 'test_minimal',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        final basicUser = EnhancedUserModel(
          uid: 'test_basic',
          email: 'test@example.com',
          displayName: 'Test User',
          bio: 'I am a developer',
          skills: ['Flutter', 'Dart', 'Firebase'],
        );

        // Minimal user tests
        expect(featureGateService.canAccess('browsing', minimalUser), true);
        expect(featureGateService.canAccess('messaging', minimalUser), false);
        expect(
          featureGateService.canAccess('project_sharing', minimalUser),
          false,
        );

        // Basic user tests
        expect(featureGateService.canAccess('browsing', basicUser), true);
        expect(featureGateService.canAccess('messaging', basicUser), true);
        expect(featureGateService.canAccess('networking', basicUser), true);
        expect(
          featureGateService.canAccess('project_sharing', basicUser),
          false,
        );
      });

      test('Should provide feature display names', () {
        expect(
          featureGateService.getFeatureDisplayName('messaging'),
          'Mesajlaşma',
        );
        expect(
          featureGateService.getFeatureDisplayName('networking'),
          'Ağ Oluşturma',
        );
        expect(
          featureGateService.getFeatureDisplayName('project_sharing'),
          'Proje Paylaşımı',
        );
      });
    });

    group('System Integration', () {
      test('Should demonstrate complete user journey from minimal to basic', () {
        // Step 1: New user with minimal data
        final newUser = EnhancedUserModel(
          uid: 'journey_user',
          email: 'journey@example.com',
          displayName: 'Journey User',
          photoURL: 'https://example.com/photo.jpg',
        );

        // Initial state
        expect(featureGateService.canAccess('browsing', newUser), true);
        expect(featureGateService.canAccess('messaging', newUser), false);

        // Step 2: User upgrades profile
        final upgradedUser = newUser.copyWith(
          bio:
              'I am a Flutter developer passionate about creating amazing mobile experiences',
          skills: ['Flutter', 'Dart', 'Firebase', 'iOS', 'Android'],
        );

        // Verify upgrade
        final finalStatus = profileCompletionService.calculateCompletionLevel(
          upgradedUser,
        );
        expect(finalStatus.level, ProfileCompletionLevel.basic);
        expect(featureGateService.canAccess('messaging', upgradedUser), true);
        expect(featureGateService.canAccess('networking', upgradedUser), true);
      });

      test('Should handle edge cases gracefully', () {
        // Empty user
        final emptyUser = EnhancedUserModel(
          uid: 'empty',
          email: '',
          displayName: null,
        );

        final status = profileCompletionService.calculateCompletionLevel(
          emptyUser,
        );
        expect(status.level, ProfileCompletionLevel.minimal);
        expect(status.missingFields, contains('email'));

        // User with null skills
        final nullSkillsUser = EnhancedUserModel(
          uid: 'null_skills',
          email: 'test@example.com',
          displayName: 'Test',
          skills: null,
        );

        expect(
          featureGateService.canAccess('messaging', nullSkillsUser),
          false,
        );
      });
    });
  });
}

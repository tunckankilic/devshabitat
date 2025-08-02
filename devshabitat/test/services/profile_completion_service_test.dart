import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/enhanced_user_model.dart' as enhanced;
import 'package:devshabitat/app/models/profile_completion_model.dart';
import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:devshabitat/app/models/location/location_model.dart';
import 'package:devshabitat/app/services/profile_completion_service.dart';

void main() {
  late ProfileCompletionService service;

  setUpAll(() {
    Get.testMode = true;
  });

  setUp(() {
    service = ProfileCompletionService();
    Get.put(service);
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileCompletionLevel', () {
    test('should return correct completion level from percentage', () {
      expect(ProfileCompletionLevel.fromPercentage(10),
          ProfileCompletionLevel.minimal);
      expect(ProfileCompletionLevel.fromPercentage(15),
          ProfileCompletionLevel.minimal);
      expect(ProfileCompletionLevel.fromPercentage(30),
          ProfileCompletionLevel.minimal);
      expect(ProfileCompletionLevel.fromPercentage(40),
          ProfileCompletionLevel.basic);
      expect(ProfileCompletionLevel.fromPercentage(50),
          ProfileCompletionLevel.basic);
      expect(ProfileCompletionLevel.fromPercentage(70),
          ProfileCompletionLevel.standard);
      expect(ProfileCompletionLevel.fromPercentage(80),
          ProfileCompletionLevel.standard);
      expect(ProfileCompletionLevel.fromPercentage(100),
          ProfileCompletionLevel.complete);
    });

    test('should return correct next level', () {
      expect(ProfileCompletionLevel.minimal.nextLevel,
          ProfileCompletionLevel.basic);
      expect(ProfileCompletionLevel.basic.nextLevel,
          ProfileCompletionLevel.standard);
      expect(ProfileCompletionLevel.standard.nextLevel,
          ProfileCompletionLevel.complete);
      expect(ProfileCompletionLevel.complete.nextLevel, null);
    });

    test('should have correct percentage values', () {
      expect(ProfileCompletionLevel.minimal.percentage, 15);
      expect(ProfileCompletionLevel.basic.percentage, 40);
      expect(ProfileCompletionLevel.standard.percentage, 70);
      expect(ProfileCompletionLevel.complete.percentage, 100);
    });
  });

  group('ProfileCompletionService - EnhancedUserModel', () {
    test('should calculate minimal level for basic user', () {
      final user = enhanced.EnhancedUserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      final status = service.calculateCompletionLevel(user);

      expect(status.level, ProfileCompletionLevel.minimal);
      expect(status.percentage, 15.0);
      expect(status.completedFields, contains('uid'));
      expect(status.completedFields, contains('email'));
      expect(status.completedFields, contains('displayName'));
    });

    test('should calculate basic level with bio and skills', () {
      final user = enhanced.EnhancedUserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        bio: 'I am a developer',
        skills: ['Flutter', 'Dart', 'JavaScript', 'React'],
      );

      final status = service.calculateCompletionLevel(user);

      expect(status.level, ProfileCompletionLevel.basic);
      expect(status.percentage, 40.0);
      expect(status.completedFields, contains('bio'));
      expect(status.completedFields, contains('skills'));
    });

    test('should calculate standard level with github and experience', () {
      final user = enhanced.EnhancedUserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        bio: 'I am a developer',
        skills: ['Flutter', 'Dart', 'JavaScript'],
        githubUsername: 'testuser',
        workExperience: [
          enhanced.WorkExperience(title: 'Developer', company: 'Test Company'),
        ],
        location: LocationModel(
          userId: 'test-user',
          location: GeoPoint(40.7128, -74.0060),
          accuracy: 10.0,
          speed: 0.0,
          heading: 0.0,
          timestamp: DateTime.now(),
          address: 'New York, NY',
        ),
      );

      final status = service.calculateCompletionLevel(user);

      expect(status.level, ProfileCompletionLevel.standard);
      expect(status.percentage, 70.0);
      expect(status.completedFields, contains('githubUsername'));
      expect(status.completedFields, contains('workExperience'));
      expect(status.completedFields, contains('location'));
    });

    test('should not require skills with less than 3 items', () {
      final user = enhanced.EnhancedUserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        bio: 'I am a developer',
        skills: ['Flutter', 'Dart'], // Only 2 skills
      );

      final status = service.calculateCompletionLevel(user);

      expect(status.level,
          ProfileCompletionLevel.minimal); // Should not reach basic
      expect(status.missingFields, contains('skills'));
    });
  });

  group('Feature Access Control', () {
    test('should allow browsing for minimal level', () {
      expect(
        service.canAccessFeature('browsing', ProfileCompletionLevel.minimal),
        true,
      );
    });

    test('should not allow commenting for minimal level', () {
      expect(
        service.canAccessFeature('commenting', ProfileCompletionLevel.minimal),
        false,
      );
    });

    test('should allow commenting for basic level', () {
      expect(
        service.canAccessFeature('commenting', ProfileCompletionLevel.basic),
        true,
      );
    });

    test('should not allow community creation for standard level', () {
      expect(
        service.canAccessFeature(
            'community_creation', ProfileCompletionLevel.standard),
        false,
      );
    });

    test('should allow community creation for complete level', () {
      expect(
        service.canAccessFeature(
            'community_creation', ProfileCompletionLevel.complete),
        true,
      );
    });

    test('should allow access to unknown features', () {
      expect(
        service.canAccessFeature(
            'unknown_feature', ProfileCompletionLevel.minimal),
        true,
      );
    });
  });

  group('ProfileCompletionService - UserProfile', () {
    test('should calculate completion for UserProfile model', () {
      final profile = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        bio: 'I am a developer',
        skills: ['Flutter', 'Dart', 'JavaScript'],
        interests: ['Mobile Development', 'Web Development'],
        yearsOfExperience: 3,
        isOnline: true,
        githubUsername: 'testuser',
        workExperience: [
          {
            'title': 'Developer',
            'company': 'Test Company',
            'startDate': DateTime.now(),
          }
        ],
        projects: [
          {
            'name': 'Test Project',
            'description': 'A test project',
          }
        ],
        education: [
          {
            'school': 'Test University',
            'degree': 'Bachelor',
            'field': 'Computer Science',
          }
        ],
        socialLinks: {
          'linkedin': 'https://linkedin.com/in/testuser',
        },
        locationName: 'New York',
      );

      final status = service.calculateCompletionLevelForProfile(profile);

      expect(status.level, ProfileCompletionLevel.complete);
      expect(status.percentage, 100.0);
    });
  });

  group('Missing Fields and Next Steps', () {
    test('should return missing fields for target level', () {
      final user = enhanced.EnhancedUserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      final missingFields =
          service.getMissingFields(user, ProfileCompletionLevel.basic);

      expect(missingFields, contains('bio'));
      expect(missingFields, contains('skills'));
    });

    test('should return next completion steps', () {
      final user = enhanced.EnhancedUserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      final nextSteps = service.getNextCompletionSteps(user);

      expect(nextSteps.length, 2); // bio and skills for basic level
      expect(nextSteps.any((step) => step.name == 'bio'), true);
      expect(nextSteps.any((step) => step.name == 'skills'), true);
    });

    test('should return empty list for complete profile', () {
      final user = enhanced.EnhancedUserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        bio: 'I am a developer',
        skills: ['Flutter', 'Dart', 'JavaScript'],
        githubUsername: 'testuser',
        workExperience: [
          enhanced.WorkExperience(title: 'Developer', company: 'Test Company'),
        ],
        location: LocationModel(
          userId: 'test-user',
          location: GeoPoint(40.7128, -74.0060),
          accuracy: 10.0,
          speed: 0.0,
          heading: 0.0,
          timestamp: DateTime.now(),
          address: 'New York, NY',
        ),
        education: [
          enhanced.Education(
            school: 'Test University',
            degree: 'Bachelor',
            field: 'Computer Science',
          ),
        ],
      );

      final nextSteps = service.getNextCompletionSteps(user);

      expect(nextSteps.isEmpty, true);
    });
  });

  group('Completion Summary', () {
    test('should provide comprehensive completion summary', () {
      final user = enhanced.EnhancedUserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        bio: 'I am a developer',
        skills: ['Flutter', 'Dart', 'JavaScript'],
      );

      final summary = service.getCompletionSummary(user);

      expect(summary['currentLevel'], 'basic');
      expect(summary['percentage'], 40.0);
      expect(summary['nextLevel'], 'standard');
      expect(summary['completedFields'], 5);
      expect(summary['availableFeatures'], contains('browsing'));
      expect(summary['availableFeatures'], contains('commenting'));
      expect(summary['lockedFeatures'], contains('community_creation'));
      expect(summary['nextSteps'], isA<List>());
    });
  });

  group('Feature Access Info', () {
    test('should return feature access information', () {
      final featureInfo = service.getFeatureAccessInfo();

      expect(featureInfo['browsing']?['requiredLevel'], 'minimal');
      expect(featureInfo['browsing']?['requiredPercentage'], 15);
      expect(featureInfo['browsing']?['displayName'], 'Gezinme');

      expect(featureInfo['community_creation']?['requiredLevel'], 'complete');
      expect(featureInfo['community_creation']?['requiredPercentage'], 100);
      expect(featureInfo['community_creation']?['displayName'],
          'Topluluk Oluşturma');
    });
  });

  group('Required Fields', () {
    test('should return correct required fields for each level', () {
      final minimalFields =
          service.getRequiredFields(ProfileCompletionLevel.minimal);
      expect(minimalFields, contains('uid'));
      expect(minimalFields, contains('email'));
      expect(minimalFields, contains('displayName'));

      final basicFields =
          service.getRequiredFields(ProfileCompletionLevel.basic);
      expect(basicFields.length, 5); // minimal + bio + skills

      final standardFields =
          service.getRequiredFields(ProfileCompletionLevel.standard);
      expect(
          standardFields.length, 8); // basic + github + experience + location
    });
  });
}

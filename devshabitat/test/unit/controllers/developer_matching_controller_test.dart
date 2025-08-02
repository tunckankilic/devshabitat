import 'package:flutter_test/flutter_test.dart';
import 'package:devshabitat/app/models/user_profile_model.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('should create UserProfile with required fields', () {
      final user = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        skills: ['Flutter', 'Dart'],
        interests: ['Mobile Development'],
        yearsOfExperience: 2,
        isOnline: false,
      );

      expect(user.id, 'test-id');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.skills, ['Flutter', 'Dart']);
      expect(user.yearsOfExperience, 2);
    });

    test('should handle optional fields', () {
      final user = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        skills: [],
        interests: [],
        yearsOfExperience: 0,
        isOnline: false,
        title: 'Flutter Developer',
        company: 'Tech Corp',
        locationName: 'Istanbul, Turkey',
        isRemote: true,
        isFullTime: true,
      );

      expect(user.title, 'Flutter Developer');
      expect(user.company, 'Tech Corp');
      expect(user.locationName, 'Istanbul, Turkey');
      expect(user.isRemote, true);
      expect(user.isFullTime, true);
    });

    test('should have default values', () {
      final user = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        skills: [],
        interests: [],
        yearsOfExperience: 0,
        isOnline: false,
      );

      expect(user.skills, isEmpty);
      expect(user.interests, isEmpty);
      expect(user.languages, isEmpty);
      expect(user.yearsOfExperience, 0);
      expect(user.isRemote, false);
      expect(user.isFullTime, false);
      expect(user.isPartTime, false);
      expect(user.isFreelance, false);
      expect(user.isOnline, false);
    });
  });
}

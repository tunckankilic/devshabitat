import 'package:flutter_test/flutter_test.dart';
import 'package:devshabitat/app/models/github_stats_model.dart';

void main() {
  group('GithubStatsModel Tests', () {
    test('should create model with correct values', () {
      final stats = GithubStatsModel(
        username: 'testuser',
        totalRepositories: 10,
        totalContributions: 100,
        languageStats: {'Dart': 5, 'JavaScript': 3},
        recentRepositories: [],
        contributionGraph: {},
        followers: 50,
        following: 30,
      );

      expect(stats.username, 'testuser');
      expect(stats.totalRepositories, 10);
      expect(stats.totalContributions, 100);
      expect(stats.followers, 50);
      expect(stats.following, 30);
      expect(stats.languageStats['Dart'], 5);
      expect(stats.languageStats['JavaScript'], 3);
    });

    test('should serialize to JSON correctly', () {
      final stats = GithubStatsModel(
        username: 'testuser',
        totalRepositories: 10,
        totalContributions: 100,
        languageStats: {'Dart': 5},
        recentRepositories: [],
        contributionGraph: {},
        followers: 50,
        following: 30,
      );

      final json = stats.toJson();
      expect(json['username'], 'testuser');
      expect(json['total_repositories'], 10);
      expect(json['total_contributions'], 100);
      expect(json['followers'], 50);
      expect(json['following'], 30);
      expect(json['language_stats']['Dart'], 5);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'username': 'testuser',
        'total_repositories': 10,
        'total_contributions': 100,
        'language_stats': {'Dart': 5, 'JavaScript': 3},
        'recent_repositories': [],
        'contribution_graph': {},
        'followers': 50,
        'following': 30,
      };

      final stats = GithubStatsModel.fromJson(json);
      expect(stats.username, 'testuser');
      expect(stats.totalRepositories, 10);
      expect(stats.totalContributions, 100);
      expect(stats.followers, 50);
      expect(stats.following, 30);
      expect(stats.languageStats['Dart'], 5);
      expect(stats.languageStats['JavaScript'], 3);
    });

    test('should handle optional fields', () {
      final stats = GithubStatsModel(
        username: 'testuser',
        totalRepositories: 10,
        totalContributions: 100,
        languageStats: {},
        recentRepositories: [],
        contributionGraph: {},
        followers: 50,
        following: 30,
        avatarUrl: 'https://example.com/avatar.jpg',
        bio: 'Test bio',
        location: 'Test Location',
        website: 'https://example.com',
        company: 'Test Company',
      );

      expect(stats.avatarUrl, 'https://example.com/avatar.jpg');
      expect(stats.bio, 'Test bio');
      expect(stats.location, 'Test Location');
      expect(stats.website, 'https://example.com');
      expect(stats.company, 'Test Company');
    });
  });
}

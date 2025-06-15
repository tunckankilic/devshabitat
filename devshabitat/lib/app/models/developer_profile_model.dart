import 'package:get/get.dart';

enum ExperienceLevel { junior, midLevel, senior, lead, architect }

class DeveloperProfile {
  final String id;
  final String name;
  final String title;
  final String bio;
  final List<String> skills;
  final List<String> languages;
  final List<String> frameworks;
  final Map<String, dynamic> githubStats;
  final String profileImage;
  final String location;
  final List<String> portfolioLinks;
  final ExperienceLevel experienceLevel;
  final List<String> interests;

  DeveloperProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.bio,
    required this.skills,
    required this.languages,
    required this.frameworks,
    required this.githubStats,
    required this.profileImage,
    required this.location,
    required this.portfolioLinks,
    required this.experienceLevel,
    required this.interests,
  });

  factory DeveloperProfile.fromJson(Map<String, dynamic> json) {
    return DeveloperProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      bio: json['bio'] as String,
      skills: List<String>.from(json['skills'] as List),
      languages: List<String>.from(json['languages'] as List),
      frameworks: List<String>.from(json['frameworks'] as List),
      githubStats: json['githubStats'] as Map<String, dynamic>,
      profileImage: json['profileImage'] as String,
      location: json['location'] as String,
      portfolioLinks: List<String>.from(json['portfolioLinks'] as List),
      experienceLevel: ExperienceLevel.values.firstWhere(
        (e) => e.toString() == 'ExperienceLevel.${json['experienceLevel']}',
      ),
      interests: List<String>.from(json['interests'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'bio': bio,
      'skills': skills,
      'languages': languages,
      'frameworks': frameworks,
      'githubStats': githubStats,
      'profileImage': profileImage,
      'location': location,
      'portfolioLinks': portfolioLinks,
      'experienceLevel': experienceLevel.toString().split('.').last,
      'interests': interests,
    };
  }
}

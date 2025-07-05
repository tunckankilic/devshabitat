enum ExperienceLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

class TechStackModel {
  final String name;
  int projectCount;
  int totalStars;
  final ExperienceLevel experienceLevel;

  TechStackModel({
    required this.name,
    required this.projectCount,
    required this.totalStars,
    required this.experienceLevel,
  });

  factory TechStackModel.fromJson(Map<String, dynamic> json) {
    return TechStackModel(
      name: json['name'] as String,
      projectCount: json['projectCount'] as int,
      totalStars: json['totalStars'] as int,
      experienceLevel: ExperienceLevel.values
          .firstWhere((e) => e.toString() == json['experienceLevel']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'projectCount': projectCount,
      'totalStars': totalStars,
      'experienceLevel': experienceLevel.toString(),
    };
  }
}

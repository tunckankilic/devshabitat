import 'package:get/get.dart';

enum SkillCategory {
  programming,
  framework,
  database,
  cloud,
  devops,
  design,
  other
}

class SkillModel {
  final String id;
  final String name;
  final SkillCategory category;
  final int proficiency; // 1-5 arası
  final String? iconUrl;
  final bool isVerified;

  SkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.proficiency,
    this.iconUrl,
    this.isVerified = false,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: SkillCategory.values.firstWhere(
        (e) => e.toString() == 'SkillCategory.${json['category']}',
      ),
      proficiency: json['proficiency'] as int,
      iconUrl: json['iconUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.toString().split('.').last,
      'proficiency': proficiency,
      'iconUrl': iconUrl,
      'isVerified': isVerified,
    };
  }
}

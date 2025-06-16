import 'package:flutter/material.dart';

class ConnectionCategoryModel {
  final String id;
  final String name;
  final String description;
  final List<String> connectionIds;
  final Color color;
  final String? icon;
  final Map<String, dynamic>? rules;

  const ConnectionCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.connectionIds,
    required this.color,
    this.icon,
    this.rules,
  });

  // Önceden tanımlanmış kategoriler
  static final List<ConnectionCategoryModel> predefinedCategories = [
    ConnectionCategoryModel(
      id: 'colleague',
      name: 'Çalışma Arkadaşları',
      description: 'Aynı şirkette çalıştığım kişiler',
      connectionIds: [],
      color: Colors.blue,
      icon: 'business',
      rules: {
        'type': 'company_match',
        'field': 'company',
      },
    ),
    ConnectionCategoryModel(
      id: 'mentor',
      name: 'Mentorlar',
      description: 'Deneyimli ve kıdemli profesyoneller',
      connectionIds: [],
      color: Colors.purple,
      icon: 'school',
      rules: {
        'type': 'experience_check',
        'minYears': 5,
        'seniorTitles': [
          'senior',
          'lead',
          'manager',
          'director',
          'cto',
          'ceo',
        ],
      },
    ),
    ConnectionCategoryModel(
      id: 'industry_peer',
      name: 'Sektör Arkadaşları',
      description: 'Benzer alanlarda çalışan profesyoneller',
      connectionIds: [],
      color: Colors.green,
      icon: 'work',
      rules: {
        'type': 'skill_match',
        'minCommonSkills': 3,
      },
    ),
    ConnectionCategoryModel(
      id: 'local',
      name: 'Yerel Bağlantılar',
      description: 'Aynı şehir veya bölgedeki kişiler',
      connectionIds: [],
      color: Colors.orange,
      icon: 'location_on',
      rules: {
        'type': 'location_match',
        'field': 'locationName',
      },
    ),
  ];

  // Factory constructor from map
  factory ConnectionCategoryModel.fromMap(Map<String, dynamic> map) {
    return ConnectionCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      connectionIds: List<String>.from(map['connectionIds'] as List<dynamic>),
      color: Color(map['color'] as int),
      icon: map['icon'] as String?,
      rules: map['rules'] as Map<String, dynamic>?,
    );
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'connectionIds': connectionIds,
      'color': color.value,
      'icon': icon,
      'rules': rules,
    };
  }

  // CopyWith method
  ConnectionCategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? connectionIds,
    Color? color,
    String? icon,
    Map<String, dynamic>? rules,
  }) {
    return ConnectionCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      connectionIds: connectionIds ?? this.connectionIds,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      rules: rules ?? this.rules,
    );
  }

  // Kategori kurallarını kontrol et
  bool matchesRules(Map<String, dynamic> userData) {
    if (rules == null) return false;

    switch (rules!['type']) {
      case 'company_match':
        final userCompany = userData[rules!['field']]?.toString().toLowerCase();
        return userCompany != null && userCompany.isNotEmpty;

      case 'experience_check':
        final yearsOfExperience = userData['yearsOfExperience'] as int? ?? 0;
        final title = userData['title']?.toString().toLowerCase() ?? '';
        final seniorTitles = rules!['seniorTitles'] as List<dynamic>;

        return yearsOfExperience >= (rules!['minYears'] as int) ||
            seniorTitles.any((t) => title.contains(t.toString()));

      case 'skill_match':
        final userSkills = List<String>.from(userData['skills'] as List? ?? []);
        final requiredSkills = rules!['requiredSkills'] as List<dynamic>? ?? [];
        final commonSkills = userSkills
            .toSet()
            .intersection(requiredSkills.map((e) => e.toString()).toSet());

        return commonSkills.length >= (rules!['minCommonSkills'] as int);

      case 'location_match':
        final userLocation =
            userData[rules!['field']]?.toString().toLowerCase();
        return userLocation != null && userLocation.isNotEmpty;

      default:
        return false;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionCategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

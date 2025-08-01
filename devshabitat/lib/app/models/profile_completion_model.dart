/// Profile completion level enum with percentage values
enum ProfileCompletionLevel {
  minimal(15), // Login + email + displayName
  basic(40), // + Bio + Skills (3+)
  standard(70), // + GitHub + Experience + Location
  complete(100); // + Projects + Education + Social links

  const ProfileCompletionLevel(this.percentage);

  final int percentage;

  /// Returns completion level based on percentage
  static ProfileCompletionLevel fromPercentage(double percentage) {
    if (percentage >= 100) return ProfileCompletionLevel.complete;
    if (percentage >= 70) return ProfileCompletionLevel.standard;
    if (percentage >= 40) return ProfileCompletionLevel.basic;
    return ProfileCompletionLevel.minimal;
  }

  /// Returns the next level
  ProfileCompletionLevel? get nextLevel {
    switch (this) {
      case ProfileCompletionLevel.minimal:
        return ProfileCompletionLevel.basic;
      case ProfileCompletionLevel.basic:
        return ProfileCompletionLevel.standard;
      case ProfileCompletionLevel.standard:
        return ProfileCompletionLevel.complete;
      case ProfileCompletionLevel.complete:
        return null;
    }
  }
}

/// Model for tracking profile completion status
class ProfileCompletionStatus {
  final ProfileCompletionLevel level;
  final double percentage;
  final List<String> missingFields;
  final List<String> completedFields;

  const ProfileCompletionStatus({
    required this.level,
    required this.percentage,
    required this.missingFields,
    required this.completedFields,
  });

  factory ProfileCompletionStatus.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionStatus(
      level: ProfileCompletionLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => ProfileCompletionLevel.minimal,
      ),
      percentage: (json['percentage'] as num).toDouble(),
      missingFields: List<String>.from(json['missingFields'] ?? []),
      completedFields: List<String>.from(json['completedFields'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'percentage': percentage,
      'missingFields': missingFields,
      'completedFields': completedFields,
    };
  }

  ProfileCompletionStatus copyWith({
    ProfileCompletionLevel? level,
    double? percentage,
    List<String>? missingFields,
    List<String>? completedFields,
  }) {
    return ProfileCompletionStatus(
      level: level ?? this.level,
      percentage: percentage ?? this.percentage,
      missingFields: missingFields ?? this.missingFields,
      completedFields: completedFields ?? this.completedFields,
    );
  }
}

/// Profile field definitions with weights
class ProfileField {
  final String name;
  final String displayName;
  final int weight;
  final bool isRequired;

  const ProfileField({
    required this.name,
    required this.displayName,
    required this.weight,
    this.isRequired = false,
  });
}

/// Profile completion requirements for each level
class ProfileCompletionRequirements {
  static const List<ProfileField> allFields = [
    // Minimal level fields (15%)
    ProfileField(
        name: 'email', displayName: 'E-posta', weight: 5, isRequired: true),
    ProfileField(
        name: 'displayName',
        displayName: 'Görünen Ad',
        weight: 5,
        isRequired: true),
    ProfileField(
        name: 'uid', displayName: 'Hesap', weight: 5, isRequired: true),

    // Basic level additional fields (25% more = 40% total)
    ProfileField(name: 'bio', displayName: 'Hakkında', weight: 10),
    ProfileField(name: 'skills', displayName: 'Yetenekler (3+)', weight: 15),

    // Standard level additional fields (30% more = 70% total)
    ProfileField(
        name: 'githubUsername', displayName: 'GitHub Profili', weight: 10),
    ProfileField(
        name: 'workExperience', displayName: 'İş Deneyimi', weight: 10),
    ProfileField(name: 'location', displayName: 'Konum', weight: 10),

    // Complete level additional fields (30% more = 100% total)
    ProfileField(name: 'projects', displayName: 'Projeler', weight: 10),
    ProfileField(name: 'education', displayName: 'Eğitim', weight: 10),
    ProfileField(
        name: 'socialLinks',
        displayName: 'Sosyal Medya Bağlantıları',
        weight: 10),
  ];

  /// Get required fields for a specific completion level
  static List<ProfileField> getRequiredFields(ProfileCompletionLevel level) {
    final requiredWeight = level.percentage;
    final fields = <ProfileField>[];
    var currentWeight = 0;

    for (final field in allFields) {
      if (currentWeight < requiredWeight) {
        fields.add(field);
        currentWeight += field.weight;
      } else {
        break;
      }
    }

    return fields;
  }

  /// Get fields required to reach target level from current level
  static List<ProfileField> getMissingFieldsForLevel(
    ProfileCompletionLevel currentLevel,
    ProfileCompletionLevel targetLevel,
  ) {
    final currentFields = getRequiredFields(currentLevel);
    final targetFields = getRequiredFields(targetLevel);

    return targetFields
        .where((field) => !currentFields.contains(field))
        .toList();
  }
}

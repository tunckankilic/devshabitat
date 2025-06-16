import '../models/enhanced_user_model.dart';

class ConnectionScoringAlgorithm {
  // Ağırlık faktörleri
  static const double _skillWeight = 0.4;
  static const double _experienceWeight = 0.3;
  static const double _locationWeight = 0.2;
  static const double _companyWeight = 0.1;

  /// Ana puanlama metodunu çağırır ve ağırlıklı skoru hesaplar
  static double calculateConnectionScore(
    EnhancedUserModel user1,
    EnhancedUserModel user2,
  ) {
    final skillScore = calculateSkillMatch(
      user1.skills ?? [],
      user2.skills ?? [],
    );

    final experienceScore = calculateExperienceMatch(
      user1.experience ?? [],
      user2.experience ?? [],
    );

    final locationScore = calculateLocationMatch(
      _extractLocations(user1.experience ?? []),
      _extractLocations(user2.experience ?? []),
    );

    final companyScore = calculateCompanyMatch(
      _extractCompanies(user1.experience ?? []),
      _extractCompanies(user2.experience ?? []),
    );

    // Ağırlıklı toplam skoru hesapla
    return (skillScore * _skillWeight) +
        (experienceScore * _experienceWeight) +
        (locationScore * _locationWeight) +
        (companyScore * _companyWeight);
  }

  /// Jaccard benzerlik algoritması ile yetenek eşleşme skorunu hesaplar
  static double calculateSkillMatch(
      List<String> skills1, List<String> skills2) {
    if (skills1.isEmpty && skills2.isEmpty) return 0.0;

    final set1 = skills1.toSet();
    final set2 = skills2.toSet();

    final intersection = set1.intersection(set2);
    final union = set1.union(set2);

    return intersection.length / union.length;
  }

  /// Deneyim eşleşme skorunu hesaplar
  static double calculateExperienceMatch(
    List<Map<String, dynamic>> exp1,
    List<Map<String, dynamic>> exp2,
  ) {
    if (exp1.isEmpty || exp2.isEmpty) return 0.0;

    final roles1 =
        exp1.map((e) => e['role'] as String?).where((e) => e != null).toSet();
    final roles2 =
        exp2.map((e) => e['role'] as String?).where((e) => e != null).toSet();

    if (roles1.isEmpty || roles2.isEmpty) return 0.0;

    final intersection = roles1.intersection(roles2);
    final union = roles1.union(roles2);

    return intersection.length / union.length;
  }

  /// Lokasyon eşleşme skorunu hesaplar
  static double calculateLocationMatch(
      Set<String> locations1, Set<String> locations2) {
    if (locations1.isEmpty || locations2.isEmpty) return 0.0;

    final intersection = locations1.intersection(locations2);
    final union = locations1.union(locations2);

    return intersection.length / union.length;
  }

  /// Şirket eşleşme skorunu hesaplar
  static double calculateCompanyMatch(
      Set<String> companies1, Set<String> companies2) {
    if (companies1.isEmpty || companies2.isEmpty) return 0.0;

    final intersection = companies1.intersection(companies2);
    final union = companies1.union(companies2);

    return intersection.length / union.length;
  }

  /// Deneyimlerden lokasyonları çıkarır
  static Set<String> _extractLocations(List<Map<String, dynamic>> experience) {
    return experience
        .map((e) => e['location'] as String?)
        .where((e) => e != null)
        .toSet()
        .cast<String>();
  }

  /// Deneyimlerden şirketleri çıkarır
  static Set<String> _extractCompanies(List<Map<String, dynamic>> experience) {
    return experience
        .map((e) => e['company'] as String?)
        .where((e) => e != null)
        .toSet()
        .cast<String>();
  }
}

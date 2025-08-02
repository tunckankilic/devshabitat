import 'dart:math' as math;
import '../models/enhanced_user_model.dart';
import '../models/user_profile_model.dart';
import '../models/connection_model.dart';

class ConnectionScoringAlgorithm {
  static double calculateConnectionScore(
    EnhancedUserModel user1,
    EnhancedUserModel user2,
  ) {
    double score = 0.0;
    double totalWeight = 0.0;

    // Yetenek uyumu (40%)
    if (user1.skills != null && user2.skills != null) {
      final commonSkills =
          user1.skills!.toSet().intersection(user2.skills!.toSet());
      score += (commonSkills.length /
              math.max(user1.skills!.length, user2.skills!.length)) *
          0.4;
      totalWeight += 0.4;
    }

    // Deneyim seviyesi uyumu (30%)
    if (user1.yearsOfExperience != 0 && user2.yearsOfExperience != 0) {
      final expDiff = (user1.yearsOfExperience - user2.yearsOfExperience).abs();
      score += (1 - (expDiff / 10).clamp(0.0, 1.0)) * 0.3;
      totalWeight += 0.3;
    }

    // Konum uyumu (30%)
    if (user1.location != null && user2.location != null) {
      final distance = calculateDistance(
        lat1: user1.location!.latitude,
        lon1: user1.location!.longitude,
        lat2: user2.location!.latitude,
        lon2: user2.location!.longitude,
      );
      score += (1 - (distance / 100).clamp(0.0, 1.0)) * 0.3;
      totalWeight += 0.3;
    }

    return totalWeight > 0 ? (score / totalWeight).clamp(0.0, 1.0) : 0.0;
  }

  double calculateScore({
    required UserProfile userProfile,
    required ConnectionModel connection,
    List<String>? preferredSkills,
  }) {
    // Basit bir skor hesaplama
    double score = 0.0;
    double totalWeight = 0.0;

    // Tercih edilen yeteneklere göre skor (70%)
    if (preferredSkills != null && preferredSkills.isNotEmpty) {
      final matchingSkills = userProfile.skills
          .where((skill) => preferredSkills.contains(skill))
          .length;
      score += matchingSkills / preferredSkills.length * 0.7;
      totalWeight += 0.7;
    }

    // Konum uyumu (30%)
    if (userProfile.location != null && connection.location != null) {
      final distance = calculateDistance(
        lat1: userProfile.location!.latitude,
        lon1: userProfile.location!.longitude,
        lat2: connection.location!.latitude,
        lon2: connection.location!.longitude,
      );
      score += (1 - (distance / 100).clamp(0.0, 1.0)) * 0.3;
      totalWeight += 0.3;
    }

    return totalWeight > 0 ? (score / totalWeight).clamp(0.0, 1.0) : 0.0;
  }

  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadius = 6371; // km
    final lat1Rad = lat1 * math.pi / 180;
    final lat2Rad = lat2 * math.pi / 180;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }
}

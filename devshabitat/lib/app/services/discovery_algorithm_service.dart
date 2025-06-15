import 'dart:math' as math;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_profile_model.dart';
import '../models/search_filter_model.dart';

class DiscoveryAlgorithmService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const double SKILL_WEIGHT = 0.4;
  static const double LOCATION_WEIGHT = 0.3;
  static const double EXPERIENCE_WEIGHT = 0.3;

  /// İki kullanıcı arasındaki genel uyumluluk puanını hesaplar
  double calculateUserCompatibility(UserProfile user1, UserProfile user2) {
    double score = 0.0;
    double totalWeight = 0.0;

    // Yetenek uyumu (Ağırlık: 0.4)
    final skillMatch = _calculateSkillMatch(user1.skills, user2.skills);
    score += skillMatch * 0.4;
    totalWeight += 0.4;

    // Deneyim seviyesi uyumu (Ağırlık: 0.2)
    final experienceMatch = _calculateExperienceMatch(
      user1.yearsOfExperience,
      user2.yearsOfExperience,
    );
    score += experienceMatch * 0.2;
    totalWeight += 0.2;

    // İlgi alanları uyumu (Ağırlık: 0.2)
    final interestMatch = _calculateInterestMatch(
      user1.interests,
      user2.interests,
    );
    score += interestMatch * 0.2;
    totalWeight += 0.2;

    // Konum uyumu (Ağırlık: 0.1)
    if (user1.location != null && user2.location != null) {
      final locationMatch = _calculateLocationMatch(
        user1.location!,
        user2.location!,
      );
      score += locationMatch * 0.1;
      totalWeight += 0.1;
    }

    // Dil uyumu (Ağırlık: 0.1)
    final languageMatch = _calculateLanguageMatch(
      user1.languages,
      user2.languages,
    );
    score += languageMatch * 0.1;
    totalWeight += 0.1;

    // Toplam puanı normalize et
    return totalWeight > 0 ? score / totalWeight : 0.0;
  }

  /// Jaccard benzerlik algoritması kullanarak beceri eşleşme puanını hesaplar
  double getSkillMatchScore(List<String> skills1, List<String> skills2) {
    if (skills1.isEmpty || skills2.isEmpty) return 0.0;

    var set1 = skills1.map((s) => s.toLowerCase()).toSet();
    var set2 = skills2.map((s) => s.toLowerCase()).toSet();

    var intersection = set1.intersection(set2);
    var union = set1.union(set2);

    return intersection.length / union.length;
  }

  /// İki konum arasındaki benzerlik puanını hesaplar
  double getLocationScore(String loc1, String loc2) {
    if (loc1.isEmpty || loc2.isEmpty) return 0.0;

    // Basit string karşılaştırması
    if (loc1.toLowerCase() == loc2.toLowerCase()) return 1.0;

    // Şehir bazlı karşılaştırma
    var city1 = _extractCity(loc1);
    var city2 = _extractCity(loc2);
    if (city1 == city2) return 0.8;

    // Ülke bazlı karşılaştırma
    var country1 = _extractCountry(loc1);
    var country2 = _extractCountry(loc2);
    if (country1 == country2) return 0.5;

    return 0.0;
  }

  /// Deneyim yılları arasındaki uyumluluk puanını hesaplar
  double getExperienceScore(int exp1, int exp2) {
    final maxExperience = 40; // Maksimum deneyim yılı
    final difference = (exp1 - exp2).abs();

    // Deneyim farkı arttıkça puan azalır
    return math.max(0.0, 1.0 - (difference / maxExperience));
  }

  /// Mevcut kullanıcıya en benzer kullanıcıları bulur
  List<UserProfile> getSimilarUsers(
    UserProfile currentUser,
    List<UserProfile> users, {
    int limit = 10,
    double minScore = 0.3,
  }) {
    // Kendisini listeden çıkar
    users = users.where((u) => u.id != currentUser.id).toList();

    // Her kullanıcı için uyumluluk puanını hesapla
    var scoredUsers = users
        .map((user) {
          return _ScoredUser(
            user: user,
            score: calculateUserCompatibility(currentUser, user),
          );
        })
        .where((su) => su.score >= minScore)
        .toList();

    // Puana göre sırala ve en yüksek puanlıları döndür
    scoredUsers.sort((a, b) => b.score.compareTo(a.score));
    return scoredUsers.take(limit).map((su) => su.user).toList();
  }

  String _extractCity(String location) {
    return location.split(',')[0].trim().toLowerCase();
  }

  String _extractCountry(String location) {
    var parts = location.split(',');
    return parts.length > 1 ? parts.last.trim().toLowerCase() : '';
  }

  Future<List<UserProfile>> getRecommendedUsers({
    required String userId,
    required SearchFilterModel filters,
  }) async {
    try {
      // Kullanıcının profilini al
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final currentUser = UserProfile.fromFirestore(userDoc);

      // Filtrelere göre sorgu oluştur
      Query query =
          _firestore.collection('users').where('id', isNotEqualTo: userId);

      // Yetenek filtreleri
      if (filters.skills.isNotEmpty) {
        query = query.where('skills', arrayContainsAny: filters.skills);
      }

      // Konum filtresi
      if (filters.location != null && filters.maxDistance != null) {
        final GeoPoint userLocation = filters.location!;
        final double latRange = filters.maxDistance! / 111.0; // km to degrees
        final double lonRange = filters.maxDistance! /
            (111.0 * math.cos(userLocation.latitude * math.pi / 180));

        query = query
            .where('location.latitude',
                isGreaterThanOrEqualTo: userLocation.latitude - latRange)
            .where('location.latitude',
                isLessThanOrEqualTo: userLocation.latitude + latRange);
      }

      // Deneyim filtresi
      if (filters.minExperience != null) {
        query = query.where('yearsOfExperience',
            isGreaterThanOrEqualTo: filters.minExperience);
      }
      if (filters.maxExperience != null) {
        query = query.where('yearsOfExperience',
            isLessThanOrEqualTo: filters.maxExperience);
      }

      // Sorguyu çalıştır ve sonuçları al
      final querySnapshot = await query.limit(20).get();
      final users = querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();

      // Kullanıcıları uyumluluk puanına göre sırala
      users.sort((a, b) {
        final scoreA = calculateUserCompatibility(currentUser, a);
        final scoreB = calculateUserCompatibility(currentUser, b);
        return scoreB.compareTo(scoreA);
      });

      return users;
    } catch (e) {
      print('Error getting recommended users: $e');
      return [];
    }
  }

  Future<double> _calculateUserScore({
    required UserProfile currentUser,
    required UserProfile candidateUser,
    required List<String> connectedUserIds,
  }) async {
    double score = 0.0;

    // Ortak yetenekler için puan
    final commonSkills = currentUser.skills
        .where((skill) => candidateUser.skills.contains(skill))
        .length;
    score += commonSkills * 2.0;

    // Ortak ilgi alanları için puan
    final commonInterests = currentUser.interests
        .where((interest) => candidateUser.interests.contains(interest))
        .length;
    score += commonInterests * 1.5;

    // Aynı lokasyon için puan
    if (currentUser.location == candidateUser.location) {
      score += 3.0;
    }

    // Aynı şirket için puan
    if (currentUser.company == candidateUser.company) {
      score += 2.0;
    }

    // Ortak bağlantılar için puan
    final candidateConnections = await _firestore
        .collection('connections')
        .where('fromUserId', isEqualTo: candidateUser.id)
        .where('status', isEqualTo: 'accepted')
        .get();

    final candidateConnectedUserIds = candidateConnections.docs
        .map((doc) => doc.data()['toUserId'] as String)
        .toList();

    final commonConnections = connectedUserIds
        .where((id) => candidateConnectedUserIds.contains(id))
        .length;
    score += commonConnections * 1.0;

    // Aktiflik durumu için puan
    if (candidateUser.isOnline) {
      score += 1.0;
    }

    return score;
  }

  double _calculateSkillMatch(List<String> skills1, List<String> skills2) {
    if (skills1.isEmpty || skills2.isEmpty) return 0.0;

    final commonSkills = skills1.toSet().intersection(skills2.toSet());
    return commonSkills.length / math.max(skills1.length, skills2.length);
  }

  double _calculateExperienceMatch(int years1, int years2) {
    final diff = (years1 - years2).abs();
    // 5 yıl veya daha fazla fark varsa uyum düşük
    if (diff >= 5) return 0.2;
    // 3-4 yıl fark varsa orta uyum
    if (diff >= 3) return 0.5;
    // 1-2 yıl fark varsa yüksek uyum
    if (diff >= 1) return 0.8;
    // Aynı deneyim yılı en yüksek uyum
    return 1.0;
  }

  double _calculateInterestMatch(
      List<String> interests1, List<String> interests2) {
    if (interests1.isEmpty || interests2.isEmpty) return 0.0;

    final commonInterests = interests1.toSet().intersection(interests2.toSet());
    return commonInterests.length /
        math.max(interests1.length, interests2.length);
  }

  double _calculateLocationMatch(GeoPoint location1, GeoPoint location2) {
    // Haversine formülü ile mesafe hesapla
    final distance = _calculateDistance(
      location1.latitude,
      location1.longitude,
      location2.latitude,
      location2.longitude,
    );

    // 50km'den uzaksa düşük uyum
    if (distance > 50) return 0.2;
    // 20-50km arası orta uyum
    if (distance > 20) return 0.5;
    // 5-20km arası yüksek uyum
    if (distance > 5) return 0.8;
    // 5km veya daha yakın en yüksek uyum
    return 1.0;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371.0; // Dünya yarıçapı (km)
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  double _calculateLanguageMatch(
      List<String> languages1, List<String> languages2) {
    if (languages1.isEmpty || languages2.isEmpty) return 0.0;

    final commonLanguages = languages1.toSet().intersection(languages2.toSet());
    return commonLanguages.length /
        math.max(languages1.length, languages2.length);
  }
}

class _ScoredUser {
  final UserProfile user;
  final double score;

  _ScoredUser({required this.user, required this.score});
}

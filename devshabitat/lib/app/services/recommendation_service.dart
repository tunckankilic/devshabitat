import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/user_profile_model.dart';
import '../models/blog_model.dart';
import '../models/community/community_model.dart';
import '../models/event/event_model.dart';
import '../core/services/error_handler_service.dart';
import '../repositories/auth_repository.dart';

class RecommendationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Kullanıcı önerileri
  Future<List<UserProfile>> getUserRecommendations({int limit = 10}) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return [];

      // Kullanıcının profilini al
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      final userSkills = List<String>.from(userData['skills'] ?? []);
      final userInterests = List<String>.from(userData['interests'] ?? []);

      // Benzer skill'lere sahip kullanıcıları bul
      final recommendations = <UserProfile>[];

      if (userSkills.isNotEmpty) {
        final skillBasedUsers = await _getUsersBySkills(userSkills, limit);
        recommendations.addAll(skillBasedUsers);
      }

      if (userInterests.isNotEmpty && recommendations.length < limit) {
        final interestBasedUsers = await _getUsersByInterests(
          userInterests,
          limit - recommendations.length,
        );
        recommendations.addAll(interestBasedUsers);
      }

      // Mevcut bağlantıları çıkar
      final connections = await _getUserConnections(currentUser.uid);
      recommendations.removeWhere(
        (user) => connections.contains(user.id) || user.id == currentUser.uid,
      );

      // Skor bazında sırala
      recommendations.sort(
        (a, b) => _calculateUserScore(
          b,
          userSkills,
          userInterests,
        ).compareTo(_calculateUserScore(a, userSkills, userInterests)),
      );

      return recommendations.take(limit).toList();
    } catch (e) {
      _logger.e('Kullanıcı önerisi hatası: $e');
      _errorHandler.handleError(
        'Öneriler yüklenemedi: $e',
        'USER_RECOMMENDATION_ERROR',
      );
      return [];
    }
  }

  // Blog önerileri
  Future<List<BlogModel>> getBlogRecommendations({int limit = 20}) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return [];

      // Kullanıcının ilgi alanlarını al
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      final userSkills = List<String>.from(userData['skills'] ?? []);
      final userInterests = List<String>.from(userData['interests'] ?? []);

      // Okunmuş blog'ları al
      final readBlogs = await _getUserReadBlogs(currentUser.uid);

      final recommendations = <BlogModel>[];

      // Skill bazlı blog'lar
      if (userSkills.isNotEmpty) {
        final skillBlogs = await _getBlogsByTags(userSkills, limit);
        recommendations.addAll(skillBlogs);
      }

      // İlgi alanı bazlı blog'lar
      if (userInterests.isNotEmpty && recommendations.length < limit) {
        final interestBlogs = await _getBlogsByTags(
          userInterests,
          limit - recommendations.length,
        );
        recommendations.addAll(interestBlogs);
      }

      // Popüler blog'lar
      if (recommendations.length < limit) {
        final popularBlogs = await _getPopularBlogs(
          limit - recommendations.length,
        );
        recommendations.addAll(popularBlogs);
      }

      // Okunmuş blog'ları çıkar
      recommendations.removeWhere((blog) => readBlogs.contains(blog.id));

      // Skor bazında sırala
      recommendations.sort(
        (a, b) => _calculateBlogScore(
          b,
          userSkills,
          userInterests,
        ).compareTo(_calculateBlogScore(a, userSkills, userInterests)),
      );

      return recommendations.take(limit).toList();
    } catch (e) {
      _logger.e('Blog önerisi hatası: $e');
      _errorHandler.handleError(
        'Blog önerileri yüklenemedi: $e',
        'BLOG_RECOMMENDATION_ERROR',
      );
      return [];
    }
  }

  // Topluluk önerileri
  Future<List<CommunityModel>> getCommunityRecommendations({
    int limit = 10,
  }) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return [];

      // Kullanıcının mevcut topluluklarını al
      final userCommunities = await _getUserCommunities(currentUser.uid);

      // Kullanıcının profilini al
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      final userSkills = List<String>.from(userData['skills'] ?? []);

      final recommendations = <CommunityModel>[];

      // Skill bazlı topluluklar
      if (userSkills.isNotEmpty) {
        final skillCommunities = await _getCommunitiesBySkills(
          userSkills,
          limit,
        );
        recommendations.addAll(skillCommunities);
      }

      // Popüler topluluklar
      if (recommendations.length < limit) {
        final popularCommunities = await _getPopularCommunities(
          limit - recommendations.length,
        );
        recommendations.addAll(popularCommunities);
      }

      // Mevcut topluluklarını çıkar
      recommendations.removeWhere(
        (community) => userCommunities.contains(community.id),
      );

      // Skor bazında sırala
      recommendations.sort(
        (a, b) => _calculateCommunityScore(
          b,
          userSkills,
        ).compareTo(_calculateCommunityScore(a, userSkills)),
      );

      return recommendations.take(limit).toList();
    } catch (e) {
      _logger.e('Topluluk önerisi hatası: $e');
      _errorHandler.handleError(
        'Topluluk önerileri yüklenemedi: $e',
        'COMMUNITY_RECOMMENDATION_ERROR',
      );
      return [];
    }
  }

  // Etkinlik önerileri
  Future<List<EventModel>> getEventRecommendations({int limit = 15}) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return [];

      // Kullanıcının profilini al
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      final userSkills = List<String>.from(userData['skills'] ?? []);
      final userLocation = userData['location'] as Map<String, dynamic>?;

      final recommendations = <EventModel>[];

      // Yakın etkinlikler (lokasyon varsa)
      if (userLocation != null) {
        final nearbyEvents = await _getNearbyEvents(
          userLocation['latitude'],
          userLocation['longitude'],
          limit,
        );
        recommendations.addAll(nearbyEvents);
      }

      // Skill bazlı etkinlikler
      if (userSkills.isNotEmpty && recommendations.length < limit) {
        final skillEvents = await _getEventsBySkills(
          userSkills,
          limit - recommendations.length,
        );
        recommendations.addAll(skillEvents);
      }

      // Popüler etkinlikler
      if (recommendations.length < limit) {
        final popularEvents = await _getPopularEvents(
          limit - recommendations.length,
        );
        recommendations.addAll(popularEvents);
      }

      // Gelecek tarihli etkinlikleri filtrele
      final now = DateTime.now();
      recommendations.removeWhere((event) => event.startDate.isBefore(now));

      // Skor bazında sırala
      recommendations.sort(
        (a, b) => _calculateEventScore(
          b,
          userSkills,
          userLocation,
        ).compareTo(_calculateEventScore(a, userSkills, userLocation)),
      );

      return recommendations.take(limit).toList();
    } catch (e) {
      _logger.e('Etkinlik önerisi hatası: $e');
      _errorHandler.handleError(
        'Etkinlik önerileri yüklenemedi: $e',
        'EVENT_RECOMMENDATION_ERROR',
      );
      return [];
    }
  }

  // Skill bazlı kullanıcı arama
  Future<List<UserProfile>> _getUsersBySkills(
    List<String> skills,
    int limit,
  ) async {
    final query = await _firestore
        .collection('users')
        .where('skills', arrayContainsAny: skills)
        .limit(limit * 2) // Fazla al, sonra filtrele
        .get();

    return query.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
  }

  // İlgi alanı bazlı kullanıcı arama
  Future<List<UserProfile>> _getUsersByInterests(
    List<String> interests,
    int limit,
  ) async {
    final query = await _firestore
        .collection('users')
        .where('interests', arrayContainsAny: interests)
        .limit(limit * 2)
        .get();

    return query.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
  }

  // Tag bazlı blog arama
  Future<List<BlogModel>> _getBlogsByTags(List<String> tags, int limit) async {
    final query = await _firestore
        .collection('blogs')
        .where('tags', arrayContainsAny: tags)
        .where('isPublished', isEqualTo: true)
        .limit(limit * 2)
        .get();

    return query.docs
        .map((doc) => BlogModel.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Popüler blog'ları al
  Future<List<BlogModel>> _getPopularBlogs(int limit) async {
    final query = await _firestore
        .collection('blogs')
        .where('isPublished', isEqualTo: true)
        .orderBy('viewCount', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => BlogModel.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Kullanıcı skor hesaplama
  double _calculateUserScore(
    UserProfile user,
    List<String> userSkills,
    List<String> userInterests,
  ) {
    double score = 0;

    // Skill eşleşmesi
    final commonSkills = user.skills.where(userSkills.contains).length;
    score += commonSkills * 10;

    // İlgi alanı eşleşmesi
    // final commonInterests = user.interests.where(userInterests.contains).length;
    // score += commonInterests * 5;

    // Deneyim seviyesi
    score += user.yearsOfExperience * 2;

    return score;
  }

  // Blog skor hesaplama
  double _calculateBlogScore(
    BlogModel blog,
    List<String> userSkills,
    List<String> userInterests,
  ) {
    double score = 0;

    // Tag eşleşmesi
    final commonTags = blog.tags
        .where((tag) => userSkills.contains(tag) || userInterests.contains(tag))
        .length;
    score += commonTags * 10;

    // Popülerlik
    score += blog.viewCount * 0.1;
    score += blog.likeCount * 2;

    // Güncellik (yeni blog'lara bonus)
    final daysSincePublished = DateTime.now()
        .difference(blog.publishedAt ?? DateTime.now())
        .inDays;
    if (daysSincePublished < 7) {
      score += 20;
    } else if (daysSincePublished < 30) {
      score += 10;
    }

    return score;
  }

  // Topluluk skor hesaplama
  double _calculateCommunityScore(
    CommunityModel community,
    List<String> userSkills,
  ) {
    double score = 0;

    // Üye sayısı
    score += community.memberCount * 0.1;

    // Aktiflik
    score += community.postCount * 0.5;

    return score;
  }

  // Etkinlik skor hesaplama
  double _calculateEventScore(
    EventModel event,
    List<String> userSkills,
    Map<String, dynamic>? userLocation,
  ) {
    double score = 0;

    // Yakınlık (lokasyon varsa)
    if (userLocation != null && event.location != null) {
      final distance = _calculateDistance(
        userLocation['latitude'],
        userLocation['longitude'],
        event.location!.latitude,
        event.location!.longitude,
      );
      score += (100 - distance).clamp(0, 100); // Yakın olana bonus
    }

    // Katılımcı sayısı
    score += event.participants.length * 2;

    return score;
  }

  // Helper methodlar
  Future<List<String>> _getUserConnections(String userId) async {
    final snapshot = await _firestore
        .collection('connections')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['targetUserId'] as String)
        .toList();
  }

  Future<List<String>> _getUserReadBlogs(String userId) async {
    final snapshot = await _firestore
        .collection('user_interactions')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'blog_read')
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['contentId'] as String)
        .toList();
  }

  Future<List<String>> _getUserCommunities(String userId) async {
    final snapshot = await _firestore
        .collection('community_members')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['communityId'] as String)
        .toList();
  }

  Future<List<CommunityModel>> _getCommunitiesBySkills(
    List<String> skills,
    int limit,
  ) async {
    final query = await _firestore
        .collection('communities')
        .where('tags', arrayContainsAny: skills)
        .limit(limit)
        .get();

    return query.docs.map((doc) => CommunityModel.fromFirestore(doc)).toList();
  }

  Future<List<CommunityModel>> _getPopularCommunities(int limit) async {
    final query = await _firestore
        .collection('communities')
        .orderBy('memberCount', descending: true)
        .limit(limit)
        .get();

    return query.docs.map((doc) => CommunityModel.fromFirestore(doc)).toList();
  }

  Future<List<EventModel>> _getNearbyEvents(
    double lat,
    double lng,
    int limit,
  ) async {
    // Basit mesafe hesabı için koordinat aralığı
    const radiusKm = 50;
    final latRange = radiusKm / 111.0;

    final query = await _firestore
        .collection('events')
        .where('latitude', isGreaterThan: lat - latRange)
        .where('latitude', isLessThan: lat + latRange)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => EventModel.fromMap({...doc.data(), 'id': doc.id}))
        .where((event) {
          if (event.location == null) return false;
          final distance = _calculateDistance(
            lat,
            lng,
            event.location!.latitude,
            event.location!.longitude,
          );
          return distance <= radiusKm;
        })
        .toList();
  }

  Future<List<EventModel>> _getEventsBySkills(
    List<String> skills,
    int limit,
  ) async {
    final query = await _firestore
        .collection('events')
        .where('tags', arrayContainsAny: skills)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => EventModel.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<List<EventModel>> _getPopularEvents(int limit) async {
    final query = await _firestore
        .collection('events')
        .orderBy('participantCount', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => EventModel.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Mesafe hesaplama
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // km

    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }
}

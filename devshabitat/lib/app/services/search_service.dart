import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/search_result_model.dart';
import '../models/user_profile_model.dart' show UserProfile;
import '../models/blog_model.dart';
import '../models/community/community_model.dart';
import '../models/event/event_model.dart';
import '../core/services/error_handler_service.dart';

class SearchService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();

  // Genel arama
  Future<SearchResultModel> globalSearch(
    String query, {
    List<String> types = const ['users', 'blogs', 'communities', 'events'],
    int limit = 20,
  }) async {
    try {
      final results = SearchResultModel(
        query: query,
        users: [],
        blogs: [],
        communities: [],
        events: [],
        totalResults: 0,
      );

      // Paralel arama işlemleri
      final futures = <Future>[];

      if (types.contains('users')) {
        futures.add(
          _searchUsers(query, limit).then((users) => results.users = users),
        );
      }

      if (types.contains('blogs')) {
        futures.add(
          _searchBlogs(query, limit).then((blogs) => results.blogs = blogs),
        );
      }

      if (types.contains('communities')) {
        futures.add(
          _searchCommunities(
            query,
            limit,
          ).then((communities) => results.communities = communities),
        );
      }

      if (types.contains('events')) {
        futures.add(
          _searchEvents(query, limit).then((events) => results.events = events),
        );
      }

      await Future.wait(futures);

      results.totalResults =
          results.users.length +
          results.blogs.length +
          results.communities.length +
          results.events.length;

      return results;
    } catch (e) {
      _logger.e('Genel arama hatası: $e');
      _errorHandler.handleError('Arama işlemi başarısız: $e', 'SEARCH_ERROR');
      return SearchResultModel(
        query: query,
        users: [],
        blogs: [],
        communities: [],
        events: [],
        totalResults: 0,
      );
    }
  }

  // Kullanıcı arama
  Future<List<UserProfile>> _searchUsers(String query, int limit) async {
    try {
      // İsim ve kullanıcı adına göre arama
      final nameQuery = _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: '${query}z')
          .limit(limit ~/ 2);

      final usernameQuery = _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('username', isLessThan: '${query.toLowerCase()}z')
          .limit(limit ~/ 2);

      final results = await Future.wait([nameQuery.get(), usernameQuery.get()]);

      final users = <UserProfile>[];
      final addedIds = <String>{};

      for (final snapshot in results) {
        for (final doc in snapshot.docs) {
          if (!addedIds.contains(doc.id)) {
            users.add(UserProfile.fromFirestore(doc));
            addedIds.add(doc.id);
          }
        }
      }

      return users.take(limit).toList();
    } catch (e) {
      _logger.e('Kullanıcı arama hatası: $e');
      return [];
    }
  }

  // Blog arama
  Future<List<BlogModel>> _searchBlogs(String query, int limit) async {
    try {
      final titleQuery = _firestore
          .collection('blogs')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .where('isPublished', isEqualTo: true)
          .limit(limit);

      final snapshot = await titleQuery.get();

      return snapshot.docs
          .map((doc) => BlogModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      _logger.e('Blog arama hatası: $e');
      return [];
    }
  }

  // Topluluk arama
  Future<List<CommunityModel>> _searchCommunities(
    String query,
    int limit,
  ) async {
    try {
      final nameQuery = _firestore
          .collection('communities')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(limit);

      final snapshot = await nameQuery.get();

      return snapshot.docs
          .map((doc) => CommunityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.e('Topluluk arama hatası: $e');
      return [];
    }
  }

  // Etkinlik arama
  Future<List<EventModel>> _searchEvents(String query, int limit) async {
    try {
      final titleQuery = _firestore
          .collection('events')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .where('isActive', isEqualTo: true)
          .limit(limit);

      final snapshot = await titleQuery.get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      _logger.e('Etkinlik arama hatası: $e');
      return [];
    }
  }

  // Skill bazlı kullanıcı arama
  Future<List<UserProfile>> searchUsersBySkills(
    List<String> skills,
    int limit,
  ) async {
    try {
      final query = _firestore
          .collection('users')
          .where('skills', arrayContainsAny: skills)
          .limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.e('Skill bazlı arama hatası: $e');
      return [];
    }
  }

  // Tag bazlı blog arama
  Future<List<BlogModel>> searchBlogsByTags(
    List<String> tags,
    int limit,
  ) async {
    try {
      final query = _firestore
          .collection('blogs')
          .where('tags', arrayContainsAny: tags)
          .where('isPublished', isEqualTo: true)
          .limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => BlogModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      _logger.e('Tag bazlı blog arama hatası: $e');
      return [];
    }
  }

  // Yakın etkinlik arama
  Future<List<EventModel>> searchNearbyEvents(
    double latitude,
    double longitude,
    double radiusKm,
    int limit,
  ) async {
    try {
      // Basit mesafe hesabı için koordinat aralığı
      final latRange = radiusKm / 111.0; // Yaklaşık 1 derece = 111 km

      final query = _firestore
          .collection('events')
          .where('latitude', isGreaterThan: latitude - latRange)
          .where('latitude', isLessThan: latitude + latRange)
          .where('isActive', isEqualTo: true)
          .limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap({...doc.data(), 'id': doc.id}))
          .where((event) {
            if (event.location == null) return false;

            final distance = _calculateDistance(
              latitude,
              longitude,
              event.location!.latitude,
              event.location!.longitude,
            );

            return distance <= radiusKm;
          })
          .toList();
    } catch (e) {
      _logger.e('Yakın etkinlik arama hatası: $e');
      return [];
    }
  }

  // Mesafe hesaplama (Haversine formülü)
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

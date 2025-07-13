import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import '../models/search_filter_model.dart';
import '../models/connection_model.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user_profile_model.dart';
import 'discovery_algorithm_service.dart';
import '../core/services/api_optimization_service.dart';

class DiscoveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiOptimizationService _apiOptimizer =
      Get.find<ApiOptimizationService>();
  final StreamController<Map<String, bool>> _onlineStatusController =
      StreamController<Map<String, bool>>.broadcast();
  final DiscoveryAlgorithmService _algorithmService =
      DiscoveryAlgorithmService();

  // Cache constants

  // Collections
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _connectionsCollection =>
      _firestore.collection('connections');
  CollectionReference get _userAnalyticsCollection =>
      _firestore.collection('user_analytics');

  // Dispose method to prevent memory leaks
  void dispose() {
    if (!_onlineStatusController.isClosed) {
      _onlineStatusController.close();
    }
  }

  // Konum hesaplama yardımcı fonksiyonları
  double _calculateDistance(GeoPoint point1, GeoPoint point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  bool _isWithinRadius(GeoPoint center, GeoPoint point, double radiusInKm) {
    final distanceInMeters = _calculateDistance(center, point);
    return distanceInMeters <= (radiusInKm * 1000);
  }

  // Search users with filters
  Stream<List<UserProfile>> searchUsersWithFilters(SearchFilterModel filters) {
    Query query = _usersCollection.limit(20);

    // Apply text search filter
    if (filters.name.isNotEmpty) {
      query = query.where('searchKeywords',
          arrayContains: filters.name.toLowerCase());
    }

    // Apply skills filter with fuzzy matching
    if (filters.skills.isNotEmpty) {
      query = query.where('skills', arrayContainsAny: filters.skills);
    }

    // Apply location filter
    if (filters.location != null && filters.maxDistance != null) {
      final center = GeoPoint(
        filters.location!.latitude,
        filters.location!.longitude,
      );

      // Konum filtresini manuel olarak uygula
      return query.snapshots().map((snapshot) {
        final users = snapshot.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .where((user) {
          if (user.location == null) return false;
          return _isWithinRadius(
            center,
            user.location!,
            filters.maxDistance!.toDouble(),
          );
        }).toList();

        return users;
      });
    }

    // Apply experience filter
    if (filters.minExperience != null) {
      query = query.where('experienceYears',
          isGreaterThanOrEqualTo: filters.minExperience);
    }
    if (filters.maxExperience != null) {
      query = query.where('experienceYears',
          isLessThanOrEqualTo: filters.maxExperience);
    }

    // Apply work type filters
    if (filters.isRemote) {
      query = query.where('isRemote', isEqualTo: true);
    }
    if (filters.isFullTime) {
      query = query.where('isFullTime', isEqualTo: true);
    }
    if (filters.isPartTime) {
      query = query.where('isPartTime', isEqualTo: true);
    }
    if (filters.isFreelance) {
      query = query.where('isFreelance', isEqualTo: true);
    }
    if (filters.isInternship) {
      query = query.where('isInternship', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList());
  }

  // Get recommended users
  Future<List<UserProfile>> getRecommendedUsers(String userId) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
        // Get user's profile for matching
        final userDoc = await _usersCollection.doc(userId).get();
        final userData = userDoc.data() as Map<String, dynamic>;

        // Get users with similar interests and skills
        final query = _usersCollection
            .where('skills', arrayContainsAny: userData['skills'] ?? [])
            .where('id', isNotEqualTo: userId)
            .limit(20);

        final recommendedUsers = await query.get();
        final results = recommendedUsers.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .toList();

        return results;
      },
      cacheKey: 'recommended_users_$userId',
      cacheDuration: const Duration(minutes: 30),
    );
  }

  // Send connection request
  Future<bool> sendConnectionRequest(String recipientId, String message) async {
    return await _apiOptimizer.retryApiCall(
      apiCall: () async {
        final String senderId = Get.find<AuthRepository>().currentUser!.uid;

        // Check if connection already exists
        final existingConnection = await _connectionsCollection
            .where('senderId', isEqualTo: senderId)
            .where('recipientId', isEqualTo: recipientId)
            .get();

        if (existingConnection.docs.isNotEmpty) {
          return false;
        }

        // Create new connection request
        final connection = ConnectionModel(
          id: '',
          fromUserId: senderId,
          toUserId: recipientId,
          status: ConnectionStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _connectionsCollection.add(connection.toMap());

        // Update analytics
        await _updateConnectionAnalytics(senderId);

        return true;
      },
      maxAttempts: 3,
    );
  }

  // Respond to connection request
  Future<bool> respondToConnectionRequest(String requestId, bool accept) async {
    try {
      final status =
          accept ? ConnectionStatus.accepted : ConnectionStatus.declined;

      await _connectionsCollection.doc(requestId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (accept) {
        final request = await _connectionsCollection.doc(requestId).get();
        final data = request.data() as Map<String, dynamic>;

        // Update analytics for both users
        await _updateConnectionAnalytics(data['senderId']);
        await _updateConnectionAnalytics(data['recipientId']);
      }

      return true;
    } catch (e) {
      print('Error responding to connection request: $e');
      return false;
    }
  }

  // Get connection requests
  Stream<List<ConnectionModel>> getConnectionRequests(String userId) {
    return _connectionsCollection
        .where('recipientId', isEqualTo: userId)
        .where('status',
            isEqualTo: ConnectionStatus.pending.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConnectionModel.fromFirestore(doc))
            .toList());
  }

  // Get connections
  Stream<List<UserProfile>> getConnections(String userId) {
    return _connectionsCollection
        .where('status',
            isEqualTo: ConnectionStatus.accepted.toString().split('.').last)
        .where(Filter.or(
          Filter('senderId', isEqualTo: userId),
          Filter('recipientId', isEqualTo: userId),
        ))
        .snapshots()
        .asyncMap((snapshot) async {
      final connections = snapshot.docs;
      final connectedUserIds = connections.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['senderId'] == userId
            ? data['recipientId']
            : data['senderId'];
      }).toList();

      if (connectedUserIds.isEmpty) return [];

      final userDocs = await _usersCollection
          .where(FieldPath.documentId, whereIn: connectedUserIds)
          .get();

      return userDocs.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    });
  }

  // Block user
  Future<bool> blockUser(String userId) async {
    try {
      final String currentUserId = Get.find<AuthRepository>().currentUser!.uid;

      // Create blocking connection
      final connection = ConnectionModel(
        id: '',
        fromUserId: currentUserId,
        toUserId: userId,
        status: ConnectionStatus.blocked,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _connectionsCollection.add(connection.toMap());

      // Remove any existing connections
      final existingConnections = await _connectionsCollection
          .where(Filter.or(
            Filter('senderId', isEqualTo: currentUserId),
            Filter('recipientId', isEqualTo: currentUserId),
          ))
          .where(Filter.or(
            Filter('senderId', isEqualTo: userId),
            Filter('recipientId', isEqualTo: userId),
          ))
          .get();

      final batch = _firestore.batch();
      for (var doc in existingConnections.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['status'] !=
            ConnectionStatus.blocked.toString().split('.').last) {
          batch.delete(doc.reference);
        }
      }
      await batch.commit();

      return true;
    } catch (e) {
      print('Error blocking user: $e');
      return false;
    }
  }

  // Update connection analytics
  Future<void> _updateConnectionAnalytics(String userId) async {
    try {
      final analyticsRef = _userAnalyticsCollection.doc(userId);
      final analytics = await analyticsRef.get();

      if (analytics.exists) {
        await analyticsRef.update({
          'connectionCount': FieldValue.increment(1),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        await analyticsRef.set({
          'userId': userId,
          'connectionCount': 1,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating connection analytics: $e');
    }
  }

  Stream<List<ConnectionModel>> listenToConnectionRequests(String userId) {
    return _firestore
        .collection('connections')
        .where('toUserId', isEqualTo: userId)
        .where('status',
            isEqualTo: ConnectionStatus.pending.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConnectionModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<UserProfile>> listenToConnectionStatusUpdates(String userId) {
    return _firestore
        .collection('connections')
        .where('status',
            isEqualTo: ConnectionStatus.accepted.toString().split('.').last)
        .where('fromUserId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<UserProfile> connections = [];
      for (var doc in snapshot.docs) {
        final connection = ConnectionModel.fromFirestore(doc);
        final userDoc =
            await _firestore.collection('users').doc(connection.toUserId).get();
        if (userDoc.exists) {
          connections.add(UserProfile.fromFirestore(userDoc));
        }
      }
      return connections;
    });
  }

  Stream<Map<String, bool>> listenToOnlineStatus() {
    return _onlineStatusController.stream;
  }

  Future<List<UserProfile>> searchUsersWithPagination(
    String query,
    SearchFilterModel filters, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Query usersQuery = _firestore.collection('users');

      // Temel arama sorgusu
      if (query.isNotEmpty) {
        usersQuery = usersQuery.where('searchKeywords',
            arrayContains: query.toLowerCase());
      }

      // Filtreleri uygula
      if (filters.skills.isNotEmpty) {
        usersQuery =
            usersQuery.where('skills', arrayContainsAny: filters.skills);
      }

      if (filters.interests.isNotEmpty) {
        usersQuery =
            usersQuery.where('interests', arrayContainsAny: filters.interests);
      }

      if (filters.company != null) {
        usersQuery = usersQuery.where('company', isEqualTo: filters.company);
      }

      // Sayfalama
      final startAt = (page - 1) * pageSize;
      final snapshot = await usersQuery
          .orderBy('lastSeen', descending: true)
          .limit(pageSize)
          .startAt([startAt]).get();

      return snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Kullanıcı araması sırasında hata: $e');
      return [];
    }
  }

  Future<void> sendConnectionRequestWithMessage({
    required String fromUserId,
    required String toUserId,
    required String message,
  }) async {
    try {
      await _firestore.collection('connections').add({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'message': message,
        'status': ConnectionStatus.pending.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Bağlantı isteği gönderilirken hata: $e');
      rethrow;
    }
  }

  Future<void> acceptConnectionRequest(String connectionId) async {
    try {
      await _firestore.collection('connections').doc(connectionId).update({
        'status': ConnectionStatus.accepted.toString().split('.').last,
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Bağlantı isteği kabul edilirken hata: $e');
      rethrow;
    }
  }

  Future<void> declineConnectionRequest(String connectionId) async {
    try {
      await _firestore.collection('connections').doc(connectionId).update({
        'status': ConnectionStatus.declined.toString().split('.').last,
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Bağlantı isteği reddedilirken hata: $e');
      rethrow;
    }
  }

  void updateOnlineStatus(String userId, bool isOnline) {
    _onlineStatusController.add({userId: isOnline});
  }

  void onClose() {
    _onlineStatusController.close();
  }

  // Kullanıcı arama
  Future<List<UserProfile>> searchUsersByName(String query,
      {int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('fullName', isGreaterThanOrEqualTo: query)
          .where('fullName', isLessThan: '${query}z')
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Önerilen kullanıcıları getir
  Future<List<UserProfile>> getRecommendedUsersWithFilters(
    String userId,
    SearchFilterModel filters,
  ) async {
    return _algorithmService.getRecommendedUsers(
      userId: userId,
      filters: filters,
    );
  }

  // Gelen bağlantı isteklerini getir
  Future<List<UserProfile>> getIncomingRequests(String userId) async {
    try {
      final requestsSnapshot = await _firestore
          .collection('connections')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      final userIds = requestsSnapshot.docs
          .map((doc) => doc['fromUserId'] as String)
          .toList();

      if (userIds.isEmpty) return [];

      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      return usersSnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting incoming requests: $e');
      return [];
    }
  }

  // Giden bağlantı isteklerini getir
  Future<List<UserProfile>> getOutgoingRequests(String userId) async {
    try {
      final requestsSnapshot = await _firestore
          .collection('connections')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      final userIds = requestsSnapshot.docs
          .map((doc) => doc['toUserId'] as String)
          .toList();

      if (userIds.isEmpty) return [];

      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      return usersSnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting outgoing requests: $e');
      return [];
    }
  }

  // Kullanıcı konumunu güncelle
  Future<void> updateUserLocation(String userId, GeoPoint location) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'location': location,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user location: $e');
      rethrow;
    }
  }

  // Kullanıcı profilini güncelle
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Kullanıcı bildirim tercihlerini güncelle
  Future<void> updateNotificationPreferences(
    String userId,
    Map<String, bool> preferences,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'notificationPreferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating notification preferences: $e');
      rethrow;
    }
  }

  // Bağlantı isteğini reddet
  Future<void> deleteConnectionRequest(String requestId) async {
    try {
      await _firestore.collection('connections').doc(requestId).delete();
    } catch (e) {
      print('Error rejecting connection request: $e');
      rethrow;
    }
  }

  // Bağlantıyı kaldır
  Future<void> deleteConnection(String connectionId) async {
    try {
      await _firestore.collection('connections').doc(connectionId).delete();
    } catch (e) {
      print('Error removing connection: $e');
      rethrow;
    }
  }

  // Yakındaki kullanıcıları getir
  Future<List<UserProfile>> getNearbyUsers(
    GeoPoint center,
    double radiusInKm, {
    int limit = 20,
  }) async {
    try {
      // Tüm kullanıcıları al ve mesafeye göre filtrele
      final querySnapshot = await _usersCollection.limit(100).get();

      final nearbyUsers = querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .where((user) {
        if (user.location == null) return false;
        return _isWithinRadius(center, user.location!, radiusInKm);
      }).toList();

      // Mesafeye göre sırala
      nearbyUsers.sort((a, b) {
        final distanceA = _calculateDistance(center, a.location!);
        final distanceB = _calculateDistance(center, b.location!);
        return distanceA.compareTo(distanceB);
      });

      // İstenilen sayıda kullanıcı döndür
      return nearbyUsers.take(limit).toList();
    } catch (e) {
      print('Error getting nearby users: $e');
      return [];
    }
  }

  Future<void> cancelConnectionRequest(String requestId) async {
    try {
      // Firebase veya başka bir backend servisine istek gönder
      await _firestore
          .collection('connection_requests')
          .doc(requestId)
          .delete();
    } catch (e) {
      throw 'Bağlantı isteği geri çekilirken bir hata oluştu: $e';
    }
  }
}

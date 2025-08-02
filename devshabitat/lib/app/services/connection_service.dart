import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/connection_model.dart';
import '../core/services/error_handler_service.dart';
import '../core/services/memory_manager_service.dart';
import '../core/services/cache_service.dart';

class ConnectionService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ErrorHandlerService _errorHandler = Get.find();
  final MemoryManagerService _memoryManager = Get.find();
  final CacheService _cacheService = Get.find();

  static const int _pageSize = 20;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;

  String _getCacheKey(Map<String, dynamic> params) {
    return 'connections_${params.toString()}';
  }

  Future<List<ConnectionModel>> getConnections({
    String? userId,
    String? searchQuery,
    List<String>? skills,
    int? maxDistance,
    bool? isOnline,
    DocumentSnapshot? startAfter,
    int limit = _pageSize,
  }) async {
    final params = {
      'userId': userId,
      'searchQuery': searchQuery,
      'skills': skills,
      'maxDistance': maxDistance,
      'isOnline': isOnline,
      'startAfter': startAfter?.id,
      'limit': limit,
    };

    final cacheKey = _getCacheKey(params);

    try {
      return await _cacheService.getOrFetch<List<ConnectionModel>>(
        cacheKey,
        () => _fetchConnections(params),
        expiration: const Duration(minutes: 5),
      );
    } catch (e) {
      _errorHandler.handleError(e);
      return [];
    }
  }

  Future<List<ConnectionModel>> _fetchConnections(
    Map<String, dynamic> params,
  ) async {
    Query query = _firestore.collection('connections');

    if (params['userId'] != null) {
      query = query.where('userId', isEqualTo: params['userId']);
    }

    if (params['searchQuery'] != null && params['searchQuery'].isNotEmpty) {
      query = query.where(
        'searchTerms',
        arrayContains: params['searchQuery'].toLowerCase(),
      );
    }

    if (params['skills'] != null && params['skills'].isNotEmpty) {
      query = query.where('skills', arrayContainsAny: params['skills']);
    }

    if (params['isOnline'] != null) {
      query = query.where('isOnline', isEqualTo: params['isOnline']);
    }

    query = query.orderBy('lastActive', descending: true);

    if (params['startAfter'] != null) {
      query = query.startAfterDocument(params['startAfter']);
    }

    query = query.limit(params['limit'] ?? _pageSize);

    final snapshot = await query.get();
    _lastDocument = snapshot.docs.isEmpty ? null : snapshot.docs.last;
    _hasMoreData = snapshot.docs.length >= (params['limit'] ?? _pageSize);

    return snapshot.docs
        .map((doc) =>
            ConnectionModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConnectionModel>> loadMoreConnections({
    String? searchQuery,
    List<String>? skills,
    int? maxDistance,
    bool? isOnline,
  }) async {
    if (!_hasMoreData || _lastDocument == null) return [];

    return getConnections(
      searchQuery: searchQuery,
      skills: skills,
      maxDistance: maxDistance,
      isOnline: isOnline,
      startAfter: _lastDocument,
    );
  }

  Future<void> resetPagination() async {
    _lastDocument = null;
    _hasMoreData = true;
    _memoryManager.optimizeMemory();

    // Clear connection-related cache entries
    final connectionKeys = _cacheService.keys
        .where((key) => key.startsWith('connections_'))
        .toList();
    _cacheService.removeMultiple(connectionKeys);
  }

  Future<void> removeConnection(String connectionId) async {
    try {
      await _firestore.collection('connections').doc(connectionId).delete();
    } catch (e) {
      _errorHandler.handleError(e, 'removeConnection');
      rethrow;
    }
  }

  Future<void> addConnection(String connectionId) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(connectionId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final connectionData = {
        'userId': connectionId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      await _firestore.collection('connections').add(connectionData);
    } catch (e) {
      _errorHandler.handleError(e, 'addConnection');
      rethrow;
    }
  }

  Future<int> getConnectionCount() async {
    try {
      final snapshot = await _firestore
          .collection('connections')
          .where('status', isEqualTo: 'accepted')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      _errorHandler.handleError(e);
      return 0;
    }
  }

  bool get hasMoreData => _hasMoreData;

  Map<String, dynamic> getCacheStats() {
    return _cacheService.getStats();
  }

  void clearCache() {
    final connectionKeys = _cacheService.keys
        .where((key) => key.startsWith('connections_'))
        .toList();
    _cacheService.removeMultiple(connectionKeys);
    _memoryManager.optimizeMemory();
  }
}

import 'package:get/get.dart';
import '../models/connection_model.dart';
import '../models/user_profile_model.dart';
import '../models/enhanced_user_model.dart';
import '../core/services/error_handler_service.dart';
import '../core/services/cache_service.dart';
import '../algorithms/connection_scoring_algorithm.dart';

class RecommendationService extends GetxService {
  final ErrorHandlerService _errorHandler = Get.find();
  final CacheService _cacheService = Get.find();

  static const Duration _recommendationCacheExpiration = Duration(hours: 1);

  Future<List<ConnectionModel>> getRecommendedConnections(
    UserProfile userProfile, {
    int limit = 10,
    List<String>? preferredSkills,
    int? maxDistance,
    bool? isOnline,
  }) async {
    try {
      final cacheKey = _getRecommendationCacheKey(
        userProfile.id,
        preferredSkills,
        maxDistance,
        isOnline,
      );

      return await _cacheService.getOrFetch<List<ConnectionModel>>(
        cacheKey,
        () => _fetchRecommendations(
          userProfile,
          limit: limit,
          preferredSkills: preferredSkills,
          maxDistance: maxDistance,
          isOnline: isOnline,
        ),
        expiration: _recommendationCacheExpiration,
      );
    } catch (e) {
      _errorHandler.handleError(e, 'getRecommendedConnections');
      return [];
    }
  }

  String _getRecommendationCacheKey(
    String userId,
    List<String>? skills,
    int? distance,
    bool? online,
  ) {
    return 'recommendations_${userId}_${skills?.join('_')}_${distance}_$online';
  }

  Future<List<ConnectionModel>> _fetchRecommendations(
    UserProfile userProfile, {
    required int limit,
    List<String>? preferredSkills,
    int? maxDistance,
    bool? isOnline,
  }) async {
    // Get potential connections
    final potentialConnections = await _getPotentialConnections(
      userProfile,
      preferredSkills: preferredSkills,
      maxDistance: maxDistance,
      isOnline: isOnline,
    );

    // Score and sort connections
    final scoredConnections = potentialConnections.map((connection) {
      final score = ConnectionScoringAlgorithm.calculateConnectionScore(
        userProfile as EnhancedUserModel,
        connection as EnhancedUserModel,
      );
      return (connection, score);
    }).toList();

    scoredConnections.sort((a, b) => b.$2.compareTo(a.$2));

    // Return top recommendations
    return scoredConnections.take(limit).map((scored) => scored.$1).toList();
  }

  Future<List<ConnectionModel>> _getPotentialConnections(
    UserProfile userProfile, {
    List<String>? preferredSkills,
    int? maxDistance,
    bool? isOnline,
  }) async {
    // Implementation will depend on your data source
    // This is a placeholder that should be replaced with actual implementation
    return [];
  }

  Future<void> refreshRecommendations(String userId) async {
    final recommendationKeys = _cacheService.keys
        .where((key) => key.startsWith('recommendations_$userId'))
        .toList();
    _cacheService.removeMultiple(recommendationKeys);
  }

  Map<String, dynamic> getRecommendationStats(String userId) {
    final recommendationKeys = _cacheService.keys
        .where((key) => key.startsWith('recommendations_$userId'))
        .toList();

    final stats = {
      'totalRecommendations': recommendationKeys.length,
      'cacheHits': 0,
      'cacheMisses': 0,
    };

    for (final key in recommendationKeys) {
      final timeToExpiration = _cacheService.getTimeToExpiration(key);
      if (timeToExpiration != null) {
        stats['cacheHits'] = (stats['cacheHits'] as int) + 1;
      } else {
        stats['cacheMisses'] = (stats['cacheMisses'] as int) + 1;
      }
    }

    return stats;
  }
}

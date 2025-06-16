import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/enhanced_user_model.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';

class SimpleRecommendationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Logger _logger;
  final double _similarityThreshold = 0.3;

  SimpleRecommendationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _logger = Get.find<Logger>();

  /// Ana öneri metodunu çağırır ve tüm önerileri birleştirir
  Future<List<EnhancedUserModel>> getRecommendedConnections() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw Exception('Kullanıcı profili bulunamadı');
      }

      final currentUserData = EnhancedUserModel.fromJson(userDoc.data()!);

      // Farklı kriterlere göre önerileri al
      final skillBasedRecommendations =
          await findBySimilarSkills(currentUserData);
      final experienceBasedRecommendations =
          await findByExperience(currentUserData);

      // Tüm önerileri birleştir ve tekrar edenleri kaldır
      final allRecommendations = {
        ...skillBasedRecommendations,
        ...experienceBasedRecommendations,
      }.toList();

      // Mevcut bağlantıları filtrele
      return _filterExistingConnections(allRecommendations, currentUserData);
    } catch (e) {
      _logger.e('Öneriler alınırken hata: $e');
      rethrow;
    }
  }

  /// Benzer yeteneklere sahip kullanıcıları bulur
  Future<Set<EnhancedUserModel>> findBySimilarSkills(
      EnhancedUserModel currentUser) async {
    try {
      if (currentUser.skills == null || currentUser.skills!.isEmpty) {
        return {};
      }

      final usersSnapshot = await _firestore.collection('users').get();
      final recommendations = <EnhancedUserModel>{};

      for (var doc in usersSnapshot.docs) {
        if (doc.id == currentUser.id.value) continue;

        final otherUser = EnhancedUserModel.fromJson(doc.data());
        if (otherUser.skills == null || otherUser.skills!.isEmpty) continue;

        final similarity = _calculateJaccardSimilarity(
          currentUser.skills!,
          otherUser.skills!,
        );

        if (similarity >= _similarityThreshold) {
          recommendations.add(otherUser);
        }
      }

      return recommendations;
    } catch (e) {
      _logger.e('Yetenek bazlı öneriler alınırken hata: $e');
      return {};
    }
  }

  /// Benzer deneyimlere sahip kullanıcıları bulur
  Future<Set<EnhancedUserModel>> findByExperience(
      EnhancedUserModel currentUser) async {
    try {
      if (currentUser.experience == null || currentUser.experience!.isEmpty) {
        return {};
      }

      final recommendations = <EnhancedUserModel>{};
      final currentUserCompanies = currentUser.experience!
          .map((e) => e['company'] as String?)
          .where((e) => e != null)
          .toSet();

      if (currentUserCompanies.isEmpty) return {};

      final usersSnapshot = await _firestore.collection('users').get();

      for (var doc in usersSnapshot.docs) {
        if (doc.id == currentUser.id.value) continue;

        final otherUser = EnhancedUserModel.fromJson(doc.data());
        if (otherUser.experience == null || otherUser.experience!.isEmpty)
          continue;

        final otherUserCompanies = otherUser.experience!
            .map((e) => e['company'] as String?)
            .where((e) => e != null)
            .toSet();

        if (otherUserCompanies.isEmpty) continue;

        final commonCompanies =
            currentUserCompanies.intersection(otherUserCompanies);
        if (commonCompanies.isNotEmpty) {
          recommendations.add(otherUser);
        }
      }

      return recommendations;
    } catch (e) {
      _logger.e('Deneyim bazlı öneriler alınırken hata: $e');
      return {};
    }
  }

  /// Jaccard benzerlik skorunu hesaplar
  double _calculateJaccardSimilarity(List<String> set1, List<String> set2) {
    if (set1.isEmpty && set2.isEmpty) return 0.0;

    final intersection = set1.toSet().intersection(set2.toSet());
    final union = set1.toSet().union(set2.toSet());

    return intersection.length / union.length;
  }

  /// Mevcut bağlantıları filtreler
  List<EnhancedUserModel> _filterExistingConnections(
    List<EnhancedUserModel> recommendations,
    EnhancedUserModel currentUser,
  ) {
    return recommendations
        .where((user) => !currentUser.connections!.contains(user.id.value))
        .toList();
  }
}

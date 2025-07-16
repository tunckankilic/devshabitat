import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';
import '../controllers/auth_controller.dart';
import 'package:logger/logger.dart';

class DeveloperMatchingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Benzer teknoloji stack'ine sahip geliştiricileri bul
  Future<List<UserProfile>> findDevelopersByTechStack({
    required List<String> techStack,
    required String excludeUsername,
  }) async {
    try {
      // Önce sadece skills ile filtrele, sonra client-side'da username kontrolü yap
      final querySnapshot = await _firestore
          .collection('users')
          .where('skills', arrayContainsAny: techStack)
          .limit(50) // Limit ekle
          .get();

      // Client-side'da username filtrelemesi yap
      final filteredDevelopers = querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['githubUsername'] != excludeUsername;
          })
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();

      return filteredDevelopers;
    } catch (e) {
      _logger.e('Teknoloji stack query hatası: $e');
      // Optimize edilmiş fallback: Batch queries ile performans iyileştirmesi
      try {
        const int batchSize = 30; // Küçük batch size
        const int maxResults = 50; // Maksimum sonuç

        List<UserProfile> allResults = [];

        // Teknoloji stack'ini küçük gruplara böl
        for (int i = 0;
            i < techStack.length && allResults.length < maxResults;
            i += 5) {
          final techBatch = techStack.skip(i).take(5).toList();

          final batchQuery = await _firestore
              .collection('users')
              .where('skills', arrayContainsAny: techBatch)
              .limit(batchSize)
              .get();

          final batchResults = batchQuery.docs
              .where((doc) {
                final data = doc.data();
                final username = data['githubUsername'];
                return username != excludeUsername;
              })
              .map((doc) => UserProfile.fromFirestore(doc))
              .toList();

          allResults.addAll(batchResults);

          // Yeterli sonuç bulunduğunda dur
          if (allResults.length >= maxResults) break;
        }

        // Tekrar edenleri kaldır ve limit uygula
        final uniqueResults = <String, UserProfile>{};
        for (final user in allResults) {
          uniqueResults[user.id] = user;
        }

        return uniqueResults.values.take(maxResults).toList();
      } catch (fallbackError) {
        throw Exception(
            'Geliştiriciler bulunurken bir hata oluştu: $fallbackError');
      }
    }
  }

  // Proje önerileri getir
  Future<List<Map<String, dynamic>>> getProjectSuggestions({
    required String username,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .where('isOpen', isEqualTo: true)
          .limit(20) // Limit ekle
          .get();

      // Client-side'da collaborator kontrolü yap
      return querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            final collaborators =
                List<String>.from(data['collaborators'] ?? []);
            return collaborators.contains(username);
          })
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Proje önerileri hatası: $e');
      return [];
    }
  }

  // Potansiyel mentorları bul
  Future<List<UserProfile>> findPotentialMentors({
    required String username,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isMentor', isEqualTo: true)
          .limit(50) // Limit ekle
          .get();

      // Client-side'da username filtrelemesi yap
      return querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['githubUsername'] != username;
          })
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Mentor bulma hatası: $e');
      return [];
    }
  }

  // Eşleşme skoru hesapla
  double calculateMatchScore(UserProfile developer) {
    try {
      // Burada daha karmaşık bir algoritma kullanılabilir
      return 0.8; // Örnek skor
    } catch (e) {
      throw Exception('Eşleşme skoru hesaplanırken bir hata oluştu: $e');
    }
  }

  // İşbirliği talebi gönder
  Future<void> sendCollaborationRequest({
    required String targetUserId,
  }) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      await _firestore.collection('collaboration_requests').add({
        'fromUserId': currentUserId,
        'toUserId': targetUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('İşbirliği talebi gönderilirken bir hata oluştu: $e');
    }
  }

  // Mentorluk talebi gönder
  Future<void> sendMentorshipRequest({
    required String mentorId,
  }) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      await _firestore.collection('mentorship_requests').add({
        'fromUserId': currentUserId,
        'toUserId': mentorId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Mentorluk talebi gönderilirken bir hata oluştu: $e');
    }
  }
}

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';
import '../controllers/auth_controller.dart';
import 'package:logger/logger.dart';
import '../services/user_service.dart'; // Added import for UserService

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
        for (
          int i = 0;
          i < techStack.length && allResults.length < maxResults;
          i += 5
        ) {
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
          'Geliştiriciler bulunurken bir hata oluştu: $fallbackError',
        );
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

      // Client-side'da collaborator kontrolü yap - düzeltildi
      return querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            final collaborators = List<String>.from(
              data['collaborators'] ?? [],
            );
            return !collaborators.contains(
              username,
            ); // NOT operatörü düzeltildi
          })
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      _logger.e('Proje önerileri hatası: $e');
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
      _logger.e('Mentor bulma hatası: $e');
      return [];
    }
  }

  // Gelişmiş eşleşme skoru hesaplama algoritması
  double calculateMatchScore(UserProfile developer) {
    try {
      // UserService'ten EnhancedUserModel al
      final userService = Get.find<UserService>();
      final currentUser = userService.currentUser;

      if (currentUser == null) return 0.0;

      double score = 0.0;
      int factors = 0;

      // Skills match (40% ağırlık)
      if (developer.skills.isNotEmpty && currentUser.skills != null) {
        final currentUserSkills = currentUser.skills!;
        final commonSkills = developer.skills
            .where((skill) => currentUserSkills.contains(skill))
            .length;
        if (currentUserSkills.isNotEmpty && developer.skills.isNotEmpty) {
          final skillScore =
              commonSkills /
              (currentUserSkills.length +
                  developer.skills.length -
                  commonSkills);
          score += skillScore * 0.4;
          factors++;
        }
      }

      // Experience level match (20% ağırlık)
      if (developer.yearsOfExperience > 0 &&
          currentUser.yearsOfExperience > 0) {
        final currentExp = currentUser.yearsOfExperience;
        final expDiff = (developer.yearsOfExperience - currentExp).abs();
        final expScore = 1.0 - (expDiff / 20.0); // 20 yıl max fark
        score += (expScore > 0 ? expScore : 0) * 0.2;
        factors++;
      }

      // Location proximity (20% ağırlık)
      if (developer.location != null && currentUser.location != null) {
        // Basit konum skorlaması
        final locationScore = 0.7; // Sabit orta değer
        score += locationScore * 0.2;
        factors++;
      }

      // Diğer faktörlerin ağırlığını artır
      score *= 1.25;

      return factors > 0 ? score / factors : 0.0;
    } catch (e) {
      _logger.e('Eşleşme skoru hesaplama hatası: $e');
      return 0.0;
    }
  }

  // İşbirliği talebi gönder
  Future<void> sendCollaborationRequest({required String targetUserId}) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Aynı kişiye tekrar istek gönderilmesini önle
      final existingRequest = await _firestore
          .collection('collaboration_requests')
          .where('fromUserId', isEqualTo: currentUserId)
          .where('toUserId', isEqualTo: targetUserId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw Exception('Bu kullanıcıya zaten bekleyen bir talebiniz var');
      }

      await _firestore.collection('collaboration_requests').add({
        'fromUserId': currentUserId,
        'toUserId': targetUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'collaboration',
      });
    } catch (e) {
      throw Exception('İşbirliği talebi gönderilirken bir hata oluştu: $e');
    }
  }

  // Mentorluk talebi gönder
  Future<void> sendMentorshipRequest({required String mentorId}) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Aynı mentora tekrar istek gönderilmesini önle
      final existingRequest = await _firestore
          .collection('mentorship_requests')
          .where('fromUserId', isEqualTo: currentUserId)
          .where('toUserId', isEqualTo: mentorId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw Exception('Bu mentora zaten bekleyen bir talebiniz var');
      }

      await _firestore.collection('mentorship_requests').add({
        'fromUserId': currentUserId,
        'toUserId': mentorId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'mentorship',
      });
    } catch (e) {
      throw Exception('Mentorluk talebi gönderilirken bir hata oluştu: $e');
    }
  }
}

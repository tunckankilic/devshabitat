import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

class DeveloperMatchingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Benzer teknoloji stack'ine sahip geliştiricileri bul
  Future<List<UserProfile>> findDevelopersByTechStack({
    required List<String> techStack,
    required String excludeUsername,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('technologies', arrayContainsAny: techStack)
          .where('username', isNotEqualTo: excludeUsername)
          .get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Geliştiriciler bulunurken bir hata oluştu: $e');
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
          .where('collaborators', arrayContains: username)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Proje önerileri alınırken bir hata oluştu: $e');
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
          .where('username', isNotEqualTo: username)
          .get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Mentor önerileri alınırken bir hata oluştu: $e');
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
      final currentUserId = Get.find<String>();

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
      final currentUserId = Get.find<String>();

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

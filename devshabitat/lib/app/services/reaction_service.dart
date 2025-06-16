import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, DateTime> _lastReactionTimes = {};

  // Rate limiting kontrolü için yardımcı metod
  bool _canAddReaction(String userId) {
    final now = DateTime.now();
    if (_lastReactionTimes.containsKey(userId)) {
      final timeDiff = now.difference(_lastReactionTimes[userId]!);
      if (timeDiff.inMilliseconds < 100) {
        return false;
      }
    }
    _lastReactionTimes[userId] = now;
    return true;
  }

  // Reaksiyon ekleme metodu
  Future<void> addReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    try {
      if (!_canAddReaction(userId)) {
        throw Exception('Çok hızlı reaksiyon ekliyorsunuz. Lütfen bekleyin.');
      }

      final reactionRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId);

      // Optimistik güncelleme için mevcut durumu kaydet
      final snapshot = await reactionRef.get();
      final currentReactions = snapshot.data()?['reactions'] ?? {};

      // Optimistik güncelleme
      List<String> users = List<String>.from(currentReactions[emoji] ?? []);
      if (!users.contains(userId)) {
        users.add(userId);
      }

      await reactionRef.set({
        'reactions': {
          ...currentReactions,
          emoji: users,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      // Hata durumunda rollback işlemleri burada yapılabilir
      rethrow;
    }
  }

  // Reaksiyon kaldırma metodu
  Future<void> removeReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    try {
      final reactionRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId);

      final snapshot = await reactionRef.get();
      final currentReactions = snapshot.data()?['reactions'] ?? {};

      List<String> users = List<String>.from(currentReactions[emoji] ?? []);
      users.remove(userId);

      if (users.isEmpty) {
        // Eğer emoji için kullanıcı kalmadıysa, emojiyi tamamen kaldır
        currentReactions.remove(emoji);
      } else {
        currentReactions[emoji] = users;
      }

      await reactionRef.update({'reactions': currentReactions});
    } catch (e) {
      rethrow;
    }
  }

  // Reaksiyonları gerçek zamanlı dinleme
  Stream<Map<String, List<String>>> getReactions(
    String conversationId,
    String messageId,
  ) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {};
      }

      final data = snapshot.data()?['reactions'] as Map<String, dynamic>?;
      if (data == null) {
        return {};
      }

      return data.map((emoji, users) => MapEntry(
            emoji,
            List<String>.from(users),
          ));
    });
  }

  // Belirli bir kullanıcının reaksiyonlarını kontrol etme
  Future<List<String>> getUserReactions({
    required String conversationId,
    required String messageId,
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .get();

      final reactions = snapshot.data()?['reactions'] as Map<String, dynamic>?;
      if (reactions == null) {
        return [];
      }

      return reactions.entries
          .where((entry) => (entry.value as List).contains(userId))
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

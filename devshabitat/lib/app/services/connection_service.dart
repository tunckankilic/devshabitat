import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/connection_model.dart';
import '../controllers/auth_controller.dart';

class ConnectionService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getConnectionCount() async {
    try {
      final userId = Get.find<AuthController>().currentUser?.uid;
      if (userId == null) return 0;

      final snapshot = await _firestore
          .collection('connections')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      return snapshot.size;
    } catch (e) {
      print('Bağlantı sayısı alınırken hata: $e');
      return 0;
    }
  }

  Future<List<ConnectionModel>> getConnections({
    required String userId,
    String status = 'accepted',
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('connections')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ConnectionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Bağlantılar alınırken hata: $e');
      return [];
    }
  }

  Future<void> sendConnectionRequest(String targetUserId) async {
    try {
      final userId = Get.find<AuthController>().currentUser?.uid;
      if (userId == null) throw 'Kullanıcı oturumu bulunamadı';

      await _firestore.collection('connections').add({
        'userId': userId,
        'targetUserId': targetUserId,
        'status': 'pending',
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
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Bağlantı isteği kabul edilirken hata: $e');
      rethrow;
    }
  }

  Future<void> rejectConnectionRequest(String connectionId) async {
    try {
      await _firestore.collection('connections').doc(connectionId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Bağlantı isteği reddedilirken hata: $e');
      rethrow;
    }
  }

  Future<void> removeConnection(String connectionId) async {
    try {
      await _firestore.collection('connections').doc(connectionId).delete();
    } catch (e) {
      print('Bağlantı silinirken hata: $e');
      rethrow;
    }
  }
}

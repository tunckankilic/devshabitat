import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class PrivacyController extends GetxController {
  final Logger _logger = Get.find<Logger>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable değişkenler
  final RxBool isProfilePublic = true.obs;
  final RxBool allowConnectionRequests = true.obs;
  final RxBool showOnlineStatus = true.obs;
  final RxBool showLastSeen = true.obs;
  final RxList<String> blockedUsers = <String>[].obs;
  final RxBool isLoading = false.obs;

  // Firestore koleksiyon referansları
  late final CollectionReference _usersCollection;
  late final CollectionReference _privacySettingsCollection;

  @override
  void onInit() {
    super.onInit();
    _initializeFirestore();
    loadPrivacySettings();
  }

  void _initializeFirestore() {
    _usersCollection = _firestore.collection('users');
    _privacySettingsCollection = _firestore.collection('privacy_settings');
  }

  Future<void> loadPrivacySettings() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final privacyDoc = await _privacySettingsCollection.doc(user.uid).get();

      if (privacyDoc.exists) {
        final data = privacyDoc.data() as Map<String, dynamic>;
        isProfilePublic.value = data['isProfilePublic'] ?? true;
        allowConnectionRequests.value = data['allowConnectionRequests'] ?? true;
        showOnlineStatus.value = data['showOnlineStatus'] ?? true;
        showLastSeen.value = data['showLastSeen'] ?? true;
        blockedUsers.value = List<String>.from(data['blockedUsers'] ?? []);
      } else {
        // Varsayılan ayarları oluştur
        await _createDefaultPrivacySettings(user.uid);
      }
    } catch (e) {
      _logger.e('Gizlilik ayarları yüklenirken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createDefaultPrivacySettings(String userId) async {
    try {
      final defaultSettings = {
        'isProfilePublic': true,
        'allowConnectionRequests': true,
        'showOnlineStatus': true,
        'showLastSeen': true,
        'blockedUsers': [],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _privacySettingsCollection.doc(userId).set(defaultSettings);
    } catch (e) {
      _logger.e('Varsayılan gizlilik ayarları oluşturulurken hata: $e');
    }
  }

  Future<void> updateProfileVisibility(bool isPublic) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      isProfilePublic.value = isPublic;
      await _privacySettingsCollection.doc(user.uid).update({
        'isProfilePublic': isPublic,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Profil görünürlüğü güncellenirken hata: $e');
    }
  }

  Future<void> updateConnectionRequestSetting(bool allow) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      allowConnectionRequests.value = allow;
      await _privacySettingsCollection.doc(user.uid).update({
        'allowConnectionRequests': allow,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Bağlantı isteği ayarı güncellenirken hata: $e');
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      if (!blockedUsers.contains(userId)) {
        blockedUsers.add(userId);
        await _privacySettingsCollection.doc(user.uid).update({
          'blockedUsers': FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Karşılıklı bağlantıları kaldır
        await _removeConnectionsBetweenUsers(user.uid, userId);
      }
    } catch (e) {
      _logger.e('Kullanıcı engellenirken hata: $e');
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      blockedUsers.remove(userId);
      await _privacySettingsCollection.doc(user.uid).update({
        'blockedUsers': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Kullanıcı engeli kaldırılırken hata: $e');
    }
  }

  Future<void> _removeConnectionsBetweenUsers(
      String userId1, String userId2) async {
    try {
      final batch = _firestore.batch();

      // Her iki kullanıcının bağlantılarından birbirlerini kaldır
      batch.update(_usersCollection.doc(userId1), {
        'connections': FieldValue.arrayRemove([userId2])
      });

      batch.update(_usersCollection.doc(userId2), {
        'connections': FieldValue.arrayRemove([userId1])
      });

      await batch.commit();
    } catch (e) {
      _logger.e('Bağlantılar kaldırılırken hata: $e');
    }
  }

  Future<void> updateOnlineStatusVisibility(bool show) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      showOnlineStatus.value = show;
      await _privacySettingsCollection.doc(user.uid).update({
        'showOnlineStatus': show,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Çevrimiçi durum görünürlüğü güncellenirken hata: $e');
    }
  }

  Future<void> updateLastSeenVisibility(bool show) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      showLastSeen.value = show;
      await _privacySettingsCollection.doc(user.uid).update({
        'showLastSeen': show,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Son görülme görünürlüğü güncellenirken hata: $e');
    }
  }
}

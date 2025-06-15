import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

class UserProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final connectionStatus = Rx<ConnectionStatus>(ConnectionStatus.none);
  final currentUserSkills = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUserSkills();
  }

  Future<void> loadCurrentUserSkills() async {
    try {
      final currentUserId = Get.find<AuthController>().user.value?.uid;
      if (currentUserId != null) {
        final doc =
            await _firestore.collection('users').doc(currentUserId).get();
        if (doc.exists) {
          final user = UserProfile.fromFirestore(doc);
          currentUserSkills.value = user.skills;
        }
      }
    } catch (e) {
      print('Error loading current user skills: $e');
    }
  }

  Future<void> sendConnectionRequest(UserProfile user) async {
    try {
      final currentUserId = Get.find<AuthController>().user.value?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('connections').add({
        'fromUserId': currentUserId,
        'toUserId': user.id,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      connectionStatus.value = ConnectionStatus.pending;
      Get.snackbar(
        'Başarılı',
        'Bağlantı isteği gönderildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error sending connection request: $e');
      Get.snackbar(
        'Hata',
        'Bağlantı isteği gönderilemedi',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openChat(UserProfile user) async {
    // Chat ekranına yönlendir
    Get.toNamed('/chat', arguments: user);
  }

  Future<void> openGitHub(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> openLinkedIn(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

enum ConnectionStatus {
  none,
  pending,
  connected,
}

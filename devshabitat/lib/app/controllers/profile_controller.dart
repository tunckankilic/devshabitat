import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/enhanced_user_model.dart';
import '../services/storage_service.dart';
import '../services/github_service.dart';
import '../core/services/api_optimization_service.dart';
import '../repositories/auth_repository.dart';

class ProfileController extends GetxController {
  final AuthRepository _authService = Get.find<AuthRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  final _user = Rxn<EnhancedUserModel>();
  final _isLoading = false.obs;
  final _error = ''.obs;

  // Form controllers
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final locationController = TextEditingController();
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final githubUsernameController = TextEditingController();
  final photoUrlController = TextEditingController();

  // Getters
  EnhancedUserModel? get user => _user.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    locationController.dispose();
    titleController.dispose();
    companyController.dispose();
    githubUsernameController.dispose();
    photoUrlController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _error.value = 'Kullanıcı bulunamadı';
        return;
      }

      final doc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!doc.exists) {
        _error.value = 'Profil bulunamadı';
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      _user.value = EnhancedUserModel.fromJson({
        'uid': doc.id,
        ...data,
      });
      _loadFormData();
    } catch (e) {
      _error.value = 'Profil yüklenirken bir hata oluştu: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void _loadFormData() {
    if (_user.value != null) {
      nameController.text = _user.value!.displayName ?? '';
      bioController.text = _user.value!.bio ?? '';
      locationController.text = _user.value!.location?.address ?? '';
      titleController.text = _user.value!.preferences?['title'] ?? '';
      companyController.text = _user.value!.preferences?['company'] ?? '';
      githubUsernameController.text = _user.value!.githubUsername ?? '';
      photoUrlController.text = _user.value!.photoURL ?? '';
    }
  }

  Future<void> updateProfile() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _error.value = 'Kullanıcı bulunamadı';
        return;
      }

      final updates = {
        'displayName': nameController.text,
        'bio': bioController.text,
        'location': {
          'address': locationController.text,
        },
        'preferences': {
          'title': titleController.text,
          'company': companyController.text,
        },
        'githubUsername': githubUsernameController.text,
        'photoURL': photoUrlController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(currentUser.uid).update(updates);
      await loadProfile();

      Get.snackbar(
        'Başarılı',
        'Profil güncellendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = 'Profil güncellenirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Profil güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfilePhoto(String localPath) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _error.value = 'Kullanıcı bulunamadı';
        return;
      }

      final downloadUrl = await _storageService.uploadProfileImage(
        currentUser.uid,
        localPath,
      );

      if (downloadUrl != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'photoURL': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        photoUrlController.text = downloadUrl;
        await loadProfile();

        Get.snackbar(
          'Başarılı',
          'Profil fotoğrafı güncellendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _error.value = 'Profil fotoğrafı güncellenirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Profil fotoğrafı güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> fetchGithubRepoData(String username) async {
    try {
      final apiOptimizer = Get.find<ApiOptimizationService>();

      return await apiOptimizer.optimizeApiCall(
        apiCall: () async {
          final repos = await Get.find<GithubService>().getUserRepos(username);
          if (repos.isEmpty) {
            throw Exception('Kullanıcının repository\'si bulunamadı');
          }
          // En çok yıldızlı repo'yu döndür
          final repo = repos.reduce((curr, next) =>
              (curr['stargazers_count'] ?? 0) > (next['stargazers_count'] ?? 0)
                  ? curr
                  : next);
          return {
            'name': repo['name'],
            'description': repo['description'],
            'language': repo['language'],
            'stars': repo['stargazers_count'] ?? 0,
            'forks': repo['forks_count'] ?? 0,
          };
        },
        cacheKey: 'github_repo_data_$username',
        cacheDuration: const Duration(minutes: 30),
      );
    } catch (e) {
      throw Exception('GitHub verisi alınamadı: $e');
    }
  }
}

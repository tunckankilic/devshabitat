import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/developer_profile_model.dart';
import '../models/skill_model.dart';
import '../models/github_stats_model.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();
  final AuthService _authService = Get.find<AuthService>();
  final Rx<DeveloperProfile?> _profile = Rx<DeveloperProfile?>(null);
  final RxList<SkillModel> _skills = <SkillModel>[].obs;
  final Rx<GithubStatsModel?> _githubStats = Rx<GithubStatsModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final locationController = TextEditingController();
  final githubUsernameController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    locationController.dispose();
    githubUsernameController.dispose();
    super.onClose();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser.value;
    if (user != null) {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        final data = userData.data()!;
        nameController.text = data['displayName'] ?? '';
        bioController.text = data['bio'] ?? '';
        locationController.text = data['location'] ?? '';
        githubUsernameController.text = data['githubUsername'] ?? '';
      }
    }
  }

  // Getters
  DeveloperProfile? get profile => _profile.value;
  List<SkillModel> get skills => _skills;
  GithubStatsModel? get githubStats => _githubStats.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  // Profile yükleme
  Future<void> loadProfile(String userId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      _profile.value = await _profileService.getProfile(userId);
      await loadSkills();
      await loadGithubStats();
    } catch (e) {
      _error.value = 'Profil yüklenirken bir hata oluştu: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // Yetenekleri yükleme
  Future<void> loadSkills() async {
    try {
      if (_profile.value != null) {
        _skills.value = await _profileService.getSkills(_profile.value!.id);
      }
    } catch (e) {
      _error.value = 'Yetenekler yüklenirken bir hata oluştu: $e';
    }
  }

  // GitHub istatistiklerini yükleme
  Future<void> loadGithubStats() async {
    try {
      if (_profile.value != null) {
        final githubUsername =
            _profile.value!.githubStats['username'] as String?;
        if (githubUsername != null) {
          _githubStats.value =
              await _profileService.getGithubStats(githubUsername);
        }
      }
    } catch (e) {
      _error.value = 'GitHub istatistikleri yüklenirken bir hata oluştu: $e';
    }
  }

  // Profil güncelleme
  Future<void> updateProfile() async {
    try {
      await _authService.updateUserProfile(
        name: nameController.text,
        bio: bioController.text,
        location: locationController.text,
        githubUsername: githubUsernameController.text,
      );
      Get.snackbar('Başarılı', 'Profil güncellendi');
    } catch (e) {
      Get.snackbar('Hata', 'Profil güncellenirken bir hata oluştu');
    }
  }

  // Yetenek ekleme
  Future<void> addSkill(SkillModel skill) async {
    try {
      if (_profile.value != null) {
        await _profileService.addSkill(_profile.value!.id, skill);
        _skills.add(skill);
      }
    } catch (e) {
      _error.value = 'Yetenek eklenirken bir hata oluştu: $e';
    }
  }

  // Yetenek silme
  Future<void> removeSkill(String skillId) async {
    try {
      if (_profile.value != null) {
        await _profileService.removeSkill(_profile.value!.id, skillId);
        _skills.removeWhere((skill) => skill.id == skillId);
      }
    } catch (e) {
      _error.value = 'Yetenek silinirken bir hata oluştu: $e';
    }
  }
}

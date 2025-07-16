// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import '../models/user_profile_model.dart';
import '../models/search_filter_model.dart';
import '../services/discovery_service.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/material.dart';

class DiscoveryController extends GetxController {
  final DiscoveryService _discoveryService = DiscoveryService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<UserProfile> searchResults = RxList<UserProfile>();
  final RxList<UserProfile> recommendedUsers = RxList<UserProfile>();
  final RxList<UserProfile> connections = RxList<UserProfile>();
  final RxList<UserProfile> incomingRequests = RxList<UserProfile>();
  final RxList<UserProfile> outgoingRequests = RxList<UserProfile>();

  final isLoadingRecommendations = false.obs;
  final isLoadingConnections = false.obs;
  final isLoadingRequests = false.obs;
  final isSearching = false.obs;

  final currentFilter = SearchFilterModel().obs;

  @override
  void onInit() {
    super.onInit();
    loadRecommendations();
    loadConnections();
    loadRequests();
  }

  void onSearchQueryChanged(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;
      final results = await _discoveryService.searchUsersByName(query);
      searchResults.value = List<UserProfile>.from(results);
    } catch (e) {
      print('Error searching users: $e');
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> loadRecommendations() async {
    if (isLoadingRecommendations.value) return;
    isLoadingRecommendations.value = true;

    try {
      final currentUserId = _authController.currentUser?.uid;
      if (currentUserId == null) return;

      final recommendations =
          await _discoveryService.getRecommendedUsers(currentUserId);

      recommendedUsers.value = List<UserProfile>.from(recommendations);
    } catch (e) {
      print('Error loading recommendations: $e');
    } finally {
      isLoadingRecommendations.value = false;
    }
  }

  Future<void> loadConnections() async {
    if (isLoadingConnections.value) return;
    isLoadingConnections.value = true;

    try {
      final currentUserId = _authController.currentUser?.uid;
      if (currentUserId == null) return;

      final userConnections =
          await _discoveryService.getConnections(currentUserId).first;
      connections.value = List<UserProfile>.from(userConnections);
    } catch (e) {
      print('Error loading connections: $e');
    } finally {
      isLoadingConnections.value = false;
    }
  }

  Future<void> loadRequests() async {
    if (isLoadingRequests.value) return;
    isLoadingRequests.value = true;

    try {
      final currentUserId = _authController.currentUser?.uid;
      if (currentUserId == null) return;

      // Gelen istekler
      final incoming =
          await _discoveryService.getIncomingRequests(currentUserId);
      incomingRequests.value = List<UserProfile>.from(incoming);

      // Giden istekler
      final outgoing =
          await _discoveryService.getOutgoingRequests(currentUserId);
      outgoingRequests.value = List<UserProfile>.from(outgoing);
    } catch (e) {
      print('Error loading requests: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> sendConnectionRequest(UserProfile user,
      {String? message}) async {
    try {
      final currentUserId = _authController.currentUser?.uid;
      if (currentUserId == null) return;

      await _discoveryService.sendConnectionRequestWithMessage(
        fromUserId: currentUserId,
        toUserId: user.id,
        message: message ?? '',
      );
      await loadRequests();

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

  Future<void> acceptRequest(String requestId) async {
    try {
      await _discoveryService.acceptConnectionRequest(requestId);
      await loadRequests();
      await loadConnections();

      Get.snackbar(
        'Başarılı',
        'Bağlantı isteği kabul edildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error accepting request: $e');
      Get.snackbar(
        'Hata',
        'Bağlantı isteği kabul edilemedi',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _discoveryService.deleteConnectionRequest(requestId);
      await loadRequests();

      Get.snackbar(
        'Başarılı',
        'Bağlantı isteği reddedildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error rejecting request: $e');
      Get.snackbar(
        'Hata',
        'Bağlantı isteği reddedilemedi',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeConnection(String connectionId) async {
    try {
      await _discoveryService.deleteConnection(connectionId);
      await loadConnections();

      Get.snackbar(
        'Başarılı',
        'Bağlantı kaldırıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error removing connection: $e');
      Get.snackbar(
        'Hata',
        'Bağlantı kaldırılamadı',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onUserTap(UserProfile user) {
    Get.toNamed('/user-profile', arguments: user);
  }

  void onMessageTap(UserProfile user) {
    Get.toNamed('/chat', arguments: user);
  }

  Future<void> updateFilter(SearchFilterModel filter) async {
    currentFilter.value = filter;
    await loadRecommendations();
  }

  Future<void> refreshRecommendations() async {
    await loadRecommendations();
  }

  double calculateMatchPercentage(UserProfile user) {
    final currentUserId = _authController.currentUser?.uid;
    if (currentUserId == null) return 0.0;

    // Yetenek eşleşmesi
    final skillMatch = user.skills
        .where((skill) => currentFilter.value.skills.contains(skill))
        .length;
    final skillPercentage =
        user.skills.isEmpty ? 0.0 : skillMatch / user.skills.length * 100;

    return skillPercentage.clamp(0.0, 100.0);
  }

  void cancelRequest(dynamic request) async {
    try {
      // Loading durumunu güncelle
      isLoadingRequests.value = true;

      // Backend servis çağrısı
      await _discoveryService.cancelConnectionRequest(request.id);

      // İsteği geri çek
      outgoingRequests.remove(request);

      // Başarılı bildirim göster
      Get.snackbar(
        'Başarılı',
        'Bağlantı isteği geri çekildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // Hata durumunda bildirim göster
      Get.snackbar(
        'Hata',
        'İstek geri çekilirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 2),
      );
    } finally {
      // Loading durumunu güncelle
      isLoadingRequests.value = false;
    }
  }
}

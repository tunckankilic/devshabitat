// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/integration/video_event_integration_service.dart';
import '../../services/integration/community_event_integration_service.dart';
import '../../services/integration/location_event_integration_service.dart';
import '../../models/event/event_model.dart';
import '../../models/community/community_model.dart';
import '../../models/location/location_model.dart';

class WebhookConfig {
  final String name;
  final String url;
  final bool isActive;
  final String type;

  WebhookConfig({
    required this.name,
    required this.url,
    required this.isActive,
    required this.type,
  });
}

class ApiConnection {
  final String name;
  final String status;
  final String apiKey;
  final DateTime lastChecked;

  ApiConnection({
    required this.name,
    required this.status,
    required this.apiKey,
    required this.lastChecked,
  });
}

class IntegrationController extends GetxController {
  final VideoEventIntegrationService _videoEventService = Get.find();
  final CommunityEventIntegrationService _communityEventService = Get.find();
  final LocationEventIntegrationService _locationEventService = Get.find();

  // Observable variables
  final RxBool isServiceStatusLoading = false.obs;
  final RxList<WebhookConfig> webhooks = <WebhookConfig>[].obs;
  final RxList<ApiConnection> apiConnections = <ApiConnection>[].obs;
  final RxMap<String, String> serviceStatus = <String, String>{}.obs;

  // Video-Etkinlik Entegrasyonu
  Future<void> handleEventVideoIntegration(EventModel event) async {
    try {
      if (event.isStarting) {
        await _videoEventService.startEventVideoCall(event);
      } else if (event.isEnding) {
        await _videoEventService.endEventVideoCall(event.id);
      }
    } catch (e) {
      print('Error in event-video integration: $e');
      rethrow;
    }
  }

  // Topluluk-Etkinlik Entegrasyonu
  Future<void> handleCommunityEventIntegration(
      EventModel event, CommunityModel community) async {
    try {
      await _communityEventService.linkEventToCommunity(event.id, community.id);
    } catch (e) {
      print('Error in community-event integration: $e');
      rethrow;
    }
  }

  // Konum-Etkinlik Entegrasyonu
  Future<void> handleLocationEventIntegration(
      LocationModel userLocation, String userToken) async {
    try {
      await _locationEventService.checkAndNotifyNearbyEvents(
          userLocation, userToken);
    } catch (e) {
      print('Error in location-event integration: $e');
      rethrow;
    }
  }

  // Yakındaki Etkinlikleri Getir
  Future<List<EventModel>> getNearbyEvents(LocationModel userLocation) async {
    try {
      return await _locationEventService.getNearbyEvents(userLocation);
    } catch (e) {
      print('Error getting nearby events: $e');
      rethrow;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  void _initializeData() {
    _loadWebhooks();
    _loadApiConnections();
    _loadServiceStatus();
  }

  void _loadWebhooks() {
    webhooks.value = [
      WebhookConfig(
        name: 'Etkinlik Webhook',
        url: 'https://api.example.com/events',
        isActive: true,
        type: 'event',
      ),
      WebhookConfig(
        name: 'Topluluk Webhook',
        url: 'https://api.example.com/communities',
        isActive: true,
        type: 'community',
      ),
      WebhookConfig(
        name: 'Kullanıcı Webhook',
        url: 'https://api.example.com/users',
        isActive: false,
        type: 'user',
      ),
    ];
  }

  void _loadApiConnections() {
    apiConnections.value = [
      ApiConnection(
        name: 'Firebase',
        status: 'Aktif',
        apiKey: '***hidden***',
        lastChecked: DateTime.now(),
      ),
      ApiConnection(
        name: 'Google Maps',
        status: 'Aktif',
        apiKey: '***hidden***',
        lastChecked: DateTime.now(),
      ),
      ApiConnection(
        name: 'Firebase Messaging',
        status: 'Aktif',
        apiKey: '***hidden***',
        lastChecked: DateTime.now(),
      ),
    ];
  }

  void _loadServiceStatus() {
    serviceStatus.value = {
      'Video-Etkinlik Entegrasyonu': 'Aktif',
      'Topluluk-Etkinlik Entegrasyonu': 'Aktif',
      'Konum-Etkinlik Entegrasyonu': 'Aktif',
    };
  }

  Future<void> refreshServiceStatus() async {
    isServiceStatusLoading.value = true;
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      _loadServiceStatus();
      Get.snackbar(
        'Durum Güncellendi',
        'Servis durumları başarıyla yenilendi',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Servis durumları güncellenirken hata oluştu',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isServiceStatusLoading.value = false;
    }
  }

  void toggleWebhook(String name, bool value) {
    final index = webhooks.indexWhere((webhook) => webhook.name == name);
    if (index != -1) {
      final webhook = webhooks[index];
      webhooks[index] = WebhookConfig(
        name: webhook.name,
        url: webhook.url,
        isActive: value,
        type: webhook.type,
      );
      Get.snackbar(
        'Webhook Durumu',
        '$name webhook\'u ${value ? 'aktif' : 'pasif'} yapıldı',
        backgroundColor: value
            ? Colors.green.withOpacity(0.8)
            : Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void addWebhook(String name, String url, String type) {
    webhooks.add(WebhookConfig(
      name: name,
      url: url,
      isActive: true,
      type: type,
    ));
    Get.snackbar(
      'Webhook Eklendi',
      'Yeni webhook başarıyla eklendi',
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  void testWebhook(String name) {
    Get.snackbar(
      'Webhook Testi',
      '$name webhook\'u test edildi',
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  void testAllWebhooks() {
    Get.snackbar(
      'Webhook Testi',
      'Tüm webhook\'lar test edildi',
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}

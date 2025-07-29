// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/notification_model.dart';
import '../../repositories/auth_repository.dart';

class IntegrationNotificationController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepository = Get.find();

  // Integration-specific notification lists
  final RxList<NotificationModel> integrationNotifications =
      <NotificationModel>[].obs;
  final RxList<NotificationModel> webhookNotifications =
      <NotificationModel>[].obs;
  final RxList<NotificationModel> serviceAlerts = <NotificationModel>[].obs;

  // Integration notification settings
  final RxBool isIntegrationNotificationsEnabled = true.obs;
  final RxBool isWebhookNotificationsEnabled = true.obs;
  final RxBool isServiceAlertsEnabled = true.obs;
  final RxBool isCustomRulesEnabled = true.obs;

  // Custom notification rules
  final RxList<Map<String, dynamic>> customRules = <Map<String, dynamic>>[].obs;

  // Integration status
  final RxBool isGitHubConnected = false.obs;
  final RxBool isSlackConnected = false.obs;
  final RxBool isDiscordConnected = false.obs;
  final RxBool isEmailConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeIntegrationNotifications();
    _loadIntegrationSettings();
    _setupIntegrationListeners();
  }

  Future<void> _initializeIntegrationNotifications() async {
    // Bildirim izinlerini iste
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Foreground mesajları için
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Background/terminated mesajları için
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Initial message kontrolü
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleInitialMessage(initialMessage);
      }
    }
  }

  Future<void> _loadIntegrationSettings() async {
    try {
      final userId = _authRepository.currentUser?.uid;
      if (userId != null) {
        final doc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('preferences')
            .doc('integration_notifications')
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          isIntegrationNotificationsEnabled.value =
              data['isIntegrationNotificationsEnabled'] ?? true;
          isWebhookNotificationsEnabled.value =
              data['isWebhookNotificationsEnabled'] ?? true;
          isServiceAlertsEnabled.value = data['isServiceAlertsEnabled'] ?? true;
          isCustomRulesEnabled.value = data['isCustomRulesEnabled'] ?? true;

          // Integration status
          isGitHubConnected.value = data['isGitHubConnected'] ?? false;
          isSlackConnected.value = data['isSlackConnected'] ?? false;
          isDiscordConnected.value = data['isDiscordConnected'] ?? false;
          isEmailConnected.value = data['isEmailConnected'] ?? false;

          // Custom rules
          final rules = data['customRules'] as List<dynamic>?;
          if (rules != null) {
            customRules.value = rules.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (e) {
      print('Error loading integration settings: $e');
    }
  }

  void _setupIntegrationListeners() {
    final userId = _authRepository.currentUser?.uid;
    if (userId != null) {
      // Integration notifications listener
      _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('type', isEqualTo: 'integration')
          .snapshots()
          .listen((snapshot) {
        _updateIntegrationNotifications(snapshot.docs);
      });

      // Webhook notifications listener
      _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('type', isEqualTo: 'webhook')
          .snapshots()
          .listen((snapshot) {
        _updateWebhookNotifications(snapshot.docs);
      });

      // Service alerts listener
      _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('type', isEqualTo: 'service_alert')
          .snapshots()
          .listen((snapshot) {
        _updateServiceAlerts(snapshot.docs);
      });
    }
  }

  void _updateIntegrationNotifications(List<QueryDocumentSnapshot> docs) {
    integrationNotifications.value = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return NotificationModel.fromJson({...data, 'id': doc.id});
    }).toList();
    integrationNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _updateWebhookNotifications(List<QueryDocumentSnapshot> docs) {
    webhookNotifications.value = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return NotificationModel.fromJson({...data, 'id': doc.id});
    }).toList();
    webhookNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _updateServiceAlerts(List<QueryDocumentSnapshot> docs) {
    serviceAlerts.value = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return NotificationModel.fromJson({...data, 'id': doc.id});
    }).toList();
    serviceAlerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Integration-specific message handling
    if (message.data['category'] == 'integration' ||
        message.data['category'] == 'webhook' ||
        message.data['category'] == 'service_alert') {
      if (!_shouldShowNotification(message.data)) {
        return;
      }

      if (message.notification != null) {
        Get.snackbar(
          message.notification!.title ?? 'Entegrasyon Bildirimi',
          message.notification!.body ?? '',
          duration: Duration(seconds: 5),
          onTap: (_) => _handleNotificationTap(message.data),
        );
      }
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['category'] == 'integration' ||
        message.data['category'] == 'webhook' ||
        message.data['category'] == 'service_alert') {
      _handleNotificationTap(message.data);
    }
  }

  void _handleInitialMessage(RemoteMessage message) {
    if (message.data['category'] == 'integration' ||
        message.data['category'] == 'webhook' ||
        message.data['category'] == 'service_alert') {
      _handleNotificationTap(message.data);
    }
  }

  bool _shouldShowNotification(Map<String, dynamic> data) {
    final category = data['category'] as String?;

    switch (category) {
      case 'integration':
        return isIntegrationNotificationsEnabled.value;
      case 'webhook':
        return isWebhookNotificationsEnabled.value;
      case 'service_alert':
        return isServiceAlertsEnabled.value;
      default:
        return true;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final category = data['category'] as String?;

    switch (category) {
      case 'integration':
        _handleIntegrationNotification(data);
        break;
      case 'webhook':
        _handleWebhookNotification(data);
        break;
      case 'service_alert':
        _handleServiceAlert(data);
        break;
      default:
        if (data['route'] != null) {
          String route = data['route'];
          if (Get.currentRoute != route) {
            Get.toNamed(route);
          }
        }
    }
  }

  void _handleIntegrationNotification(Map<String, dynamic> data) {
    final integrationType = data['integrationType'] as String?;

    switch (integrationType) {
      case 'github':
        Get.toNamed('/integration/github', arguments: data);
        break;
      case 'slack':
        Get.toNamed('/integration/slack', arguments: data);
        break;
      case 'discord':
        Get.toNamed('/integration/discord', arguments: data);
        break;
      case 'email':
        Get.toNamed('/integration/email', arguments: data);
        break;
      default:
        Get.toNamed('/integrations', arguments: data);
    }
  }

  void _handleWebhookNotification(Map<String, dynamic> data) {
    final webhookId = data['webhookId'] as String?;
    if (webhookId != null) {
      Get.toNamed('/webhooks/$webhookId', arguments: data);
    } else {
      Get.toNamed('/webhooks', arguments: data);
    }
  }

  void _handleServiceAlert(Map<String, dynamic> data) {
    final serviceName = data['serviceName'] as String?;
    final alertType = data['alertType'] as String?;

    Get.toNamed('/service-alerts', arguments: {
      'serviceName': serviceName,
      'alertType': alertType,
      ...data,
    });
  }

  // Integration settings management
  Future<void> updateIntegrationNotificationSetting(bool value) async {
    isIntegrationNotificationsEnabled.value = value;
    await _saveIntegrationSettings();
  }

  Future<void> updateWebhookNotificationSetting(bool value) async {
    isWebhookNotificationsEnabled.value = value;
    await _saveIntegrationSettings();
  }

  Future<void> updateServiceAlertSetting(bool value) async {
    isServiceAlertsEnabled.value = value;
    await _saveIntegrationSettings();
  }

  Future<void> updateCustomRulesSetting(bool value) async {
    isCustomRulesEnabled.value = value;
    await _saveIntegrationSettings();
  }

  Future<void> _saveIntegrationSettings() async {
    try {
      final userId = _authRepository.currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('preferences')
            .doc('integration_notifications')
            .set({
          'isIntegrationNotificationsEnabled':
              isIntegrationNotificationsEnabled.value,
          'isWebhookNotificationsEnabled': isWebhookNotificationsEnabled.value,
          'isServiceAlertsEnabled': isServiceAlertsEnabled.value,
          'isCustomRulesEnabled': isCustomRulesEnabled.value,
          'isGitHubConnected': isGitHubConnected.value,
          'isSlackConnected': isSlackConnected.value,
          'isDiscordConnected': isDiscordConnected.value,
          'isEmailConnected': isEmailConnected.value,
          'customRules': customRules.toList(),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error saving integration settings: $e');
    }
  }

  // Custom rules management
  Future<void> addCustomRule(Map<String, dynamic> rule) async {
    customRules.add(rule);
    await _saveIntegrationSettings();
  }

  Future<void> removeCustomRule(int index) async {
    if (index >= 0 && index < customRules.length) {
      customRules.removeAt(index);
      await _saveIntegrationSettings();
    }
  }

  Future<void> updateCustomRule(int index, Map<String, dynamic> rule) async {
    if (index >= 0 && index < customRules.length) {
      customRules[index] = rule;
      await _saveIntegrationSettings();
    }
  }

  // Integration status management
  Future<void> updateIntegrationStatus(String integration, bool status) async {
    switch (integration) {
      case 'github':
        isGitHubConnected.value = status;
        break;
      case 'slack':
        isSlackConnected.value = status;
        break;
      case 'discord':
        isDiscordConnected.value = status;
        break;
      case 'email':
        isEmailConnected.value = status;
        break;
    }
    await _saveIntegrationSettings();
  }

  // Test integration notifications
  Future<void> sendTestIntegrationNotification({
    required String title,
    required String body,
    required String integrationType,
    Map<String, dynamic>? additionalData,
  }) async {
    final message = RemoteMessage(
      notification: RemoteNotification(
        title: title,
        body: body,
      ),
      data: {
        'category': 'integration',
        'integrationType': integrationType,
        'route': '/integrations',
        ...?additionalData,
      },
    );

    _handleForegroundMessage(message);
  }

  Future<String?> getDeviceToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

  // Get all integration notifications
  List<NotificationModel> getAllIntegrationNotifications() {
    final allNotifications = <NotificationModel>[];
    allNotifications.addAll(integrationNotifications);
    allNotifications.addAll(webhookNotifications);
    allNotifications.addAll(serviceAlerts);
    allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allNotifications;
  }

  // Get unread count for integration notifications
  int getUnreadIntegrationCount() {
    return getAllIntegrationNotifications().where((n) => !n.isRead).length;
  }

  // Mark all integration notifications as read
  Future<void> markAllIntegrationNotificationsAsRead() async {
    try {
      final userId = _authRepository.currentUser?.uid;
      if (userId != null) {
        final batch = _firestore.batch();
        final allNotifications = getAllIntegrationNotifications();
        final unreadNotifications =
            allNotifications.where((n) => !n.isRead).toList();

        for (var notification in unreadNotifications) {
          final ref = _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc(notification.id);
          batch.update(ref, {'isRead': true});
        }

        await batch.commit();
      }
    } catch (e) {
      print('Error marking integration notifications as read: $e');
    }
  }
}

// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  connection, // Connection requests, accepted connections
  message, // New messages, mentions
  event, // Event invites, reminders
  community, // Community updates, mentions
  project, // Project updates, mentions
  integration, // Integration notifications, webhooks
  webhook, // Webhook notifications
  service_alert, // Service alerts, system issues
  system // System notifications, updates
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isRead: json['isRead'] as bool? ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.system,
      ),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  String get notificationIcon {
    switch (type) {
      case NotificationType.connection:
        return 'person_add';
      case NotificationType.message:
        return 'message';
      case NotificationType.event:
        return 'event';
      case NotificationType.community:
        return 'groups';
      case NotificationType.project:
        return 'code';
      case NotificationType.integration:
        return 'integration';
      case NotificationType.webhook:
        return 'webhook';
      case NotificationType.service_alert:
        return 'warning';
      case NotificationType.system:
        return 'info';
    }
  }

  String get typeLabel {
    switch (type) {
      case NotificationType.connection:
        return 'Connection';
      case NotificationType.message:
        return 'Message';
      case NotificationType.event:
        return 'Event';
      case NotificationType.community:
        return 'Community';
      case NotificationType.project:
        return 'Project';
      case NotificationType.integration:
        return 'Integration';
      case NotificationType.webhook:
        return 'Webhook';
      case NotificationType.service_alert:
        return 'Service Alert';
      case NotificationType.system:
        return 'System';
    }
  }
}

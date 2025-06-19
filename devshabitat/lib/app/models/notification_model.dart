import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'data': data,
        'createdAt': createdAt,
        'isRead': isRead,
      };

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        body: map['body'] ?? '',
        imageUrl: map['imageUrl'],
        data: map['data'],
        createdAt: (map['createdAt'] as Timestamp).toDate(),
        isRead: map['isRead'] ?? false,
      );
}

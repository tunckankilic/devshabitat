import 'package:cloud_firestore/cloud_firestore.dart';

enum ConnectionStatus { pending, accepted, declined, blocked }

class ConnectionModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String message;
  final ConnectionStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  ConnectionModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      message: json['message'] as String,
      status: ConnectionStatus.values.firstWhere(
        (e) => e.toString() == 'ConnectionStatus.${json['status']}',
        orElse: () => ConnectionStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }

  factory ConnectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConnectionModel(
      id: doc.id,
      fromUserId: data['fromUserId'] as String,
      toUserId: data['toUserId'] as String,
      message: data['message'] as String,
      status: ConnectionStatus.values.firstWhere(
        (e) => e.toString() == 'ConnectionStatus.${data['status']}',
        orElse: () => ConnectionStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'message': message,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'message': message,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  ConnectionModel copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? message,
    ConnectionStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return ConnectionModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

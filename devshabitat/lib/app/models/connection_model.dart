import 'package:cloud_firestore/cloud_firestore.dart';

enum ConnectionStatus {
  pending,
  accepted,
  declined,
  blocked,
}

class ConnectionModel {
  final String id;
  final String userId;
  final String targetUserId;
  final String status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime lastActive;
  final List<String> skills;
  final bool isOnline;
  final Map<String, dynamic>? metadata;
  final GeoPoint? location;
  final int yearsOfExperience;

  ConnectionModel({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.rejectedAt,
    required this.lastActive,
    required this.skills,
    required this.isOnline,
    this.metadata,
    this.location,
    required this.yearsOfExperience,
  });

  Map<String, dynamic>? get locationMap {
    if (location == null) return null;
    return {
      'latitude': location!.latitude,
      'longitude': location!.longitude,
    };
  }

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      targetUserId: json['targetUserId'] as String,
      status: json['status'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      acceptedAt: json['acceptedAt'] != null
          ? (json['acceptedAt'] as Timestamp).toDate()
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? (json['rejectedAt'] as Timestamp).toDate()
          : null,
      lastActive: (json['lastActive'] as Timestamp).toDate(),
      skills: List<String>.from(json['skills'] ?? []),
      isOnline: json['isOnline'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      location: json['location'] as GeoPoint?,
      yearsOfExperience: json['yearsOfExperience'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'targetUserId': targetUserId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'rejectedAt': rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'lastActive': Timestamp.fromDate(lastActive),
      'skills': skills,
      'isOnline': isOnline,
      'metadata': metadata,
      'location': location,
      'yearsOfExperience': yearsOfExperience,
    };
  }

  ConnectionModel copyWith({
    String? id,
    String? userId,
    String? targetUserId,
    String? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    DateTime? lastActive,
    List<String>? skills,
    bool? isOnline,
    Map<String, dynamic>? metadata,
    GeoPoint? location,
    int? yearsOfExperience,
  }) {
    return ConnectionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetUserId: targetUserId ?? this.targetUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      lastActive: lastActive ?? this.lastActive,
      skills: skills ?? this.skills,
      isOnline: isOnline ?? this.isOnline,
      metadata: metadata ?? this.metadata,
      location: location ?? this.location,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    );
  }

  @override
  String toString() {
    return 'ConnectionModel(id: $id, userId: $userId, targetUserId: $targetUserId, status: $status)';
  }
}

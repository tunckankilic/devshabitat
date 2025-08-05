import 'package:get/get.dart';

class CollaborationRequestModel {
  final String id;
  final String repositoryOwner;
  final String repositoryName;
  final String requesterId;
  final String requesterUsername;
  final String collaborationType;
  final String message;
  final List<String> requiredSkills;
  final DateTime createdAt;
  final String status;

  CollaborationRequestModel({
    required this.id,
    required this.repositoryOwner,
    required this.repositoryName,
    required this.requesterId,
    required this.requesterUsername,
    required this.collaborationType,
    required this.message,
    required this.requiredSkills,
    required this.createdAt,
    required this.status,
  });

  factory CollaborationRequestModel.fromJson(Map<String, dynamic> json) {
    return CollaborationRequestModel(
      id: json['id'],
      repositoryOwner: json['repository_owner'],
      repositoryName: json['repository_name'],
      requesterId: json['requester_id'],
      requesterUsername: json['requester_username'],
      collaborationType: json['collaboration_type'],
      message: json['message'],
      requiredSkills: List<String>.from(json['required_skills']),
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repository_owner': repositoryOwner,
      'repository_name': repositoryName,
      'requester_id': requesterId,
      'requester_username': requesterUsername,
      'collaboration_type': collaborationType,
      'message': message,
      'required_skills': requiredSkills,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  CollaborationRequestModel copyWith({
    String? id,
    String? repositoryOwner,
    String? repositoryName,
    String? requesterId,
    String? requesterUsername,
    String? collaborationType,
    String? message,
    List<String>? requiredSkills,
    DateTime? createdAt,
    String? status,
  }) {
    return CollaborationRequestModel(
      id: id ?? this.id,
      repositoryOwner: repositoryOwner ?? this.repositoryOwner,
      repositoryName: repositoryName ?? this.repositoryName,
      requesterId: requesterId ?? this.requesterId,
      requesterUsername: requesterUsername ?? this.requesterUsername,
      collaborationType: collaborationType ?? this.collaborationType,
      message: message ?? this.message,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

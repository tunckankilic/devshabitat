import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class EnhancedUserModel {
  final RxString id;
  final RxString email;
  final RxString? displayName;
  final RxString? photoURL;
  final RxMap<String, dynamic>? connections;
  final RxMap<String, dynamic>? preferences;
  final Rx<DateTime?> createdAt;
  final Rx<DateTime?> updatedAt;
  final Rx<DateTime?> lastSeen;
  final RxList<String>? skills;
  final RxList<Map<String, dynamic>>? experience;
  final RxString? githubUsername;
  final RxString? githubAvatarUrl;
  final RxString? githubId;
  final RxMap<String, dynamic>? githubData;

  EnhancedUserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? connections,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
    List<String>? skills,
    List<Map<String, dynamic>>? experience,
    String? githubUsername,
    String? githubAvatarUrl,
    String? githubId,
    Map<String, dynamic>? githubData,
  })  : id = id.obs,
        email = email.obs,
        displayName = displayName?.obs,
        photoURL = photoURL?.obs,
        connections = connections != null
            ? RxMap<String, dynamic>.from(connections)
            : null,
        preferences = preferences != null
            ? RxMap<String, dynamic>.from(preferences)
            : null,
        createdAt = createdAt.obs,
        updatedAt = updatedAt.obs,
        lastSeen = lastSeen.obs,
        skills = skills != null ? RxList<String>.from(skills) : null,
        experience = experience != null
            ? RxList<Map<String, dynamic>>.from(experience)
            : null,
        githubUsername = githubUsername?.obs,
        githubAvatarUrl = githubAvatarUrl?.obs,
        githubId = githubId?.obs,
        githubData =
            githubData != null ? RxMap<String, dynamic>.from(githubData) : null;

  factory EnhancedUserModel.fromFirebase(User user) {
    return EnhancedUserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastSeen: DateTime.now(),
    );
  }

  factory EnhancedUserModel.fromJson(Map<String, dynamic> json) {
    return EnhancedUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      connections: json['connections'] as Map<String, dynamic>?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      lastSeen: (json['lastSeen'] as Timestamp?)?.toDate(),
      skills: (json['skills'] as List<dynamic>?)?.cast<String>(),
      experience: (json['experience'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      githubUsername: json['githubUsername'] as String?,
      githubAvatarUrl: json['githubAvatarUrl'] as String?,
      githubId: json['githubId'] as String?,
      githubData: json['githubData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'email': email.value,
      'displayName': displayName?.value,
      'photoURL': photoURL?.value,
      'connections': connections?.value,
      'preferences': preferences?.value,
      'createdAt':
          createdAt.value != null ? Timestamp.fromDate(createdAt.value!) : null,
      'updatedAt':
          updatedAt.value != null ? Timestamp.fromDate(updatedAt.value!) : null,
      'lastSeen':
          lastSeen.value != null ? Timestamp.fromDate(lastSeen.value!) : null,
      'skills': skills?.value,
      'experience': experience?.value,
      'githubUsername': githubUsername?.value,
      'githubAvatarUrl': githubAvatarUrl?.value,
      'githubId': githubId?.value,
      'githubData': githubData?.value,
    };
  }

  EnhancedUserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? connections,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
    List<String>? skills,
    List<Map<String, dynamic>>? experience,
    String? githubUsername,
    String? githubAvatarUrl,
    String? githubId,
    Map<String, dynamic>? githubData,
  }) {
    return EnhancedUserModel(
      id: id ?? this.id.value,
      email: email ?? this.email.value,
      displayName: displayName ?? this.displayName?.value,
      photoURL: photoURL ?? this.photoURL?.value,
      connections: connections ?? this.connections?.value,
      preferences: preferences ?? this.preferences?.value,
      createdAt: createdAt ?? this.createdAt.value,
      updatedAt: updatedAt ?? this.updatedAt.value,
      lastSeen: lastSeen ?? this.lastSeen.value,
      skills: skills ?? this.skills?.value,
      experience: experience ?? this.experience?.value,
      githubUsername: githubUsername ?? this.githubUsername?.value,
      githubAvatarUrl: githubAvatarUrl ?? this.githubAvatarUrl?.value,
      githubId: githubId ?? this.githubId?.value,
      githubData: githubData ?? this.githubData?.value,
    );
  }

  bool get isValid => id.value.isNotEmpty && email.value.isNotEmpty;

  void updateLastSeen() {
    lastSeen.value = DateTime.now();
  }

  void addSkill(String skill) {
    skills?.add(skill);
  }

  void removeSkill(String skill) {
    skills?.remove(skill);
  }

  void addExperience(Map<String, dynamic> exp) {
    experience?.add(exp);
  }

  void removeExperience(int index) {
    if (index >= 0 && index < (experience?.length ?? 0)) {
      experience?.removeAt(index);
    }
  }

  void updatePreferences(Map<String, dynamic> newPreferences) {
    preferences?.addAll(newPreferences);
  }

  void addConnection(String userId, Map<String, dynamic> connectionData) {
    connections?.addAll({userId: connectionData});
  }

  void removeConnection(String userId) {
    connections?.remove(userId);
  }
}

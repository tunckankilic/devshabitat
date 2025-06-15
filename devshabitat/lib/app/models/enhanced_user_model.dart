import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class EnhancedUserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? bio;
  final Map<String, dynamic>? preferences;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSeen;
  final List<String>? connections;
  final String? githubUsername;
  final String? githubAvatarUrl;
  final String? githubId;
  final Map<String, dynamic>? githubData;
  final List<String>? skills;
  final List<Map<String, dynamic>>? experience;

  // Reactive properties
  final RxString id;
  final RxString emailRx;
  final RxString? displayNameRx;
  final RxString? photoURLRx;
  final RxMap<String, dynamic>? preferencesRx;
  final Rx<DateTime?> createdAtRx;
  final Rx<DateTime?> updatedAtRx;
  final Rx<DateTime?> lastSeenRx;
  final RxList<String>? connectionsRx;
  final RxString? githubUsernameRx;
  final RxString? githubAvatarUrlRx;
  final RxString? githubIdRx;
  final RxMap<String, dynamic>? githubDataRx;
  final RxList<String>? skillsRx;
  final RxList<Map<String, dynamic>>? experienceRx;

  EnhancedUserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.bio,
    this.preferences,
    this.createdAt,
    this.updatedAt,
    this.lastSeen,
    this.connections,
    this.githubUsername,
    this.githubAvatarUrl,
    this.githubId,
    this.githubData,
    this.skills,
    this.experience,
  })  : id = uid.obs,
        emailRx = email.obs,
        displayNameRx = displayName?.obs,
        photoURLRx = photoURL?.obs,
        preferencesRx = preferences?.obs,
        createdAtRx = Rx<DateTime?>(createdAt),
        updatedAtRx = Rx<DateTime?>(updatedAt),
        lastSeenRx = Rx<DateTime?>(lastSeen),
        connectionsRx = connections?.obs,
        githubUsernameRx = githubUsername?.obs,
        githubAvatarUrlRx = githubAvatarUrl?.obs,
        githubIdRx = githubId?.obs,
        githubDataRx = githubData?.obs,
        skillsRx = skills?.obs,
        experienceRx = experience?.obs;

  factory EnhancedUserModel.fromFirebase(User user) {
    return EnhancedUserModel(
      uid: user.uid,
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
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      bio: json['bio'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      lastSeen: json['lastSeen'] != null
          ? (json['lastSeen'] as Timestamp).toDate()
          : null,
      connections: (json['connections'] as List<dynamic>?)?.cast<String>(),
      githubUsername: json['githubUsername'] as String?,
      githubAvatarUrl: json['githubAvatarUrl'] as String?,
      githubId: json['githubId'] as String?,
      githubData: json['githubData'] as Map<String, dynamic>?,
      skills: (json['skills'] as List<dynamic>?)?.cast<String>(),
      experience: (json['experience'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'preferences': preferences,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastSeen': lastSeen,
      'connections': connections,
      'githubUsername': githubUsername,
      'githubAvatarUrl': githubAvatarUrl,
      'githubId': githubId,
      'githubData': githubData,
      'skills': skills,
      'experience': experience,
    };
  }

  EnhancedUserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? bio,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
    List<String>? connections,
    String? githubUsername,
    String? githubAvatarUrl,
    String? githubId,
    Map<String, dynamic>? githubData,
    List<String>? skills,
    List<Map<String, dynamic>>? experience,
  }) {
    return EnhancedUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
      connections: connections ?? this.connections,
      githubUsername: githubUsername ?? this.githubUsername,
      githubAvatarUrl: githubAvatarUrl ?? this.githubAvatarUrl,
      githubId: githubId ?? this.githubId,
      githubData: githubData ?? this.githubData,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
    );
  }

  bool get isValid => uid.isNotEmpty && email.isNotEmpty;

  void updateLastSeen() {
    lastSeenRx.value = DateTime.now();
  }

  void addSkill(String skill) {
    skillsRx?.add(skill);
  }

  void removeSkill(String skill) {
    skillsRx?.remove(skill);
  }

  void addExperience(Map<String, dynamic> exp) {
    experienceRx?.add(exp);
  }

  void removeExperience(int index) {
    if (index >= 0 && index < (experienceRx?.length ?? 0)) {
      experienceRx?.removeAt(index);
    }
  }

  void updatePreferences(Map<String, dynamic> newPreferences) {
    preferencesRx?.addAll(newPreferences);
  }

  void addConnection(String userId) {
    connectionsRx?.add(userId);
  }

  void removeConnection(String userId) {
    connectionsRx?.remove(userId);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'location/location_model.dart';

class WorkExperience {
  final String title;
  final String company;
  final bool isCurrentRole;

  WorkExperience({
    required this.title,
    required this.company,
    this.isCurrentRole = false,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      title: json['title'] as String,
      company: json['company'] as String,
      isCurrentRole: json['isCurrentRole'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'company': company,
      'isCurrentRole': isCurrentRole,
    };
  }
}

class Education {
  final String school;
  final String degree;
  final String field;
  final bool isCurrentlyStudying;

  Education({
    required this.school,
    required this.degree,
    required this.field,
    this.isCurrentlyStudying = false,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      school: json['school'] as String,
      degree: json['degree'] as String,
      field: json['field'] as String,
      isCurrentlyStudying: json['isCurrentlyStudying'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'school': school,
      'degree': degree,
      'field': field,
      'isCurrentlyStudying': isCurrentlyStudying,
    };
  }
}

class EnhancedUserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? bio;
  final String? title;
  final String? company;
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
  final List<String>? languages;
  final List<String>? frameworks;
  final List<WorkExperience>? workExperience;
  final List<Education>? education;
  final LocationModel? location;
  final int yearsOfExperience;

  // Reactive properties
  final RxString id;
  final RxString emailRx;
  final RxString? displayNameRx;
  final RxString? photoURLRx;
  final RxString? titleRx;
  final RxString? companyRx;
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
  final RxList<String>? languagesRx;
  final RxList<String>? frameworksRx;
  final RxList<WorkExperience>? workExperienceRx;
  final RxList<Education>? educationRx;
  final Rx<LocationModel?> locationRx;
  final RxInt yearsOfExperienceRx;

  EnhancedUserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.bio,
    this.title,
    this.company,
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
    this.languages,
    this.frameworks,
    this.workExperience,
    this.education,
    this.location,
    this.yearsOfExperience = 0,
  })  : id = uid.obs,
        emailRx = email.obs,
        displayNameRx = displayName?.obs,
        photoURLRx = photoURL?.obs,
        titleRx = title?.obs,
        companyRx = company?.obs,
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
        experienceRx = experience?.obs,
        languagesRx = languages?.obs,
        frameworksRx = frameworks?.obs,
        workExperienceRx = workExperience?.obs,
        educationRx = education?.obs,
        locationRx = Rx<LocationModel?>(location),
        yearsOfExperienceRx = yearsOfExperience.obs;

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
      title: json['title'] as String?,
      company: json['company'] as String?,
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
      languages: (json['languages'] as List<dynamic>?)?.cast<String>(),
      frameworks: (json['frameworks'] as List<dynamic>?)?.cast<String>(),
      workExperience: (json['workExperience'] as List<dynamic>?)
          ?.map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
          .toList(),
      education: (json['education'] as List<dynamic>?)
          ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList(),
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      yearsOfExperience: json['yearsOfExperience'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'title': title,
      'company': company,
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
      'languages': languages,
      'frameworks': frameworks,
      'workExperience': workExperience,
      'education': education,
      'location': location?.toJson(),
      'yearsOfExperience': yearsOfExperience,
    };
  }

  EnhancedUserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? bio,
    String? title,
    String? company,
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
    List<String>? languages,
    List<String>? frameworks,
    List<WorkExperience>? workExperience,
    List<Education>? education,
    LocationModel? location,
    int? yearsOfExperience,
  }) {
    return EnhancedUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      title: title ?? this.title,
      company: company ?? this.company,
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
      languages: languages ?? this.languages,
      frameworks: frameworks ?? this.frameworks,
      workExperience: workExperience ?? this.workExperience,
      education: education ?? this.education,
      location: location ?? this.location,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
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

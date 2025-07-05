import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';
import 'privacy_settings_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? bio;
  final List<String> technologies;
  final PrivacySettings privacySettings;
  final String? phoneNumber;
  final bool emailVerified;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.displayName,
    this.email,
    this.photoUrl,
    this.bio,
    this.technologies = const [],
    PrivacySettings? privacySettings,
    this.phoneNumber,
    this.emailVerified = false,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  }) : privacySettings = privacySettings ?? PrivacySettings();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    String? bio,
    List<String>? technologies,
    PrivacySettings? privacySettings,
    String? phoneNumber,
    bool? emailVerified,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      technologies: technologies ?? this.technologies,
      privacySettings: privacySettings ?? this.privacySettings,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WorkExperience {
  final String company;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final String description;
  final List<String> skills;
  final bool isCurrentRole;

  WorkExperience({
    required this.company,
    required this.title,
    required this.startDate,
    this.endDate,
    required this.description,
    this.skills = const [],
    this.isCurrentRole = false,
  });

  factory WorkExperience.fromMap(Map<String, dynamic> map) {
    return WorkExperience(
      company: map['company'] ?? '',
      title: map['title'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      description: map['description'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      isCurrentRole: map['isCurrentRole'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'title': title,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'description': description,
      'skills': skills,
      'isCurrentRole': isCurrentRole,
    };
  }
}

class Education {
  final String school;
  final String degree;
  final String field;
  final DateTime startDate;
  final DateTime? endDate;
  final double? gpa;
  final List<String> activities;
  final bool isCurrentlyStudying;

  Education({
    required this.school,
    required this.degree,
    required this.field,
    required this.startDate,
    this.endDate,
    this.gpa,
    this.activities = const [],
    this.isCurrentlyStudying = false,
  });

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      school: map['school'] ?? '',
      degree: map['degree'] ?? '',
      field: map['field'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      gpa: map['gpa']?.toDouble(),
      activities: List<String>.from(map['activities'] ?? []),
      isCurrentlyStudying: map['isCurrentlyStudying'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'school': school,
      'degree': degree,
      'field': field,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'gpa': gpa,
      'activities': activities,
      'isCurrentlyStudying': isCurrentlyStudying,
    };
  }
}

class Project {
  final String name;
  final String description;
  final String? url;
  final String? repositoryUrl;
  final List<String> technologies;
  final List<String> images;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isOpenSource;
  final bool isFeatured;

  Project({
    required this.name,
    required this.description,
    this.url,
    this.repositoryUrl,
    this.technologies = const [],
    this.images = const [],
    required this.startDate,
    this.endDate,
    this.isOpenSource = false,
    this.isFeatured = false,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      url: map['url'],
      repositoryUrl: map['repositoryUrl'],
      technologies: List<String>.from(map['technologies'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      isOpenSource: map['isOpenSource'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'url': url,
      'repositoryUrl': repositoryUrl,
      'technologies': technologies,
      'images': images,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isOpenSource': isOpenSource,
      'isFeatured': isFeatured,
    };
  }
}

class Certificate {
  final String name;
  final String issuer;
  final String credentialId;
  final String? credentialUrl;
  final DateTime issueDate;
  final DateTime? expirationDate;
  final List<String> skills;

  Certificate({
    required this.name,
    required this.issuer,
    required this.credentialId,
    this.credentialUrl,
    required this.issueDate,
    this.expirationDate,
    this.skills = const [],
  });

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      name: map['name'] ?? '',
      issuer: map['issuer'] ?? '',
      credentialId: map['credentialId'] ?? '',
      credentialUrl: map['credentialUrl'],
      issueDate: (map['issueDate'] as Timestamp).toDate(),
      expirationDate: map['expirationDate'] != null
          ? (map['expirationDate'] as Timestamp).toDate()
          : null,
      skills: List<String>.from(map['skills'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'issuer': issuer,
      'credentialId': credentialId,
      'credentialUrl': credentialUrl,
      'issueDate': Timestamp.fromDate(issueDate),
      'expirationDate':
          expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
      'skills': skills,
    };
  }
}

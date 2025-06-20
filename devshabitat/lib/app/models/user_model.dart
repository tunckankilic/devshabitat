import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? bio;
  final String? title;
  final String? company;
  final GeoPoint? location;
  final String? locationName;
  final List<String> skills;
  final List<String> interests;
  final List<String> languages;
  final List<String> frameworks;
  final int yearsOfExperience;
  final bool isAvailableForWork;
  final Map<String, dynamic> githubData;
  final String? githubUsername;
  final List<String> portfolioUrls;
  final List<WorkExperience> workExperience;
  final List<Education> education;
  final List<Project> projects;
  final List<Certificate> certificates;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeen;
  final bool isOnline;
  final Map<String, dynamic> socialLinks;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.bio,
    this.title,
    this.company,
    this.location,
    this.locationName,
    this.skills = const [],
    this.interests = const [],
    this.languages = const [],
    this.frameworks = const [],
    this.yearsOfExperience = 0,
    this.isAvailableForWork = true,
    this.githubData = const {},
    this.githubUsername,
    this.portfolioUrls = const [],
    this.workExperience = const [],
    this.education = const [],
    this.projects = const [],
    this.certificates = const [],
    required this.createdAt,
    required this.updatedAt,
    this.lastSeen,
    this.isOnline = false,
    this.socialLinks = const {},
    this.preferences = const {},
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastSeen: DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      bio: data['bio'],
      title: data['title'],
      company: data['company'],
      location: data['location'] as GeoPoint?,
      locationName: data['locationName'],
      skills: List<String>.from(data['skills'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      languages: List<String>.from(data['languages'] ?? []),
      frameworks: List<String>.from(data['frameworks'] ?? []),
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      isAvailableForWork: data['isAvailableForWork'] ?? true,
      githubData: Map<String, dynamic>.from(data['githubData'] ?? {}),
      githubUsername: data['githubUsername'],
      portfolioUrls: List<String>.from(data['portfolioUrls'] ?? []),
      workExperience: (data['workExperience'] as List<dynamic>? ?? [])
          .map((e) => WorkExperience.fromMap(e as Map<String, dynamic>))
          .toList(),
      education: (data['education'] as List<dynamic>? ?? [])
          .map((e) => Education.fromMap(e as Map<String, dynamic>))
          .toList(),
      projects: (data['projects'] as List<dynamic>? ?? [])
          .map((e) => Project.fromMap(e as Map<String, dynamic>))
          .toList(),
      certificates: (data['certificates'] as List<dynamic>? ?? [])
          .map((e) => Certificate.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
      isOnline: data['isOnline'] ?? false,
      socialLinks: Map<String, dynamic>.from(data['socialLinks'] ?? {}),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'title': title,
      'company': company,
      'location': location,
      'locationName': locationName,
      'skills': skills,
      'interests': interests,
      'languages': languages,
      'frameworks': frameworks,
      'yearsOfExperience': yearsOfExperience,
      'isAvailableForWork': isAvailableForWork,
      'githubData': githubData,
      'githubUsername': githubUsername,
      'portfolioUrls': portfolioUrls,
      'workExperience': workExperience.map((e) => e.toMap()).toList(),
      'education': education.map((e) => e.toMap()).toList(),
      'projects': projects.map((e) => e.toMap()).toList(),
      'certificates': certificates.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'isOnline': isOnline,
      'socialLinks': socialLinks,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? bio,
    String? title,
    String? company,
    GeoPoint? location,
    String? locationName,
    List<String>? skills,
    List<String>? interests,
    List<String>? languages,
    List<String>? frameworks,
    int? yearsOfExperience,
    bool? isAvailableForWork,
    Map<String, dynamic>? githubData,
    String? githubUsername,
    List<String>? portfolioUrls,
    List<WorkExperience>? workExperience,
    List<Education>? education,
    List<Project>? projects,
    List<Certificate>? certificates,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
    bool? isOnline,
    Map<String, dynamic>? socialLinks,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
      frameworks: frameworks ?? this.frameworks,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      isAvailableForWork: isAvailableForWork ?? this.isAvailableForWork,
      githubData: githubData ?? this.githubData,
      githubUsername: githubUsername ?? this.githubUsername,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      workExperience: workExperience ?? this.workExperience,
      education: education ?? this.education,
      projects: projects ?? this.projects,
      certificates: certificates ?? this.certificates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      socialLinks: socialLinks ?? this.socialLinks,
      preferences: preferences ?? this.preferences,
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

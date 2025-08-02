import 'package:cloud_firestore/cloud_firestore.dart';

class Experience {
  final String title;
  final String company;
  final String duration;

  Experience({
    required this.title,
    required this.company,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'duration': duration,
    };
  }

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      duration: map['duration'] ?? '',
    );
  }
}

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? bio;
  final List<String> skills;
  final List<String> interests;
  final String? githubUsername;
  final int yearsOfExperience;
  final GeoPoint? location;
  final DateTime? lastActive;
  final bool isOnline;
  final Map<String, dynamic>? metadata;
  final bool isRemote;
  final bool isFullTime;
  final bool isPartTime;
  final bool isFreelance;
  final String? title;
  final String? company;
  final String? locationName;
  final List<Map<String, dynamic>> workExperience;
  final Map<String, String> socialLinks;
  final List<String> languages;
  final List<Map<String, dynamic>> projects;
  final List<Map<String, dynamic>> education;

  String get fullName => displayName ?? email.split('@')[0];

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.bio,
    required this.skills,
    required this.interests,
    this.githubUsername,
    required this.yearsOfExperience,
    this.location,
    this.lastActive,
    required this.isOnline,
    this.metadata,
    this.isRemote = false,
    this.isFullTime = false,
    this.isPartTime = false,
    this.isFreelance = false,
    this.title,
    this.company,
    this.locationName,
    this.workExperience = const [],
    this.socialLinks = const {},
    this.languages = const [],
    this.projects = const [],
    this.education = const [],
  });

  Map<String, dynamic>? get locationMap {
    if (location == null) return null;
    return {
      'latitude': location!.latitude,
      'longitude': location!.longitude,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      skills: List<String>.from(json['skills'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      githubUsername: json['githubUsername'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int? ?? 0,
      location: json['location'] as GeoPoint?,
      lastActive: json['lastActive'] != null
          ? (json['lastActive'] as Timestamp).toDate()
          : null,
      isOnline: json['isOnline'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRemote: json['isRemote'] as bool? ?? false,
      isFullTime: json['isFullTime'] as bool? ?? false,
      isPartTime: json['isPartTime'] as bool? ?? false,
      isFreelance: json['isFreelance'] as bool? ?? false,
      title: json['title'] as String?,
      company: json['company'] as String?,
      locationName: json['locationName'] as String?,
      workExperience:
          List<Map<String, dynamic>>.from(json['workExperience'] ?? []),
      socialLinks: Map<String, String>.from(json['socialLinks'] ?? {}),
      languages: List<String>.from(json['languages'] ?? []),
      projects: List<Map<String, dynamic>>.from(json['projects'] ?? []),
      education: List<Map<String, dynamic>>.from(json['education'] ?? []),
    );
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      skills: List<String>.from(data['skills'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      githubUsername: data['githubUsername'],
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      location: data['location'],
      lastActive: data['lastActive'] != null
          ? (data['lastActive'] as Timestamp).toDate()
          : null,
      isOnline: data['isOnline'] ?? false,
      metadata: data['metadata'],
      isRemote: data['isRemote'] ?? false,
      isFullTime: data['isFullTime'] ?? false,
      isPartTime: data['isPartTime'] ?? false,
      isFreelance: data['isFreelance'] ?? false,
      title: data['title'],
      company: data['company'],
      locationName: data['locationName'],
      workExperience:
          List<Map<String, dynamic>>.from(data['workExperience'] ?? []),
      socialLinks: Map<String, String>.from(data['socialLinks'] ?? {}),
      languages: List<String>.from(data['languages'] ?? []),
      projects: List<Map<String, dynamic>>.from(data['projects'] ?? []),
      education: List<Map<String, dynamic>>.from(data['education'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'skills': skills,
      'interests': interests,
      'githubUsername': githubUsername,
      'yearsOfExperience': yearsOfExperience,
      'location': location,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'isOnline': isOnline,
      'metadata': metadata,
      'isRemote': isRemote,
      'isFullTime': isFullTime,
      'isPartTime': isPartTime,
      'isFreelance': isFreelance,
      'title': title,
      'company': company,
      'locationName': locationName,
      'workExperience': workExperience,
      'socialLinks': socialLinks,
      'languages': languages,
      'projects': projects,
      'education': education,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    List<String>? skills,
    List<String>? interests,
    String? githubUsername,
    int? yearsOfExperience,
    GeoPoint? location,
    DateTime? lastActive,
    bool? isOnline,
    Map<String, dynamic>? metadata,
    bool? isRemote,
    bool? isFullTime,
    bool? isPartTime,
    bool? isFreelance,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      githubUsername: githubUsername ?? this.githubUsername,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      location: location ?? this.location,
      lastActive: lastActive ?? this.lastActive,
      isOnline: isOnline ?? this.isOnline,
      metadata: metadata ?? this.metadata,
      isRemote: isRemote ?? this.isRemote,
      isFullTime: isFullTime ?? this.isFullTime,
      isPartTime: isPartTime ?? this.isPartTime,
      isFreelance: isFreelance ?? this.isFreelance,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, displayName: $displayName)';
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

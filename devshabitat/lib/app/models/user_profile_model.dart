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
  final String fullName;
  final String? photoUrl;
  final String? bio;
  final String? title;
  final String? company;
  final GeoPoint? location;
  final String? locationName;
  final List<String> skills;
  final List<String> interests;
  final List<String> languages;
  final int yearsOfExperience;
  final bool isAvailableForWork;
  final bool isRemote;
  final bool isFullTime;
  final bool isPartTime;
  final bool isFreelance;
  final bool isInternship;
  final DateTime? lastActive;
  final bool isOnline;
  final Map<String, dynamic> socialLinks;
  final List<String> portfolioUrls;
  final List<WorkExperience> workExperience;
  final List<Education> education;
  final List<Project> projects;
  final List<Certificate> certificates;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.photoUrl,
    this.bio,
    this.title,
    this.company,
    this.location,
    this.locationName,
    this.skills = const [],
    this.interests = const [],
    this.languages = const [],
    this.yearsOfExperience = 0,
    this.isAvailableForWork = true,
    this.isRemote = false,
    this.isFullTime = false,
    this.isPartTime = false,
    this.isFreelance = false,
    this.isInternship = false,
    this.lastActive,
    this.isOnline = false,
    this.socialLinks = const {},
    this.portfolioUrls = const [],
    this.workExperience = const [],
    this.education = const [],
    this.projects = const [],
    this.certificates = const [],
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      title: data['title'],
      company: data['company'],
      location: data['location'] as GeoPoint?,
      locationName: data['locationName'],
      skills: List<String>.from(data['skills'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      languages: List<String>.from(data['languages'] ?? []),
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      isAvailableForWork: data['isAvailableForWork'] ?? true,
      isRemote: data['isRemote'] ?? false,
      isFullTime: data['isFullTime'] ?? false,
      isPartTime: data['isPartTime'] ?? false,
      isFreelance: data['isFreelance'] ?? false,
      isInternship: data['isInternship'] ?? false,
      lastActive: data['lastActive'] != null
          ? (data['lastActive'] as Timestamp).toDate()
          : null,
      isOnline: data['isOnline'] ?? false,
      socialLinks: Map<String, dynamic>.from(data['socialLinks'] ?? {}),
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'bio': bio,
      'title': title,
      'company': company,
      'location': location,
      'locationName': locationName,
      'skills': skills,
      'interests': interests,
      'languages': languages,
      'yearsOfExperience': yearsOfExperience,
      'isAvailableForWork': isAvailableForWork,
      'isRemote': isRemote,
      'isFullTime': isFullTime,
      'isPartTime': isPartTime,
      'isFreelance': isFreelance,
      'isInternship': isInternship,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'isOnline': isOnline,
      'socialLinks': socialLinks,
      'portfolioUrls': portfolioUrls,
      'workExperience': workExperience.map((e) => e.toMap()).toList(),
      'education': education.map((e) => e.toMap()).toList(),
      'projects': projects.map((e) => e.toMap()).toList(),
      'certificates': certificates.map((e) => e.toMap()).toList(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? photoUrl,
    String? bio,
    String? title,
    String? company,
    GeoPoint? location,
    String? locationName,
    List<String>? skills,
    List<String>? interests,
    List<String>? languages,
    int? yearsOfExperience,
    bool? isAvailableForWork,
    bool? isRemote,
    bool? isFullTime,
    bool? isPartTime,
    bool? isFreelance,
    bool? isInternship,
    DateTime? lastActive,
    bool? isOnline,
    Map<String, dynamic>? socialLinks,
    List<String>? portfolioUrls,
    List<WorkExperience>? workExperience,
    List<Education>? education,
    List<Project>? projects,
    List<Certificate>? certificates,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      isAvailableForWork: isAvailableForWork ?? this.isAvailableForWork,
      isRemote: isRemote ?? this.isRemote,
      isFullTime: isFullTime ?? this.isFullTime,
      isPartTime: isPartTime ?? this.isPartTime,
      isFreelance: isFreelance ?? this.isFreelance,
      isInternship: isInternship ?? this.isInternship,
      lastActive: lastActive ?? this.lastActive,
      isOnline: isOnline ?? this.isOnline,
      socialLinks: socialLinks ?? this.socialLinks,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      workExperience: workExperience ?? this.workExperience,
      education: education ?? this.education,
      projects: projects ?? this.projects,
      certificates: certificates ?? this.certificates,
    );
  }

  double calculateCompatibility(UserProfile other) {
    // Basit bir uyumluluk hesaplama algoritması
    double skillMatch = _calculateSkillMatch(other.skills);
    double experienceMatch = _calculateExperienceMatch(other.yearsOfExperience);
    double interestMatch = _calculateInterestMatch(other.interests);

    return (skillMatch * 0.5) + (experienceMatch * 0.3) + (interestMatch * 0.2);
  }

  double _calculateSkillMatch(List<String> otherSkills) {
    if (skills.isEmpty || otherSkills.isEmpty) return 0.0;
    var intersection = skills.toSet().intersection(otherSkills.toSet());
    var union = skills.toSet().union(otherSkills.toSet());
    return intersection.length / union.length;
  }

  double _calculateExperienceMatch(int otherExperience) {
    final maxExperience = 40; // Maksimum deneyim yılı
    return 1.0 - ((yearsOfExperience - otherExperience).abs() / maxExperience);
  }

  double _calculateInterestMatch(List<String> otherInterests) {
    if (interests.isEmpty || otherInterests.isEmpty) return 0.0;
    var intersection = interests.toSet().intersection(otherInterests.toSet());
    var union = interests.toSet().union(otherInterests.toSet());
    return intersection.length / union.length;
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

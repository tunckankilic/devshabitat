import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, GeoPoint, Timestamp;

class UserProfile {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'title': title,
      'projects': projects,
      'education': education,
      'workExperience': workExperience,
      'company': company,
      'bio': bio,
      'photoUrl': photoUrl,
      'locationName': locationName,
      'githubUsername': githubUsername,
      'skills': skills,
      'interests': interests,
      'languages': languages,
      'workExperiences': workExperiences,
      'socialLinks': socialLinks,
      'lastActive': lastActive?.toIso8601String(),
      'isOnline': isOnline,
      'isRemote': isRemote,
      'isFullTime': isFullTime,
      'isPartTime': isPartTime,
      'isFreelance': isFreelance,
      'yearsOfExperience': yearsOfExperience,
      'location': location != null
          ? {'latitude': location!.latitude, 'longitude': location!.longitude}
          : null,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      title: json['title'] as String?,
      projects: List<Map<String, dynamic>>.from(json['projects'] ?? []),
      education: List<Map<String, dynamic>>.from(json['education'] ?? []),
      workExperience: List<Map<String, dynamic>>.from(
        json['workExperience'] ?? [],
      ),
      company: json['company'] as String?,
      bio: json['bio'] as String?,
      photoUrl: json['photoUrl'] as String?,
      locationName: json['locationName'] as String?,
      githubUsername: json['githubUsername'] as String?,
      skills: List<String>.from(json['skills'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      workExperiences: List<Map<String, dynamic>>.from(
        json['workExperiences'] ?? [],
      ),
      socialLinks: Map<String, String>.from(json['socialLinks'] ?? {}),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      isOnline: json['isOnline'] as bool? ?? false,
      isRemote: json['isRemote'] as bool? ?? false,
      isFullTime: json['isFullTime'] as bool? ?? false,
      isPartTime: json['isPartTime'] as bool? ?? false,
      isFreelance: json['isFreelance'] as bool? ?? false,
      yearsOfExperience: json['yearsOfExperience'] as int? ?? 0,
      location: json['location'] != null
          ? GeoPoint(
              json['location']['latitude'],
              json['location']['longitude'],
            )
          : null,
    );
  }
  final String id;
  final String email;
  final String fullName;
  final String? title;
  final List<Map<String, dynamic>> projects;
  final List<Map<String, dynamic>> education;
  final List<Map<String, dynamic>> workExperience;
  final String? company;
  final String? bio;
  final String? photoUrl;
  final String? locationName;
  final String? githubUsername;
  final List<String> skills;
  final List<String> interests;
  final List<String> languages;
  final List<Map<String, dynamic>> workExperiences;
  final Map<String, String> socialLinks;
  final DateTime? lastActive;
  final bool isOnline;
  final bool isRemote;
  final bool isFullTime;
  final bool isPartTime;
  final bool isFreelance;
  final int yearsOfExperience;
  final GeoPoint? location;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.title,
    this.projects = const [],
    this.education = const [],
    this.workExperience = const [],
    this.company,
    this.bio,
    this.photoUrl,
    this.locationName,
    this.githubUsername,
    required this.skills,
    this.interests = const [],
    this.languages = const [],
    this.workExperiences = const [],
    this.socialLinks = const {},
    this.lastActive,
    this.isOnline = false,
    required this.isRemote,
    required this.isFullTime,
    required this.isPartTime,
    required this.isFreelance,
    required this.yearsOfExperience,
    this.location,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    doc.data() as Map<String, dynamic>;
    return UserProfile.fromDocument(doc);
  }

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      title: data['title'],
      projects: List<Map<String, dynamic>>.from(data['projects'] ?? []),
      education: List<Map<String, dynamic>>.from(data['education'] ?? []),
      workExperience: List<Map<String, dynamic>>.from(
        data['workExperience'] ?? [],
      ),
      company: data['company'],
      bio: data['bio'],
      photoUrl: data['photoURL'],
      locationName: data['locationName'],
      githubUsername: data['githubUsername'],
      skills: List<String>.from(data['skills'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      languages: List<String>.from(data['languages'] ?? []),
      workExperiences: List<Map<String, dynamic>>.from(
        data['workExperiences'] ?? [],
      ),
      socialLinks: Map<String, String>.from(data['socialLinks'] ?? {}),
      lastActive: data['lastActive'] != null
          ? (data['lastActive'] as Timestamp).toDate()
          : null,
      isOnline: data['isOnline'] ?? false,
      isRemote: data['isRemote'] ?? false,
      isFullTime: data['isFullTime'] ?? false,
      isPartTime: data['isPartTime'] ?? false,
      isFreelance: data['isFreelance'] ?? false,
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
    );
  }
}

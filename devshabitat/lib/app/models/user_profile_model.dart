import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, GeoPoint, Timestamp;

class UserProfile {
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
    final data = doc.data() as Map<String, dynamic>;
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
      photoUrl: data['photoUrl'],
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

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final String? profileImage;
  final String? bio;
  final List<String> skills;
  final List<String> interests;
  final String? location;
  final String? company;
  final String? position;
  bool isOnline;
  final DateTime lastSeen;
  final Map<String, dynamic> additionalInfo;

  UserProfile({
    required this.id,
    required this.name,
    this.profileImage,
    this.bio,
    this.skills = const [],
    this.interests = const [],
    this.location,
    this.company,
    this.position,
    this.isOnline = false,
    required this.lastSeen,
    this.additionalInfo = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImage: json['profileImage'] as String?,
      bio: json['bio'] as String?,
      skills: List<String>.from(json['skills'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      location: json['location'] as String?,
      company: json['company'] as String?,
      position: json['position'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'bio': bio,
      'skills': skills,
      'interests': interests,
      'location': location,
      'company': company,
      'position': position,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'additionalInfo': additionalInfo,
    };
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      profileImage: data['profileImage'],
      bio: data['bio'],
      skills: List<String>.from(data['skills'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      location: data['location'] as String?,
      company: data['company'] as String?,
      position: data['position'] as String?,
      isOnline: data['isOnline'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp).toDate(),
      additionalInfo: data['additionalInfo'] as Map<String, dynamic>? ?? {},
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      profileImage: map['profileImage'],
      bio: map['bio'],
      skills: List<String>.from(map['skills'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      location: map['location'] as String?,
      company: map['company'] as String?,
      position: map['position'] as String?,
      isOnline: map['isOnline'] ?? false,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(map['lastSeen']),
      additionalInfo: map['additionalInfo'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'bio': bio,
      'skills': skills,
      'interests': interests,
      'location': location,
      'company': company,
      'position': position,
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'additionalInfo': additionalInfo,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? profileImage,
    String? bio,
    List<String>? skills,
    List<String>? interests,
    String? location,
    String? company,
    String? position,
    bool? isOnline,
    DateTime? lastSeen,
    Map<String, dynamic>? additionalInfo,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      location: location ?? this.location,
      company: company ?? this.company,
      position: position ?? this.position,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}

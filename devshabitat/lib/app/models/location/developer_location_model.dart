import 'package:cloud_firestore/cloud_firestore.dart';

class DeveloperLocationModel {
  final String id;
  final String name;
  final List<String> skills;
  final GeoPoint location;

  DeveloperLocationModel({
    required this.id,
    required this.name,
    required this.skills,
    required this.location,
  });

  factory DeveloperLocationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeveloperLocationModel(
      id: doc.id,
      name: data['name'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      location: data['location'] as GeoPoint,
    );
  }
}

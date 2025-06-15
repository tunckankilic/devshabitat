import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchFilter {
  final String name;
  final List<String> skills;
  final List<String> interests;
  final String? location;
  final double? radius;
  final RangeValues? experienceRange;
  final String? company;
  final bool onlineOnly;

  SearchFilter({
    required this.name,
    this.skills = const [],
    this.interests = const [],
    this.location,
    this.radius,
    this.experienceRange,
    this.company,
    this.onlineOnly = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'skills': skills,
      'interests': interests,
      'location': location,
      'radius': radius,
      'experienceRange': experienceRange != null
          ? {
              'start': experienceRange!.start,
              'end': experienceRange!.end,
            }
          : null,
      'company': company,
      'onlineOnly': onlineOnly,
    };
  }

  factory SearchFilter.fromMap(Map<String, dynamic> map) {
    return SearchFilter(
      name: map['name'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      location: map['location'],
      radius: map['radius']?.toDouble(),
      experienceRange: map['experienceRange'] != null
          ? RangeValues(
              map['experienceRange']['start']?.toDouble() ?? 0.0,
              map['experienceRange']['end']?.toDouble() ?? 20.0,
            )
          : null,
      company: map['company'],
      onlineOnly: map['onlineOnly'] ?? false,
    );
  }

  SearchFilter copyWith({
    String? name,
    List<String>? skills,
    List<String>? interests,
    String? location,
    double? radius,
    RangeValues? experienceRange,
    String? company,
    bool? onlineOnly,
  }) {
    return SearchFilter(
      name: name ?? this.name,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      location: location ?? this.location,
      radius: radius ?? this.radius,
      experienceRange: experienceRange ?? this.experienceRange,
      company: company ?? this.company,
      onlineOnly: onlineOnly ?? this.onlineOnly,
    );
  }
}

class SearchFilterModel {
  final String name;
  final List<String> skills;
  final List<String> interests;
  final GeoPoint? location;
  final double? maxDistance;
  final int? minExperience;
  final int? maxExperience;
  final List<String> languages;
  final String? company;
  final bool isRemote;
  final bool isFullTime;
  final bool isPartTime;
  final bool isFreelance;
  final bool isInternship;

  SearchFilterModel({
    this.name = 'Default',
    this.skills = const [],
    this.interests = const [],
    this.location,
    this.maxDistance = 50.0,
    this.minExperience,
    this.maxExperience,
    this.languages = const [],
    this.company,
    this.isRemote = false,
    this.isFullTime = false,
    this.isPartTime = false,
    this.isFreelance = false,
    this.isInternship = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'skills': skills,
      'interests': interests,
      'location': location,
      'maxDistance': maxDistance,
      'minExperience': minExperience,
      'maxExperience': maxExperience,
      'languages': languages,
      'company': company,
      'isRemote': isRemote,
      'isFullTime': isFullTime,
      'isPartTime': isPartTime,
      'isFreelance': isFreelance,
      'isInternship': isInternship,
    };
  }

  factory SearchFilterModel.fromMap(Map<String, dynamic> map) {
    return SearchFilterModel(
      name: map['name'] ?? 'Default',
      skills: List<String>.from(map['skills'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      location: map['location'] as GeoPoint?,
      maxDistance: map['maxDistance']?.toDouble() ?? 50.0,
      minExperience: map['minExperience'] as int?,
      maxExperience: map['maxExperience'] as int?,
      languages: List<String>.from(map['languages'] ?? []),
      company: map['company'] as String?,
      isRemote: map['isRemote'] ?? false,
      isFullTime: map['isFullTime'] ?? false,
      isPartTime: map['isPartTime'] ?? false,
      isFreelance: map['isFreelance'] ?? false,
      isInternship: map['isInternship'] ?? false,
    );
  }

  SearchFilterModel copyWith({
    String? name,
    List<String>? skills,
    List<String>? interests,
    GeoPoint? location,
    double? maxDistance,
    int? minExperience,
    int? maxExperience,
    List<String>? languages,
    String? company,
    bool? isRemote,
    bool? isFullTime,
    bool? isPartTime,
    bool? isFreelance,
    bool? isInternship,
  }) {
    return SearchFilterModel(
      name: name ?? this.name,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      location: location ?? this.location,
      maxDistance: maxDistance ?? this.maxDistance,
      minExperience: minExperience ?? this.minExperience,
      maxExperience: maxExperience ?? this.maxExperience,
      languages: languages ?? this.languages,
      company: company ?? this.company,
      isRemote: isRemote ?? this.isRemote,
      isFullTime: isFullTime ?? this.isFullTime,
      isPartTime: isPartTime ?? this.isPartTime,
      isFreelance: isFreelance ?? this.isFreelance,
      isInternship: isInternship ?? this.isInternship,
    );
  }
}

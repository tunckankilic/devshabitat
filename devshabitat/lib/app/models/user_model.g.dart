// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      technologies: (json['technologies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      privacySettings: json['privacySettings'] == null
          ? null
          : PrivacySettings.fromJson(
              json['privacySettings'] as Map<String, dynamic>),
      phoneNumber: json['phoneNumber'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'bio': instance.bio,
      'technologies': instance.technologies,
      'privacySettings': instance.privacySettings,
      'phoneNumber': instance.phoneNumber,
      'emailVerified': instance.emailVerified,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

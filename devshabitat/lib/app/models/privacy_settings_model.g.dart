// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    PrivacySettings(
      isProfilePublic: json['isProfilePublic'] as bool? ?? true,
      showLocation: json['showLocation'] as bool? ?? true,
      allowConnectionRequests: json['allowConnectionRequests'] as bool? ?? true,
      showTechnologies: json['showTechnologies'] as bool? ?? true,
      showBio: json['showBio'] as bool? ?? true,
      allowMentorshipRequests: json['allowMentorshipRequests'] as bool? ?? true,
      blockedUsers: (json['blockedUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      customVisibility:
          (json['customVisibility'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as bool),
              ) ??
              const {},
    );

Map<String, dynamic> _$PrivacySettingsToJson(PrivacySettings instance) =>
    <String, dynamic>{
      'isProfilePublic': instance.isProfilePublic,
      'showLocation': instance.showLocation,
      'allowConnectionRequests': instance.allowConnectionRequests,
      'showTechnologies': instance.showTechnologies,
      'showBio': instance.showBio,
      'allowMentorshipRequests': instance.allowMentorshipRequests,
      'blockedUsers': instance.blockedUsers,
      'customVisibility': instance.customVisibility,
    };

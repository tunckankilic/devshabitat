import 'package:json_annotation/json_annotation.dart';

part 'privacy_settings_model.g.dart';

@JsonSerializable()
class PrivacySettings {
  final bool isProfilePublic;
  final bool showLocation;
  final bool allowConnectionRequests;
  final bool showTechnologies;
  final bool showBio;
  final bool allowMentorshipRequests;
  final List<String> blockedUsers;
  final Map<String, bool> customVisibility;

  PrivacySettings({
    this.isProfilePublic = true,
    this.showLocation = true,
    this.allowConnectionRequests = true,
    this.showTechnologies = true,
    this.showBio = true,
    this.allowMentorshipRequests = true,
    this.blockedUsers = const [],
    this.customVisibility = const {},
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacySettingsToJson(this);

  PrivacySettings copyWith({
    bool? isProfilePublic,
    bool? showLocation,
    bool? allowConnectionRequests,
    bool? showTechnologies,
    bool? showBio,
    bool? allowMentorshipRequests,
    List<String>? blockedUsers,
    Map<String, bool>? customVisibility,
  }) {
    return PrivacySettings(
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      showLocation: showLocation ?? this.showLocation,
      allowConnectionRequests:
          allowConnectionRequests ?? this.allowConnectionRequests,
      showTechnologies: showTechnologies ?? this.showTechnologies,
      showBio: showBio ?? this.showBio,
      allowMentorshipRequests:
          allowMentorshipRequests ?? this.allowMentorshipRequests,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      customVisibility: customVisibility ?? this.customVisibility,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoPointConverter _$GeoPointConverterFromJson(Map<String, dynamic> json) =>
    GeoPointConverter();

Map<String, dynamic> _$GeoPointConverterToJson(GeoPointConverter instance) =>
    <String, dynamic>{};

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      organizerId: json['organizerId'] as String,
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      location: $enumDecode(_$EventLocationEnumMap, json['location']),
      geoPoint: const GeoPointConverter()
          .fromJson(json['geoPoint'] as Map<String, dynamic>?),
      coverImageUrl: json['coverImageUrl'] as String?,
      venueAddress: json['venueAddress'] as String?,
      onlineMeetingUrl: json['onlineMeetingUrl'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participantLimit: (json['participantLimit'] as num).toInt(),
      currentParticipants: (json['currentParticipants'] as num?)?.toInt() ?? 0,
      categoryIds: (json['categoryIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'organizerId': instance.organizerId,
      'type': _$EventTypeEnumMap[instance.type]!,
      'location': _$EventLocationEnumMap[instance.location]!,
      'geoPoint': const GeoPointConverter().toJson(instance.geoPoint),
      'coverImageUrl': instance.coverImageUrl,
      'venueAddress': instance.venueAddress,
      'onlineMeetingUrl': instance.onlineMeetingUrl,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'participantLimit': instance.participantLimit,
      'currentParticipants': instance.currentParticipants,
      'categoryIds': instance.categoryIds,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$EventTypeEnumMap = {
  EventType.workshop: 'workshop',
  EventType.meetup: 'meetup',
  EventType.conference: 'conference',
  EventType.hackathon: 'hackathon',
  EventType.other: 'other',
};

const _$EventLocationEnumMap = {
  EventLocation.online: 'online',
  EventLocation.offline: 'offline',
};

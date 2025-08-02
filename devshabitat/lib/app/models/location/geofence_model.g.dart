// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofence_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeofenceAction _$GeofenceActionFromJson(Map<String, dynamic> json) =>
    GeofenceAction(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GeofenceActionToJson(GeofenceAction instance) =>
    <String, dynamic>{'type': instance.type, 'data': instance.data};

GeofenceModel _$GeofenceModelFromJson(Map<String, dynamic> json) =>
    GeofenceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num?)?.toDouble(),
      onEnterActions: (json['onEnterActions'] as List<dynamic>?)
          ?.map((e) => GeofenceAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      onExitActions: (json['onExitActions'] as List<dynamic>?)
          ?.map((e) => GeofenceAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GeofenceModelToJson(GeofenceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius': instance.radius,
      'onEnterActions': instance.onEnterActions,
      'onExitActions': instance.onExitActions,
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'metadata': instance.metadata,
    };

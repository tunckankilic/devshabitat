// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_marker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapMarkerModel _$MapMarkerModelFromJson(Map<String, dynamic> json) =>
    MapMarkerModel(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      title: json['title'] as String,
      snippet: json['snippet'] as String?,
      isVisible: json['isVisible'] as bool? ?? true,
      isDraggable: json['isDraggable'] as bool? ?? false,
    );

Map<String, dynamic> _$MapMarkerModelToJson(MapMarkerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'title': instance.title,
      'snippet': instance.snippet,
      'isVisible': instance.isVisible,
      'isDraggable': instance.isDraggable,
    };

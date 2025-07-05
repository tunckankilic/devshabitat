// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_marker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomMapMarker _$CustomMapMarkerFromJson(Map<String, dynamic> json) =>
    CustomMapMarker(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      category: $enumDecode(_$MarkerCategoryEnumMap, json['category']),
      iconPath: json['iconPath'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CustomMapMarkerToJson(CustomMapMarker instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'category': _$MarkerCategoryEnumMap[instance.category]!,
      'iconPath': instance.iconPath,
      'metadata': instance.metadata,
    };

const _$MarkerCategoryEnumMap = {
  MarkerCategory.user: 'user',
  MarkerCategory.event: 'event',
  MarkerCategory.community: 'community',
  MarkerCategory.place: 'place',
  MarkerCategory.custom: 'custom',
};

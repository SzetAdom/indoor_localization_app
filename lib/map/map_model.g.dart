// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapModel _$MapModelFromJson(Map<String, dynamic> json) => MapModel(
      id: json['id'] as String,
      name: json['name'] as String,
      objects: (json['objects'] as List<dynamic>)
          .map((e) => MapObjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      extraWidthRigth: (json['extraWidthRigth'] as num?)?.toDouble() ?? 100,
      extraWidthLeft: (json['extraWidthLeft'] as num?)?.toDouble() ?? 100,
      extraHeightTop: (json['extraHeightTop'] as num?)?.toDouble() ?? 100,
      extraHeightBottom: (json['extraHeightBottom'] as num?)?.toDouble() ?? 100,
    )
      ..baseWidth = (json['baseWidth'] as num).toDouble()
      ..baseHeight = (json['baseHeight'] as num).toDouble();

Map<String, dynamic> _$MapModelToJson(MapModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'objects': instance.objects,
      'baseWidth': instance.baseWidth,
      'baseHeight': instance.baseHeight,
      'extraWidthRigth': instance.extraWidthRigth,
      'extraWidthLeft': instance.extraWidthLeft,
      'extraHeightTop': instance.extraHeightTop,
      'extraHeightBottom': instance.extraHeightBottom,
    };

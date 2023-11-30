// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wall_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WallObject _$WallObjectFromJson(Map<String, dynamic> json) => WallObject(
      id: json['id'] as String,
      name: json['name'] as String?,
      description: json['description'] as String,
      icon: json['icon'] as String?,
      pointsRaw: (json['pointsRaw'] as List<dynamic>?)
          ?.map((e) => WallObjectPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      doors: (json['doors'] as List<dynamic>)
          .map((e) => DoorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..type = $enumDecode(_$MapObjectTypeEnumMap, json['type']);

Map<String, dynamic> _$WallObjectToJson(WallObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'type': _$MapObjectTypeEnumMap[instance.type]!,
      'pointsRaw': instance.pointsRaw,
      'doors': instance.doors,
    };

const _$MapObjectTypeEnumMap = {
  MapObjectType.wall: 'wall',
};

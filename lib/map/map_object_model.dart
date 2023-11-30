
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:indoor_localization_app/map/map_object_point_model.dart';
import 'package:indoor_localization_app/map/wall_object.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class MapObjectInterface {
  void draw(Canvas canvas, Size size, {bool selected = false});
}

enum MapObjectType { wall }

@JsonSerializable()
class MapObjectModel implements MapObjectInterface {
  static const double pointRadius = 10;

  String id;
  String? name;
  String? icon;
  String? description;
  MapObjectType type;
  // List<MapObjectPointModel> points;
  List<MapObjectPointModel> pointsRaw = [];


  MapObjectModel({
    required this.id,
    this.type = MapObjectType.wall,
    this.name,
    this.icon,
    this.description,
    required this.pointsRaw,
  });

  factory MapObjectModel.fromJson(Map<String, dynamic> json) {
    var type = json['type'];
    switch (type) {
      case 'wall':
        return WallObject.fromJson(json);
      default:
        return MapObjectModel(
          id: json['id'],
          name: json['name'],
          icon: json['icon'],
          description: json['description'],
          pointsRaw: (json['pointsRaw'] as List<dynamic>)
              .map((e) =>
              MapObjectPointModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
    }
  }

  Map<String, dynamic> toJson() {
    var res = <String, dynamic>{
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'type': type.toString().split('.').last,
      'pointsRaw': pointsRaw,
    };
    return res;
  }


  @override
  void draw(Canvas canvas, Size size, {bool selected = false}) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = pointRadius
      ..strokeCap = StrokeCap.round;

    //draw only the points
    canvas.drawPoints(
        PointMode.points, pointsRaw.map((e) => e.point).toList(), paint);
  }
}

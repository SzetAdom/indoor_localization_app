import 'package:flutter/material.dart';
import 'package:indoor_localization_app/map/map_object_point_model.dart';

class TestPointModel extends MapObjectPointModel {
  TestPointModel({
    required Offset point,
    required this.id,
    required this.name,
  }) : super(
          point: point,
        );

  String id;
  String name;

  factory TestPointModel.fromJson(Map<String, dynamic> json) => TestPointModel(
        point: Offset(double.parse(json['x'].toString()),
            double.parse(json['y'].toString())),
        id: json['id'],
        name: json['name'],
      );

  @override
  Map<String, dynamic> toJson() => {
        'x': point.dx.toString(),
        'y': point.dy.toString(),
        'id': id,
        'name': name,
      };
}

import 'package:flutter/material.dart';
import 'package:indoor_localization_app/map/map_point_model.dart';

class MapBeaconModel extends MapPointModel {
  String uuid;
  int? major;
  int? minor;

  MapBeaconModel({
    required Offset point,
    required this.uuid,
    this.major,
    this.minor,
    Color color = Colors.green,
  }) : super(
          id: uuid,
          x: point.dx,
          y: point.dy,
          color: color,
        );

  factory MapBeaconModel.fromJson(Map<String, dynamic> json) => MapBeaconModel(
        point: Offset(double.parse(json['x'].toString()),
            double.parse(json['y'].toString())),
        uuid: json['uuid'],
        major: json['major'],
        minor: json['minor'],
      );

  @override
  Map<String, dynamic> toJson() => {
        'x': super.x.toString(),
        'y': super.y.toString(),
        'uuid': uuid,
        'major': major,
        'minor': minor,
      };
}

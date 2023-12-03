import 'package:flutter/material.dart';
import 'package:indoor_localization_app/map/map_object_point_model.dart';

class MapBeaconModel extends MapObjectPointModel {
  String uuid;
  int? major;
  int? minor;

  MapBeaconModel({
    required Offset point,
    required this.uuid,
    this.major,
    this.minor,
  }) : super(
          point: point,
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
        'x': point.dx.toString(),
        'y': point.dy.toString(),
        'uuid': uuid,
        'major': major,
        'minor': minor,
      };
}

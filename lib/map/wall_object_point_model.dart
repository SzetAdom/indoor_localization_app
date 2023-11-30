import 'dart:ui';

import 'package:indoor_localization_app/map/map_object_point_model.dart';

class WallObjectPointModel extends MapObjectPointModel {
  WallObjectPointModel({
    required Offset point,
  }) : super(
          point: point,
        );

  factory WallObjectPointModel.fromJson(Map<String, dynamic> json) =>
      WallObjectPointModel(
        point: Offset(double.parse(json['x'].toString()),
            double.parse(json['y'].toString())),
      );

  @override
  Map<String, dynamic> toJson() => {
        'x': point.dx,
        'y': point.dy,
      };
}

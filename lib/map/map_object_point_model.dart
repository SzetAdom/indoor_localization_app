import 'dart:ui';

class MapObjectPointModel {
  Offset point;

  MapObjectPointModel({
    required this.point,
  });

  factory MapObjectPointModel.fromJson(Map<String, dynamic> json) =>
      MapObjectPointModel(
        point: Offset(json['x'], json['y']),
      );

  Map<String, dynamic> toJson() => {
        'x': point.dx,
        'y': point.dy,
      };
}

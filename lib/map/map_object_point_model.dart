import 'dart:ui';

class MapObjectPointModel {
  Offset point;

  MapObjectPointModel({
    required this.point,
  });

  factory MapObjectPointModel.fromJson(Map<String, dynamic> json) =>
      MapObjectPointModel(
        point: Offset(double.parse(json['x'].toString()),
            double.parse(json['y'].toString())),
      );

  Map<String, dynamic> toJson() => {
        'x': point.dx.toDouble(),
        'y': point.dy.toDouble(),
      };
}

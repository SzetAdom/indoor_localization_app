import 'package:flutter/material.dart';
import 'package:indoor_localization_app/helper/map_helper.dart';

class DoorModel {
  int firstPointIndex;
  int secondPointIndex;

  double distanceToFirstPoint;
  double distanceToSecondPoint;

  List<int> get pointsIndexes => [firstPointIndex, secondPointIndex];

  DoorModel({
    required this.firstPointIndex,
    required this.secondPointIndex,
    required this.distanceToFirstPoint,
    required this.distanceToSecondPoint,
  });

  factory DoorModel.fromJson(Map<String, dynamic> json) => DoorModel(
        firstPointIndex: json['firstPointIndex'],
        secondPointIndex: json['secontPointIndex'],
        distanceToFirstPoint:
            double.parse(json['distanceToFirstPoint'].toString()),
        distanceToSecondPoint:
            double.parse(json['distanceToSecondPoint'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'firstPointIndex': firstPointIndex,
        'secontPointIndex': secondPointIndex,
        'distanceToFirstPoint': distanceToFirstPoint.toString(),
        'distanceToSecondPoint': distanceToSecondPoint.toString(),
      };

  Offset getFirstPointOffset(Offset firstPoint, Offset secondPoint) {
    final firstPointDirection = MapHelper.direction(
      firstPoint,
      secondPoint,
    );

    final firstPointOffset = MapHelper.offsetFromDirection(
      firstPointDirection,
      distanceToFirstPoint,
    );

    return firstPoint + firstPointOffset;
  }

  Offset getSecondPointOffset(Offset firstPoint, Offset secondPoint) {
    final secondPointDirection = MapHelper.direction(
      secondPoint,
      firstPoint,
    );

    final secondPointOffset = MapHelper.offsetFromDirection(
      secondPointDirection,
      distanceToSecondPoint,
    );

    return secondPoint + secondPointOffset;
  }
}

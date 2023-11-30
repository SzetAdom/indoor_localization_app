import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:indoor_localization_app/map/door_model.dart';
import 'package:indoor_localization_app/map/map_object_model.dart';
import 'package:indoor_localization_app/map/wall_object_point_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wall_object.g.dart';

@JsonSerializable()
class WallObject extends MapObjectModel {
  WallObject({
    required String id,
    String? name,
    required String description,
    String? icon,
    List<WallObjectPointModel>? pointsRaw,
    required this.doors,
  }) : super(
          id: id,
          name: name,
          icon: icon,
          description: description,
          pointsRaw: pointsRaw ?? [],
        );

  List<DoorModel> doors = [];

  factory WallObject.fromJson(Map<String, dynamic> json) =>
      _$WallObjectFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WallObjectToJson(this);

  @override
  void draw(Canvas canvas, Size size, {bool selected = false}) {
    fillBackground(canvas, size);
    drawWallsWithoutDoors(canvas, size);
    // drawWallsWithDoors(canvas, size);

    if (selected) {
      drawEditPoints(canvas, size);

      drawDoorEditPoints(canvas, size);
    }

    // //draw center
    // final center = getCenter();

    // final centerPaint = Paint()
    //   ..color = Colors.red
    //   ..strokeWidth = 10
    //   ..strokeCap = StrokeCap.round;

    // canvas.drawPoints(PointMode.points, [center], centerPaint);
  }

  void fillBackground(Canvas canvas, Size size) {
    final path = Path();

    path.moveTo(pointsRaw.first.point.dx, pointsRaw.first.point.dy);

    for (var i = 1; i < pointsRaw.length; i++) {
      path.lineTo(pointsRaw[i].point.dx, pointsRaw[i].point.dy);
    }

    path.close();

    final fillPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    canvas.drawPath(fullPath, fillPaint);
  }

  void drawEditPoints(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(
        PointMode.points, pointsRaw.map((e) => e.point).toList(), paint);

    //write the point index

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (var i = 0; i < pointsRaw.length; i++) {
      textPainter.text = TextSpan(
        text: '$i',
        style: textStyle,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(pointsRaw[i].point.dx + 10,
            pointsRaw[i].point.dy - textPainter.height),
      );
    }
  }

  void drawDoorEditPoints(Canvas canvas, Size size) {
    var doorPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.square;

    for (var door in doors) {
      final firstPoint = pointsRaw[door.firstPointIndex];
      final secondPoint = pointsRaw[door.secontPointIndex];

      final firstPointDoor =
          door.getFirstPointOffset(firstPoint.point, secondPoint.point);
      final secondPointDoor =
          door.getSecondPointOffset(firstPoint.point, secondPoint.point);

      canvas.drawPoints(PointMode.points, [firstPointDoor], doorPaint);

      canvas.drawPoints(PointMode.points, [secondPointDoor], doorPaint);
    }
  }

  Path get fullPath {
    final path = Path();

    path.moveTo(pointsRaw.first.point.dx, pointsRaw.first.point.dy);

    for (var i = 0; i < pointsRaw.length; i++) {
      path.lineTo(pointsRaw[i].point.dx, pointsRaw[i].point.dy);
    }

    path.close();

    return path;
  }

  void drawWallsWithoutDoors(Canvas canvas, Size size) {
    final path = Path();

    path.moveTo(pointsRaw.first.point.dx, pointsRaw.first.point.dy);

    for (var i = 0; i < pointsRaw.length; i++) {
      //next point
      final nextPoint = pointsRaw[(i + 1) % pointsRaw.length];
      if (!doors.any((element) => element.firstPointIndex == i)) {
        //line to next point
        path.lineTo(nextPoint.point.dx, nextPoint.point.dy);
      } else {
        //iterate through doors on this wall
        for (var door
            in doors.where((element) => element.firstPointIndex == i)) {
          final firstPoint = pointsRaw[door.firstPointIndex];
          final secondPoint = pointsRaw[door.secontPointIndex];

          final firstPointDoor =
              door.getFirstPointOffset(firstPoint.point, secondPoint.point);

          path.lineTo(firstPointDoor.dx, firstPointDoor.dy);

          final secondPointDoor =
              door.getSecondPointOffset(firstPoint.point, secondPoint.point);

          path.moveTo(secondPointDoor.dx, secondPointDoor.dy);

          path.lineTo(nextPoint.point.dx, nextPoint.point.dy);
        }
      }
    }

    final drawPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, drawPaint);
  }

  Path get doorPaths {
    final path = Path();

    for (var door in doors) {
      final doorPath = Path();

      final firstPoint = pointsRaw[door.firstPointIndex];
      final secondPoint = pointsRaw[door.secontPointIndex];

      final firstPointDoor =
          door.getFirstPointOffset(firstPoint.point, secondPoint.point);
      final secondPointDoor =
          door.getSecondPointOffset(firstPoint.point, secondPoint.point);

      doorPath.moveTo(firstPointDoor.dx, firstPointDoor.dy);
      doorPath.lineTo(secondPointDoor.dx, secondPointDoor.dy);

      doorPath.close();

      path.addPath(doorPath, Offset.zero);
    }

    return path;
  }
}

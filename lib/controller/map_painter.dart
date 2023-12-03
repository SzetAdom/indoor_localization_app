import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:indoor_localization_app/map/map_model.dart';

class MapEditorPainter extends CustomPainter {
  double pointSize;
  double mapEditPointSize;
  Offset canvasOffset;
  double gridStep;
  MapModel map;
  double zoomLevel;
  Offset? calculatedOffset;

  MapEditorPainter({
    required this.map,
    required this.canvasOffset,
    required this.gridStep,
    required this.zoomLevel,
    required this.pointSize,
    required this.mapEditPointSize,
    this.calculatedOffset,
  });

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is MapEditorPainter) {
      return oldDelegate.map != map ||
          oldDelegate.canvasOffset != canvasOffset ||
          oldDelegate.gridStep != gridStep ||
          oldDelegate.zoomLevel != zoomLevel ||
          oldDelegate.pointSize != pointSize;
    }
    return false;
  }

  void _drawPoint(Canvas canvas, Offset point, bool selected) {
    final paint = Paint()
      ..color = selected ? Colors.red : Colors.blue
      ..strokeWidth = pointSize
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(PointMode.points, [point], paint);

    //if point is selected draw point coordinates
    if (selected) {
      const textStyle = TextStyle(
        color: Colors.black,
        fontSize: 20,
      );

      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.text = TextSpan(
        text: 'x: ${point.dx}',
        style: textStyle,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(point.dx + 10, point.dy - textPainter.height),
      );

      textPainter.text = TextSpan(
        text: 'y: ${point.dy}',
        style: textStyle,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(point.dx + 10, point.dy - textPainter.height * 2),
      );
    }
  }

  void drawBaseBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void drawMap(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(
        Rect.fromLTRB(map.widthLeft * -1, map.heightTop * -1, map.widthRight,
            map.heightBottom),
        paint);

    drawGrid(canvas, size);

    drawAxis(canvas, size);
    // drawMapSize(canvas, size);
  }

  void drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    // vertical lines
    for (var i = 0.0; i > map.widthLeft * -1; i -= gridStep) {
      canvas.drawLine(Offset(i.toDouble(), map.heightTop * -1),
          Offset(i.toDouble(), map.heightBottom), gridPaint);
    }

    for (var i = 0.0; i < map.widthRight; i += gridStep) {
      canvas.drawLine(Offset(i.toDouble(), map.heightTop * -1),
          Offset(i.toDouble(), map.heightBottom), gridPaint);
    }

    // horizontal lines
    for (var i = 0.0; i < map.heightBottom; i += gridStep) {
      canvas.drawLine(Offset(map.widthLeft * -1, i.toDouble()),
          Offset(map.widthRight, i.toDouble()), gridPaint);
    }
    for (var i = 0.0; i > map.heightTop * -1; i -= gridStep) {
      canvas.drawLine(Offset(map.widthLeft * -1, i.toDouble()),
          Offset(map.widthRight, i.toDouble()), gridPaint);
    }
  }

  void drawAxis(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        Offset(map.widthLeft * -1, 0), Offset(map.widthRight, 0), axisPaint);
    canvas.drawLine(
        Offset(0, map.heightTop * -1), Offset(0, map.heightBottom), axisPaint);

    //draw axis arrows
    canvas.drawLine(Offset(map.widthRight, 0), Offset(map.widthRight - 10, 10),
        axisPaint..strokeWidth = 3);

    canvas.drawLine(Offset(map.widthRight, 0), Offset(map.widthRight - 10, -10),
        axisPaint..strokeWidth = 3);

    canvas.drawLine(Offset(0, map.heightBottom),
        Offset(10, map.heightBottom - 10), axisPaint..strokeWidth = 3);

    canvas.drawLine(Offset(0, map.heightBottom),
        Offset(-10, map.heightBottom - 10), axisPaint..strokeWidth = 3);

    //draw axis labels
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.text = const TextSpan(
      text: 'x',
      style: textStyle,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(map.widthRight - textPainter.width - 20, 0),
    );

    textPainter.text = const TextSpan(
      text: 'y',
      style: textStyle,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(5, map.heightBottom - textPainter.height - 20),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(zoomLevel);
    drawBaseBackground(canvas, size);

    canvas.translate(canvasOffset.dx, canvasOffset.dy);

    var horizontalCenterOffset = (size.width / 2);
    var verticalCenterOffset = (size.height / 2);
    canvas.translate(
      horizontalCenterOffset,
      verticalCenterOffset,
    );

    drawMap(canvas, size);

    canvas.translate(
      map.baseWidth / 2 * -1,
      map.baseHeight / 2 * -1,
    );

    canvas.translate(map.baseWidth / 2, map.baseHeight / 2);

    for (final mapObject in map.objects) {
      mapObject.draw(canvas, size, selected: false);
    }
    for (final testPoint in map.testPoints) {
      testPoint.draw(canvas, size);
    }

    for (final beacon in map.beacons) {
      beacon.draw(canvas, size);
    }

    if (calculatedOffset != null) {
      _drawPoint(canvas, calculatedOffset!, true);
    }
  }
}

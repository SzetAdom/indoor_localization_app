import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

class MapHelper {
  static bool polyContains(
      int nvert, List<double> vertx, List<double> verty, Offset test) {
    int c = 0;
    int j = nvert - 1;

    try {
      for (int i = 0; i < nvert && j < nvert; i++) {
        if (((verty[i] > test.dy) != (verty[j] > test.dy)) &&
            (test.dx <
                (vertx[j] - vertx[i]) *
                        (test.dy - verty[i]) /
                        (verty[j] - verty[i]) +
                    vertx[i])) {
          c = 1 - c;
        }

        j++;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    return c == 1;
  }

  static bool edgeContainsWithTolerance(List<Offset> points, Offset point,
      {double tolerance = 10}) {
    final path = Path();

    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    path.close();

    final rect = path.getBounds();

    final left = rect.left - tolerance;
    final right = rect.right + tolerance;
    final top = rect.top - tolerance;
    final bottom = rect.bottom + tolerance;

    final rectPath = Path()
      ..moveTo(left, top)
      ..lineTo(right, top)
      ..lineTo(right, bottom)
      ..lineTo(left, bottom)
      ..close();

    bool edgeContaines = rectPath.contains(point);

    return edgeContaines;
  }

  static double direction(Offset from, Offset to) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;

    final radians = atan2(dy, dx);

    return radians;
  }

  static Offset offsetFromDirection(double direction, double distance) {
    final dx = distance * cos(direction);
    final dy = distance * sin(direction);

    return Offset(dx, dy);
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

class MapObjectDataModel {
  double x;
  double y;
  double width;
  double height;
  double angle;

  MapObjectDataModel(
      {required this.x,
      required this.y,
      required this.width,
      required this.height,
      required this.angle}) {
    angle = angle % 360;
  }

  Rect get rect => Rect.fromCenter(
        center: Offset(x, y),
        width: width,
        height: height,
      );

  double get angleInRadiant => (angle * (pi / 180));

  Offset get center => rect.center;

  EdgeInsets get edgeInsets =>
      EdgeInsets.fromLTRB(rect.left, rect.top, rect.right, rect.bottom);

  EdgeInsets getLocalEdgeInsets() {
    var leftOffset = toLocalOffset(Offset(edgeInsets.left, 0));
    var rightOffset = toLocalOffset(Offset(edgeInsets.right, 0));
    var topOffset = toLocalOffset(Offset(0, edgeInsets.top));
    var bottomOffset = toLocalOffset(Offset(0, edgeInsets.bottom));

    return EdgeInsets.fromLTRB(
        leftOffset.dx, topOffset.dy, rightOffset.dx, bottomOffset.dy);
  }

  Offset toLocalOffset(Offset globalOFfset) {
    var res = globalOFfset - center;
    return res;
  }

  Offset toGlobalOffset(Offset localOffset) {
    var res = localOffset + center;
    return res;
  }

  Matrix4 get matrix => Matrix4.identity()..translate(x, y);

  moveByMatrix4(Matrix4? matrix4) {
    if (matrix4 == null) return;

    var translationVector = matrix4.getTranslation();
    x = translationVector.x;
    y = translationVector.y;
  }

  void resizeByRect(Rect rect) {
    x = rect.center.dx;
    y = rect.center.dy;
    width = rect.width;
    height = rect.height;
  }

  @override
  String toString() {
    return 'MapObjectDataModel(x: $x, y: $y, width: $width, height: $height, angle: $angle)';
  }

  MapObjectDataModel copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? angle,
  }) {
    return MapObjectDataModel(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      angle: angle ?? this.angle,
    );
  }

  MapObjectDataModel.fromJson(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'],
        width = json['width'],
        height = json['height'],
        angle = json['angle'];
}

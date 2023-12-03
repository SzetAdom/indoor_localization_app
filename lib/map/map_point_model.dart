import 'package:flutter/material.dart';

class MapPointModel {
  final String id;
  Color? color;
  double x;
  double y;
  String? description;
  String? icon;

  MapPointModel({
    required this.id,
    required this.x,
    required this.y,
    this.color,
  });

  factory MapPointModel.fromJson(Map<String, dynamic> json) {
    return MapPointModel(
      id: json['id'],
      x: json['x'],
      y: json['y'],
    );
  }

  Offset toOffset() {
    return Offset(
      x,
      y,
    );
  }

  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    canvas.drawCircle(toOffset(), 5, paint);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'x': x,
      'y': y,
      'description': description,
      'icon': icon,
    };
  }

  MapPointModel copyWith({
    String? id,
    Color? color,
    double? x,
    double? y,
    String? description,
    String? icon,
  }) {
    return MapPointModel(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

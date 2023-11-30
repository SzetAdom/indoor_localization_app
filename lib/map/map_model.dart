import 'package:flutter/material.dart';
import 'package:indoor_localization_app/map/map_object_model.dart';

class MapModel {
  double toDouble(String number) {
    return double.parse(number);
  }

  String id;
  String name;

  List<MapObjectModel> objects;

  MapModel({
    required this.id,
    required this.name,
    required this.objects,
    this.extraWidthRight = 100,
    this.extraWidthLeft = 100,
    this.extraHeightTop = 100,
    this.extraHeightBottom = 100,
  });

  factory MapModel.fromJson(Map<String, dynamic> json) {
    var objects = json['objects'] as List;
    List<MapObjectModel> objectsList =
        objects.map((e) => MapObjectModel.fromJson(e)).toList();
    return MapModel(
      id: json['id'],
      name: json['name'],
      objects: objectsList,
      extraWidthRight: double.parse(json['extraWidthRight'].toString()),
      extraWidthLeft: double.parse(json['extraWidthLeft'].toString()),
      extraHeightTop: double.parse(json['extraHeightTop'].toString()),
      extraHeightBottom: double.parse(json['extraHeightBottom'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'objects': objects.map((e) => e.toJson()).toList(),
      'extraWidthRight': extraWidthRight,
      'extraWidthLeft': extraWidthLeft,
      'extraHeightTop': extraHeightTop,
      'extraHeightBottom': extraHeightBottom,
    };
  }

  double baseWidth = 1000;
  double baseHeight = 1000;

  Size get baseSize => Size(baseWidth, baseHeight);
  double extraWidthRight;
  double extraWidthLeft;
  double extraHeightTop;
  double extraHeightBottom;

  double get width => baseWidth + extraWidthRight + extraWidthLeft;
  double get height => baseHeight + extraHeightTop + extraHeightBottom;
  double get widthRight => baseWidth / 2 + extraWidthRight;
  double get widthLeft => baseWidth / 2 + extraWidthLeft;
  double get heightTop => baseHeight / 2 + extraHeightTop;
  double get heightBottom => baseHeight / 2 + extraHeightBottom;

//starting point
//list of objects
}

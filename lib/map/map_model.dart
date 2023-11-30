import 'package:flutter/material.dart';
import 'package:indoor_localization_app/map/map_object_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_model.g.dart';

@JsonSerializable()
class MapModel {
  String id;
  String name;

  List<MapObjectModel> objects;

  MapModel({
    required this.id,
    required this.name,
    required this.objects,
    this.extraWidthRigth = 100,
    this.extraWidthLeft = 100,
    this.extraHeightTop = 100,
    this.extraHeightBottom = 100,
  });

  factory MapModel.fromJson(Map<String, dynamic> json) =>
      _$MapModelFromJson(json);

  Map<String, dynamic> toJson() => _$MapModelToJson(this);

  double baseWidth = 1000;
  double baseHeight = 1000;

  Size get baseSize => Size(baseWidth, baseHeight);

  double extraWidthRigth;
  double extraWidthLeft;
  double extraHeightTop;
  double extraHeightBottom;

  double get width => baseWidth + extraWidthRigth + extraWidthLeft;
  double get height => baseHeight + extraHeightTop + extraHeightBottom;
  double get widthRight => baseWidth / 2 + extraWidthRigth;
  double get widthLeft => baseWidth / 2 + extraWidthLeft;
  double get heightTop => baseHeight / 2 + extraHeightTop;
  double get heightBottom => baseHeight / 2 + extraHeightBottom;

//starting point
//list of objects
}

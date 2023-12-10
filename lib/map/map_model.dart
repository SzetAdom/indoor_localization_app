import 'package:flutter/material.dart';
import 'package:indoor_localization_app/map/map_beacon_model.dart';
import 'package:indoor_localization_app/map/test_point_model.dart';
import 'package:indoor_localization_app/map/wall_object.dart';

class MapModel {
  double toDouble(String number) {
    return double.parse(number);
  }

  String id;
  String name;

  List<WallObject> objects;
  List<TestPointModel> testPoints;
  List<MapBeaconModel> beacons;

  MapModel({
    required this.id,
    required this.name,
    required this.objects,
    this.extraWidthRight = 100,
    this.extraWidthLeft = 100,
    this.extraHeightTop = 100,
    this.extraHeightBottom = 100,
    this.testPoints = const [],
    this.beacons = const [],
  });

  factory MapModel.fromJson(Map<String, dynamic> json) {
    var objects = json['objects'] as List;
    List<WallObject> objectsList =
        objects.map((e) => WallObject.fromJson(e)).toList();

    List<TestPointModel> testPoints = [];
    if (json['testPoints'] != null) {
      var testPointsJson = json['testPoints'] as List;
      testPoints =
          testPointsJson.map((e) => TestPointModel.fromJson(e)).toList();
    }

    List<MapBeaconModel> beacons = [];
    if (json['beacons'] != null) {
      var beaconsJson = json['beacons'] as List;
      beacons = beaconsJson.map((e) => MapBeaconModel.fromJson(e)).toList();
    }

    return MapModel(
      id: json['id'],
      name: json['name'],
      objects: objectsList,
      extraWidthRight: double.parse(json['extraWidthRight'].toString()),
      extraWidthLeft: double.parse(json['extraWidthLeft'].toString()),
      extraHeightTop: double.parse(json['extraHeightTop'].toString()),
      extraHeightBottom: double.parse(json['extraHeightBottom'].toString()),
      testPoints: testPoints,
      beacons: beacons,
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
      'testPoints': testPoints.map((e) => e.toJson()).toList(),
      'beacons': beacons.map((e) => e.toJson()).toList(),
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

}

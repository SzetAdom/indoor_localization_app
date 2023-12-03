import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:indoor_localization_app/map/map_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class MapController extends ChangeNotifier {
  MapModel? map;

  Future<bool> loadMap(String path) async {
    try {
      var jsonString = await File(path).readAsString();
      setMap(jsonString);
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  void setMap(String json) {
    var mapModel = MapModel.fromJson(jsonDecode(json));
    map = mapModel;
    notifyListeners();
  }

  Offset normalize(Offset offset) {
    return translateToMapOffset(translateFromCanvas(offset));
  }

  Offset translateFromCanvas(Offset offset) {
    var horizontalOffset = (canvasSize.width / 2) * zoomLevel;
    var verticalOffset = (canvasSize.height / 2) * zoomLevel;

    return offset.translate(-1 * horizontalOffset, -1 * verticalOffset) /
        zoomLevel;
  }

  Offset translateToMapOffset(Offset offset) {
    return offset.translate(-canvasOffset.dx, -canvasOffset.dy);
  }

  Offset canvasOffset = Offset.zero;

  Size canvasSize = Size.zero;

  double gridStep = 1000;

  double zoomLevel = 1.0;

  double zoomSensitive = 0.07;

  double pointSize = 10;

  double get mapEditPointSize => 15 / zoomLevel;

  vector.Matrix4 matrix = vector.Matrix4.identity();

  void onMatrixUpdate(vector.Matrix4 m, vector.Matrix4? t, vector.Matrix4? s,
      vector.Matrix4? r) {
    matrix = m;

    notifyListeners();
  }

  void logTestData(String data) {
    FlutterLogs.logToFile(
        logFileName: "test_point", logMessage: data, overwrite: false);
  }

  void logRealData(String data) {
    FlutterLogs.logToFile(
        logFileName: "test_point", logMessage: data, overwrite: false);
  }

  Future<bool> copyLogsToSaveFolder() async {
    try {
      var appDir = await getExternalStorageDirectory();
      var path = "${appDir!.path}/MyLogs/Logs/device.txt";
      File file = File(path);
      var newPath = "/storage/emulated/0/Download/data.txt";
      await file.copy(newPath);
    } catch (e) {
      return false;
    }
    return true;
  }
}

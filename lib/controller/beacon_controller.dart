import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:indoor_localization_app/map/map_beacon_model.dart';
import 'package:indoor_localization_app/map/test_point_model.dart';
import 'package:indoor_localization_app/models/beacon_log_model.dart';
import 'package:path_provider/path_provider.dart';

class BeaconController extends ChangeNotifier {
  TestPointModel? testPoint;
  Offset? calculatedPosition;

  List<MapBeaconModel> mapBeacons = [];

  void setBeaconLocations(List<MapBeaconModel> mapBeacons) {
    this.mapBeacons = mapBeacons;
    notifyListeners();
  }

  setTestPoint(TestPointModel? testPoint) {
    this.testPoint = testPoint;
    notifyListeners();
  }

  var regions = [
    Region(
      identifier: 'com.beacon',
    ),
  ];

  List<String> uuid = [
    'B9407F30-F5F8-466E-AFF9-25556B57FEEA',
    'B9407F30-F5F8-466E-AFF9-25556B57FEEB',
    'B9407F30-F5F8-466E-AFF9-25556B57FEEC',
  ];

  StreamSubscription<RangingResult>? _streamRanging;

  Future<void> init() async {
    await flutterBeacon.initializeAndCheckScanning;
    await flutterBeacon.setBetweenScanPeriod(100);
  }

  Future<void> stopRanging() async {
    _streamRanging?.cancel();
  }

  Future<void> startRangingAndLogging(Function(BeaconLogModel log) showLog,
      {String? testId}) async {
    print('Start ranging...');

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
      var dateTime = DateTime.now();
      if (result.beacons.isNotEmpty) {
        for (var beacon in result.beacons
            .where((element) => uuid.contains(element.proximityUUID))) {
          if (beacon.txPower != null) {
            BeaconLogModel beaconLogModel = BeaconLogModel(
              uuid: beacon.proximityUUID,
              major: beacon.major,
              minor: beacon.minor,
              rssi: beacon.rssi,
              txPower: beacon.txPower,
              accuracy: beacon.accuracy,
              testId: testId,
              time: dateTime,
            );

            FlutterLogs.logToFile(
                logFileName: testId != null ? "test_point" : "real_time",
                logMessage: "${jsonEncode(beaconLogModel.toJson())}\n",
                overwrite: false);
            showLog(beaconLogModel);
          }
        }
      }

      notifyListeners();
    });
  }

  void logTestData(String testPoint) {
    FlutterLogs.logToFile(
        logFileName: "test_point", logMessage: testPoint, overwrite: false);
  }

  void logRealData() {
    FlutterLogs.logToFile(
        logFileName: "test_point", logMessage: "", overwrite: false);
  }

  Future<bool> copyLogsToSaveFolder({bool test = false}) async {
    try {
      var appDir = await getExternalStorageDirectory();
      var path = "${appDir!.path}/MyLogs/Logs/";
      Directory directory = Directory(path);
      var newPath = "/storage/emulated/0/Download/log/";
      Directory newDirectory = Directory(newPath);
      if (!await directory.exists()) {
        await directory.create();
      }

      for (var file in directory.listSync()) {
        if (file is File) {
          var fileName = file.path.split('/').last;
          if (fileName.contains(test ? "test_point" : "real_time")) {
            var newFile = File("$newPath$fileName");
            bool exists = await newFile.exists();
            int i = 1;
            while (exists) {
              newFile = File("$newPath${fileName.split('.').first}_$i.txt");
              exists = await newFile.exists();
              i++;
            }
            await file.copy(newFile.path);
          }
        }
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> createStatistics(String analysis) async {
    try {
      File file = File("/storage/emulated/0/Download/log/analysis.txt");
      //check if file exists
      bool exists = await file.exists();
      int i = 1;
      while (exists) {
        file = File("/storage/emulated/0/Download/log/analysis_$i.txt");
        exists = await file.exists();
        i++;
      }
      await file.create();
      await file.writeAsString(analysis);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<BeaconLogModel>?> loadLogs({bool test = false}) async {
    try {
      var appDir = await getExternalStorageDirectory();
      var path =
          "${appDir!.path}/MyLogs/Logs/${test ? "test_point" : "real_time"}.log";
      File file = File(path);
      var lines = await file.readAsLines();

      var beacons = <BeaconLogModel>[];

      for (var line in lines) {
        var json = jsonDecode(line) as Map<String, dynamic>;
        var beacon = BeaconLogModel.fromJson(json);
        if (beacon.accuracy != null) {
          beacons.add(beacon);
        }
      }
      return beacons;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Offset? calculatePosition(Map<String, double> beaconDistancess) {
    if (mapBeacons.length < 3 || beaconDistancess.length < 3) return null;

    try {
      var beacon1 = mapBeacons[0];
      var beacon2 = mapBeacons[1];
      var beacon3 = mapBeacons[2];

      var beacon1distance = beaconDistancess[beacon1.uuid];
      var beacon2distance = beaconDistancess[beacon2.uuid];
      var beacon3distance = beaconDistancess[beacon3.uuid];

      var x1 = beacon1.x;
      var y1 = beacon1.y;

      var x2 = beacon2.x;
      var y2 = beacon2.y;

      var x3 = beacon3.x;
      var y3 = beacon3.y;

      var a = 2 * x2 - 2 * x1;
      var b = 2 * y2 - 2 * y1;
      var c = pow(beacon1distance!, 2) -
          pow(beacon2distance!, 2) -
          pow(x1, 2) +
          pow(x2, 2) -
          pow(y1, 2) +
          pow(y2, 2);

      var d = 2 * x3 - 2 * x2;
      var e = 2 * y3 - 2 * y2;
      var f = pow(beacon2distance, 2) -
          pow(beacon3distance!, 2) -
          pow(x2, 2) +
          pow(x3, 2) -
          pow(y2, 2) +
          pow(y3, 2);

      var x = (c * e - f * b) / (e * a - b * d);

      var y = (c * d - a * f) / (b * d - a * e);

      return Offset(x, y);
    } catch (e) {
      print(e);
    }
    return null;
  }

  double distanceBetweenPoints(Offset point1, Offset point2) {
    return sqrt(pow(point1.dx - point2.dx, 2) + pow(point1.dy - point2.dy, 2));
  }

  Future<void> calculateStatistics(Function(String analysis) callBack,
      {bool test = false}) async {
    var beacons = await loadLogs(test: test);
    if (beacons == null) return;

    var groupedBeacons = <String, List<BeaconLogModel>>{};
    for (var beacon in beacons) {
      var key = "${beacon.simpleUUID}-${beacon.major}-${beacon.minor}";
      if (groupedBeacons.containsKey(key)) {
        groupedBeacons[key]!.add(beacon);
      } else {
        groupedBeacons[key] = [beacon];
      }
    }

    var groupedBeaconsList = groupedBeacons.values.toList();
    List<double> averageAccuracyList = [];
    String statistics = "";
    statistics += '---------------------------------\n';
    //average sample count per beacons per second
    statistics += "Átlagos mintaszám másodpercenként (beaconönként):\n";
    for (var element in groupedBeaconsList) {
      element.sort((a, b) => a.time!.compareTo(b.time!));
      var dateRange = element.last.time!.difference(element.first.time!);
      var seconds = dateRange.inSeconds;
      averageAccuracyList.add(element.length / seconds);

      statistics +=
          "${element.first.simpleUUID}-${element.first.major}-${element.first.minor} - ${element.length / seconds}\n";
    }
    statistics += '---------------------------------\n';
    statistics +=
        "Átlagos mintaszám másodpercenként (összesen): ${averageAccuracyList.reduce((a, b) => a + b) / averageAccuracyList.length}\n";

    statistics += '---------------------------------\n';

    // rssi changes grouper
    var groupedRssiChanges = <String, List<int>>{};
    for (var element in groupedBeaconsList) {
      var key =
          "${element.first.simpleUUID}-${element.first.major}-${element.first.minor}";
      var rssiChanges = <int>[];
      for (var i = 0; i < element.length - 1; i++) {
        var rssiChange = element[i + 1].rssi! - element[i].rssi!;
        rssiChanges.add(rssiChange);
      }
      groupedRssiChanges[key] = rssiChanges;
    }

    //rssi changes in absolute value
    var groupedRssiChangesAbs = <String, List<int>>{};
    for (var element in groupedRssiChanges.entries) {
      var key = element.key;
      var rssiChanges = element.value;
      var rssiChangesAbs = <int>[];
      for (var rssiChange in rssiChanges) {
        rssiChangesAbs.add(rssiChange.abs());
      }
      groupedRssiChangesAbs[key] = rssiChangesAbs;
    }

    //average, min and max rssi change in absolute value per beacon
    statistics += "Rssi változás (beaconönként):\n";
    for (var element in groupedRssiChangesAbs.entries) {
      var key = element.key;
      var rssiChangesAbs = element.value;
      var sum = 0;
      var min = 10;
      var max = 0;
      var allZeroCount = 0;
      var zeroCount = 0;
      var longestZeroCount = 0;
      for (var rssiChangeAbs in rssiChangesAbs) {
        sum += rssiChangeAbs;
        if (rssiChangeAbs < min) {
          min = rssiChangeAbs;
        }
        if (rssiChangeAbs > max) {
          max = rssiChangeAbs;
        }
        if (rssiChangeAbs == 0) {
          allZeroCount++;
          zeroCount++;
          if (zeroCount > longestZeroCount) {
            longestZeroCount = zeroCount;
          }
        } else {
          zeroCount = 0;
        }
      }

      statistics += """$key
          Átlagos: ${sum / rssiChangesAbs.length}, Min: $min, Max: $max
          Változásmentes minták aránya: $allZeroCount / ${rssiChangesAbs.length} (${allZeroCount / rssiChangesAbs.length * 100}%)
          Leghosszabb változás nélküli minták száma: $longestZeroCount\n""";
    }
    statistics += '---------------------------------\n';
    //average, min and max rssi change in absolute value
    var rssiChangesAbs = <int>[];
    for (var element in groupedRssiChangesAbs.entries) {
      var rssiChanges = element.value;
      for (var rssiChange in rssiChanges) {
        rssiChangesAbs.add(rssiChange);
      }
    }
    var sum = 0;
    for (var rssiChangeAbs in rssiChangesAbs) {
      sum += rssiChangeAbs;
    }
    statistics +=
        """Átlagos rssi változás (összesen): ${sum / rssiChangesAbs.length}""";

    statistics += '---------------------------------\n';

    Map<String, double> averageDistanceValueByBeacons = {};

    for (var element in groupedBeaconsList) {
      var key = element.first.uuid;
      var sum = 0.0;

      for (var beacon in element) {
        sum += beacon.accuracy!;
      }

      var average = sum / element.length * 100;

      averageDistanceValueByBeacons[key] = average;
    }

    //calculate my position based on the beacons
    var myPosition = calculatePosition(averageDistanceValueByBeacons);
    if (myPosition != null) {
      calculatedPosition = myPosition;
      notifyListeners();

      statistics += "Számolt pozíció: ${myPosition.dx}, ${myPosition.dy}\n";
      if (testPoint != null) {
        //calculate distance between my position and testpoint
        var distance = distanceBetweenPoints(
            myPosition, Offset(testPoint!.x, testPoint!.y));

        statistics += "Valós és számolt távolság közti különbség: $distance\n";
      }
    } else {
      statistics += "Pozíció: -\n";
    }

    callBack(statistics);
    print(statistics);
  }
}

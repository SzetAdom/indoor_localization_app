import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:indoor_localization_app/models/beacon_model.dart';

class BeaconController extends ChangeNotifier {
  var regions = <Region>[];

  List<BeaconModel> beacons = [];

  StreamSubscription<RangingResult>? _streamRanging;

  Future<void> stopRanging() async {
    // await BeaconsPlugin.stopMonitoring();
    // await FlutterBluePlus.stopScan();
    _streamRanging?.cancel();
  }

  Future<void> startRanging() async {
    log('Start ranging...');
    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
      if (result.beacons.isNotEmpty) {
        for (var beacon in result.beacons) {
          log('Beacon - ${beacon.proximityUUID} - ${beacon.txPower} - ${beacon.rssi} ');
        }
      }

      notifyListeners();
    });
  }
}

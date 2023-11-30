import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:indoor_localization_app/models/beacon_model.dart';

class BeaconController extends ChangeNotifier {
  var regions = <Region>[];

  List<BeaconModel> beacons = [];

  StreamSubscription<RangingResult>? _streamRanging;

  Future<void> init() async {
    try {
      var res = await flutterBeacon.initializeAndCheckScanning;

      regions.add(Region(
        identifier: 'pink',
        proximityUUID: 'B9407F30-F5F8-466E-AFF9-25556B57FEEC'
      ));
      regions.add(Region(
        identifier: 'mobile',
        proximityUUID: '2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6'
      ));
      regions.add(Region(
        identifier: 'yellow with ipad',
        proximityUUID: 'B9407F30-F5F8-466E-AFF9-025556B57EEA'
      ));

    } on PlatformException {
      log('something went wrong');
    }
  }

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

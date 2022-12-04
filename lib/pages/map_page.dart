import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  StreamSubscription<RangingResult>? _streamRanging;
  StreamSubscription<MonitoringResult>? _streamMonitoring;
  final regions = <Region>[];
  late Future future;

  Map<String, String> beacons = {};

  Future<void> _init() async {
    try {
      var res = await flutterBeacon.initializeAndCheckScanning;
      log(res.toString());
      var identifiers = await _getBeaconIdentifiers();

      for (var identifier in identifiers) {
        regions.add(Region(identifier: 'com.beacon', proximityUUID: null));
      }
      // regions.add(Region(identifier: 'com.beacon'));
      log('init done');
    } on PlatformException {
      log('something went wrong');
    }
  }

  Future<List<String>> _getBeaconIdentifiers() async {
    List<String> beaconIdentifiers = ['b9407f30-f5f8-466e-aff9-25556b57feeb'];

    return beaconIdentifiers;
  }

  void startRanging() {
    log('Start ranging...');
    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
      log(result.toString());
      var map = <String, String>{};
      for (var beacon in result.beacons) {
        if (beacon.txPower != null) {
          var distance = getDistance(beacon.rssi, beacon.txPower!);
          map[beacon.proximityUUID] = distance;
          log('${beacon.proximityUUID} : $distance');
        }
      }
      setState(() {
        beacons = map;
      });
      setState(() {});
    });
  }

  String getDistance(int rssi, int txPower) {
    var res = ((math.pow(10, (txPower - rssi) / (10 * 2)))).toString();
    return res;
  }

  void stopRanging() {
    log('Stop ranging...');
    _streamRanging?.cancel();
  }

  void startMonitoring() {
    log('Start monitoring...');
    _streamMonitoring =
        flutterBeacon.monitoring(regions).listen((MonitoringResult result) {
      log(result.toString());
    });
  }

  void stopMonitoring() {
    log('Stop ranging...');
    _streamRanging?.cancel();
  }

  @override
  void initState() {
    future = _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () => startRanging(),
                  child: Container(
                    margin: const EdgeInsets.all(15),
                    color: Colors.amber,
                    height: 100,
                    child: const Center(
                      child: Text('Start ranging beacons'),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => stopRanging(),
                  child: Container(
                    margin: const EdgeInsets.all(15),
                    color: Colors.amber,
                    height: 100,
                    child: const Center(
                      child: Text('Stop ranging beacons'),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5),
                  height: 20,
                  child: Center(
                    child: Text('count: ${beacons.length}'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5),
                  height: 100,
                  child: Center(
                    child: Text(
                      beacons.values.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // GestureDetector(
                //   onTap: () => startMonitoring(),
                //   child: Container(
                //     margin: const EdgeInsets.all(15),
                //     color: Colors.amber,
                //     height: 100,
                //     child: const Center(
                //       child: Text('Start monitoring beacons'),
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   onTap: () => startMonitoring(),
                //   child: Container(
                //     margin: const EdgeInsets.all(15),
                //     color: Colors.amber,
                //     height: 100,
                //     child: const Center(
                //       child: Text('Stop monitoring beacons'),
                //     ),
                //   ),
                // ),
              ],
            );
          }),
    );
  }
}

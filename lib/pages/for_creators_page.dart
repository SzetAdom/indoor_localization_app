import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';

class ForCreatorsPage extends StatefulWidget {
  const ForCreatorsPage({Key? key}) : super(key: key);

  @override
  State<ForCreatorsPage> createState() => _ForCreatorsPageState();
}

class _ForCreatorsPageState extends State<ForCreatorsPage> {
  var isRunning = false;

  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();

  late Future future;

  Map<String, String> beacons = {};

  Future<List<String>> _getBeaconIdentifiers() async {
    List<String> beaconIdentifiers = ['b9407f30-f5f8-466e-aff9-25556b57fe6a'];

    return beaconIdentifiers;
  }

  void startRanging() async {
    await BeaconsPlugin.startMonitoring();
    log('Start ranging...');
    setState(() {
      isRunning = true;
    });
  }

  String getDistance(int rssi, int txPower) {
    var res = ((math.pow(10, (txPower - rssi) / (10 * 2)))).toString();
    return res;
  }

  void stopRanging() {
    log('Stop ranging...');
  }

  @override
  void initState() {
    future = initPlatformState();
    super.initState();
  }

  @override
  void dispose() {
    beaconEventsController.close();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await BeaconsPlugin.addRegion("b9407f30-f5f8-466e-aff9-25556b57feec",
        "b9407f30-f5f8-466e-aff9-25556b57feec");

    BeaconsPlugin.setForegroundScanPeriodForAndroid(
        foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);

    BeaconsPlugin.setBackgroundScanPeriodForAndroid(
        backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);

    BeaconsPlugin.listenToBeacons(beaconEventsController);

    beaconEventsController.stream.listen(
        (data) {
          log('received data: $data');
          if (data.isNotEmpty && isRunning) {
            log(data.toString());

            log("Beacons DataReceived: $data");
          }
        },
        onDone: () {},
        onError: (error) {
          log("Error: $error");
        });

    await BeaconsPlugin.runInBackground(true);

    // BeaconsPlugin.event_channel.receiveBroadcastStream().listen((event) {
    //   dev.log("Event: $event");
    //   beaconEventsController.add(event);
    // }, onError: (error) {
    //   dev.log("Error: $error");
    // }, onDone: () {
    //   dev.log("Done");
    // });

    if (!mounted) return;
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

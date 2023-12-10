// import 'dart:async';
// import 'dart:developer';
// import 'dart:math' as math;

// import 'package:epitaph_ips/epitaph_ips/buildings/point.dart';
// import 'package:epitaph_ips/epitaph_ips/positioning_system/beacon.dart'
//     as otherBeacon;
// import 'package:epitaph_ips/epitaph_ips/positioning_system/real_beacon.dart';
// import 'package:epitaph_ips/epitaph_ips/tracking/calculator.dart';
// import 'package:epitaph_ips/epitaph_ips/tracking/filter.dart';
// import 'package:epitaph_ips/epitaph_ips/tracking/lma.dart';
// import 'package:epitaph_ips/epitaph_ips/tracking/merwe_function.dart';
// import 'package:epitaph_ips/epitaph_ips/tracking/sigma_point_function.dart';
// import 'package:epitaph_ips/epitaph_ips/tracking/simple_ukf.dart';
// import 'package:epitaph_ips/epitaph_ips/tracking/tracker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_beacon/flutter_beacon.dart';
// import 'package:ml_linalg/linalg.dart';

// class BeaconControllerOld extends ChangeNotifier {
//   StreamSubscription<RangingResult>? _streamRanging;
//   final regions = <Region>[];

//   Point calculatedPosition = Point(0, 0);
//   Point filteredPosition = Point(0, 0);
//   Point finalPosition = Point(0, 0);
//   Point userPosition = Point(0, 0);
//   late Future future;
//   Map<String, Point> beaconPositions = {
//     'B9407F30-F5F8-466E-AFF9-25556B57FE6D': Point(0.5, 2.75),
//     'B9407F30-F5F8-466E-AFF9-025556B57EEA': Point(2.40, 0),
//     'B9407F30-F5F8-466E-AFF9-25556B57FEEC': Point(4, 1.75),
//   };
//   Map<String, double> distances = {
//     'B9407F30-F5F8-466E-AFF9-25556B57FE6D': 0,
//     'B9407F30-F5F8-466E-AFF9-025556B57EEA': 0,
//     'B9407F30-F5F8-466E-AFF9-25556B57FEEC': 0
//   };

//   Map<String, otherBeacon.Beacon> beacons = {};

//   int realBeacnCount = 0;

//   Future<void> init() async {
//     try {
//       var res = await flutterBeacon.initializeAndCheckScanning;
//       log(res.toString());

//       regions.add(Region(identifier: 'com.beacon', proximityUUID: null));

//       // regions.add(Region(identifier: 'com.beacon'));
//       log('init done');
//     } on PlatformException {
//       log('something went wrong');
//     }
//   }

//   Map<String, List<int>> history = {
//     'B9407F30-F5F8-466E-AFF9-25556B57FE6D': [],
//     'B9407F30-F5F8-466E-AFF9-025556B57EEA': [],
//     'B9407F30-F5F8-466E-AFF9-25556B57FEEC': []
//   };

//   void startRanging() {
//     log('Start ranging...');
//     _streamRanging =
//         flutterBeacon.ranging(regions).listen((RangingResult result) {
//       // log(result.toString());

//       for (var beacon in result.beacons) {
//         if (beacon.txPower != null) {
//           log(beacon.toString());

//           history[beacon.proximityUUID]!.insert(0, beacon.txPower!);
//           if (history[beacon.proximityUUID]!.length > 20) {
//             history[beacon.proximityUUID]!.removeLast();
//           }

//           var beaconPoint = beaconPositions[beacon.proximityUUID];
//           if (beaconPoint != null) {
//             var realBeacon = RealBeacon(
//                 beacon.proximityUUID, beacon.proximityUUID, beaconPoint,
//                 configuration: otherBeacon.BeaconsConfiguration(
//                     // measuredPower: (history[beacon.proximityUUID]!
//                     //             .reduce((value, element) => value + element) /
//                     //         history[beacon.proximityUUID]!.length)
//                     //     .round(),
//                     measuredPower: sortList(history[beacon.proximityUUID]!)[
//                         (history[beacon.proximityUUID]!.length / 2).floor()],
//                     environmentalFactor: 3,
//                     advertisementInterval: 0.3));
//             realBeacon.rssiUpdate(beacon.rssi);
//             beacons[beacon.proximityUUID] = realBeacon;

//             distances[beacon.proximityUUID] =
//                 getDistance(beacon.rssi, realBeacon.measuredPower, n: 2.5);

//             // log('power: ${beacon.rssi}');
//           }
//         }
//       }

//       realBeacnCount = result.beacons.length;
//       if (beacons.keys.length > 2) {
//         userPosition = getDistanceNew(beacons.values.toList());
//       }
//       notifyListeners();
//     });
//   }

//   List<int> sortList(List<int> input) {
//     List<int> newList = [];
//     newList.addAll(input);
//     newList.sort();

//     return newList;
//   }

//   Point getDistanceNew(List<otherBeacon.Beacon> beacons) {
//     //Initialize calculator
//     Calculator calculator = LMA();

// //Very basic models for unscented Kalman filter
//     Matrix fxUserLocation(Matrix x, double dt, List? args) {
//       List<double> list = [
//         x[1][0] * dt + x[0][0],
//         x[1][0],
//         x[3][0] * dt + x[2][0],
//         x[3][0]
//       ];
//       return Matrix.fromFlattenedList(list, 4, 1);
//     }

//     Matrix hxUserLocation(Matrix x, List? args) {
//       return Matrix.row([x[0][0], x[0][2]]);
//     }

// //Sigma point function for unscented Kalman filter
//     SigmaPointFunction sigmaPoints = MerweFunction(4, 0.1, 2.0, 1.0);

// //Initialize filter
//     Filter filter = SimpleUKF(4, 2, 0.3, hxUserLocation, fxUserLocation,
//         sigmaPoints, sigmaPoints.numberOfSigmaPoints());

// //Initialize tracker
//     Tracker tracker = Tracker(calculator, filter);

// //Engage tracker by calling this method with a list with at least 3 Beacon instances
//     tracker.initiateTrackingCycle(beacons);

// //The result of the tracker can be called as follows
//     tracker.finalPosition;
//     log("final: ${tracker.finalPosition}");

// //Raw calculated position and filtered position can be called as well
//     tracker.calculatedPosition;
//     log("calc: ${tracker.calculatedPosition}");
//     log("filter: ${tracker.filteredPosition}");

//     calculatedPosition = tracker.calculatedPosition;
//     filteredPosition = tracker.filteredPosition;
//     finalPosition = tracker.finalPosition;
//     notifyListeners();
//     return tracker.finalPosition;
//   }

//   double getDistance(int rssi, int txPower, {double n = 2}) {
//     var res = (math.pow(10, (txPower - rssi) / (10 * n))).toDouble();
//     return res;
//   }

//   void stopRanging() {
//     log('Stop ranging...');
//     _streamRanging?.cancel();
//   }
// }

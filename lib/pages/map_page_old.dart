import 'dart:async';

import 'package:flutter/material.dart';
import 'package:indoor_localization_app/controller/beacon_controller_old.dart';
import 'package:indoor_localization_app/pages/map_view_widget.dart';
import 'package:provider/provider.dart';

class MapPageOld extends StatefulWidget {
  const MapPageOld({Key? key}) : super(key: key);

  @override
  State<MapPageOld> createState() => _MapPageOldState();
}

class _MapPageOldState extends State<MapPageOld> {
  late BeaconControllerOld _beaconController;
  late Future _future;
  Future<void> loadMap() async {
    _beaconController.init();
  }

  @override
  void initState() {
    _beaconController = BeaconControllerOld();
    _future = loadMap();
    super.initState();
  }

  @override
  void dispose() {
    _beaconController.stopRanging();
    _beaconController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
        ),
        body: ChangeNotifierProvider<BeaconControllerOld>(
          create: (context) => _beaconController,
          child: Consumer<BeaconControllerOld>(
            builder: ((context, value, child) => FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => _beaconController.startRanging(),
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          color: Colors.amber,
                          height: 50,
                          child: const Center(
                            child: Text('Start ranging beacons'),
                          ),
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () => _beaconController.stopRanging(),
                      //   child: Container(
                      //     margin: const EdgeInsets.all(10),
                      //     color: Colors.amber,
                      //     height: 50,
                      //     child: const Center(
                      //       child: Text('Stop ranging beacons'),
                      //     ),
                      //   ),
                      // ),
                      Container(
                        margin: const EdgeInsets.all(5),
                        height: 20,
                        child: Center(
                          child: Text(
                              'count: ${_beaconController.realBeacnCount}'),
                        ),
                      ),
                      // Container(
                      //   margin: const EdgeInsets.all(5),
                      //   height: 30,
                      //   child: Center(
                      //     child: Text(
                      //       'c: ${_beaconController.calculatedPosition}',
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 30,
                        child: Center(
                          child: Text(
                            'f: ${_beaconController.filteredPosition}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   height: 30,
                      //   child: Center(
                      //     child: Text(
                      //       'fin: ${_beaconController.finalPosition}',
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 200,
                      //   child: Center(
                      //     child: Text(
                      //       'dist: ${_beaconController.distances.values.toString()}',
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ),
                      // ),
                      Expanded(child: Builder(builder: (context) {
                        List<Positioned> pos = [];
                        for (var key
                            in _beaconController.beaconPositions.keys) {
                          var val = _beaconController.beaconPositions[key];
                          pos.add(
                            Positioned.fromRect(
                              rect: Rect.fromCenter(
                                  center: Offset(val!.x * 100, val.y * 100),
                                  width: 10,
                                  height: 10),
                              child: Container(
                                color: Colors.red,
                              ),
                            ),
                          );
                          pos.add(
                            Positioned.fromRect(
                              rect: Rect.fromCenter(
                                  center: Offset(val.x * 100, val.y * 100),
                                  width:
                                      _beaconController.distances[key]! * 100,
                                  height:
                                      _beaconController.distances[key]! * 100),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.red, width: 2)),
                              ),
                            ),
                          );
                        }

                        pos.add(
                          Positioned.fromRect(
                            rect: Rect.fromCenter(
                                center: Offset(
                                    _beaconController.calculatedPosition.x *
                                        100,
                                    _beaconController.calculatedPosition.y *
                                        100),
                                width: 10,
                                height: 10),
                            child: Container(
                              color: Colors.green,
                            ),
                          ),
                        );

                        return MapViewWidget(pos);
                      })),
                    ],
                  );
                })),
          ),
        ));
  }
}
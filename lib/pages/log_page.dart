// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indoor_localization_app/controller/beacon_controller.dart';
import 'package:indoor_localization_app/controller/map_controller.dart';
import 'package:indoor_localization_app/map/test_point_model.dart';
import 'package:indoor_localization_app/models/beacon_log_model.dart';
import 'package:provider/provider.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<String> realTimeLog = [];
  List<BeaconLogModel> logs = [];

  ScrollController? _scrollController;

  String statistics = '';
  @override
  void initState() {
    super.initState();
    if (showLogs) _scrollController = ScrollController();
  }

  void _scrollToBottom() {
    _scrollController?.animateTo(
      _scrollController!.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  bool showLogs = false;
  bool useKalman = false;
  bool followLogs = true;

  void switchShowLogs() {
    setState(() {
      showLogs = !showLogs;
    });
    if (!showLogs) {
      _scrollController?.dispose();
      _scrollController = null;
    } else {
      _scrollController = ScrollController();
    }
  }

  @override
  Widget build(BuildContext context) {
    var beaconController = Provider.of<BeaconController>(context);
    var beaconControllerAsync =
        Provider.of<BeaconController>(context, listen: false);
    var mapController = Provider.of<MapController>(context);

    var buttonStyle = TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        textStyle: const TextStyle(fontSize: 20));

    var testId = beaconController.testPoint?.id;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
              child: Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Teszteset kiválasztása: '),
                    DropdownButton<String>(
                      value: beaconController.testPoint?.id == null
                          ? "Nincs teszteset"
                          : beaconController.testPoint!.name,
                      onChanged: (String? newValue) {
                        TestPointModel? selectedItem;
                        try {
                          selectedItem = mapController.map!.testPoints
                              .firstWhere(
                                  (element) => element.name == newValue);
                        } catch (e) {
                          print(e);
                        }
                        beaconControllerAsync.setTestPoint(selectedItem);
                      },
                      items: [
                        "Nincs teszteset",
                        ...mapController.map!.testPoints
                            .map((e) => e.name)
                            .toList(),
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child:
                              Text(value, style: const TextStyle(fontSize: 20)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        onPressed: () async {
                          try {
                            await beaconControllerAsync.startRangingAndLogging(
                                (BeaconLogModel log) {
                              setState(() {
                                realTimeLog.add(log.toSimpleString());
                                logs.add(log);
                                if (followLogs) {
                                  _scrollToBottom();
                                }
                              });
                            }, testId: testId);
                          } catch (e) {
                            print(e);
                          }
                        },
                        style: buttonStyle,
                        icon: const Icon(Icons.play_arrow_rounded)),
                    IconButton(
                        onPressed: () async {
                          try {
                            // beaconControllerAsync.logTestData("Test point 0");
                            beaconControllerAsync.stopRanging();
                          } catch (e) {
                            print(e);
                          }
                        },
                        style: buttonStyle,
                        icon: const Icon(Icons.stop_rounded)),
                    IconButton(
                        onPressed: () async {
                          FlutterLogs.clearLogs();
                          setState(() {
                            realTimeLog.clear();
                            logs.clear();
                            statistics = '';
                          });
                        },
                        style: buttonStyle,
                        icon: const Icon(Icons.delete_forever_rounded)),
                  ],
                ),
                //show logs switch button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Logok megjelenítése'),
                    Switch(
                        value: showLogs,
                        onChanged: (value) {
                          switchShowLogs();
                        })
                  ],
                ),
                //show logs switch button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Kálmán filter alkalmazása'),
                    Switch(
                        value: useKalman,
                        onChanged: (value) {
                          setState(() {
                            useKalman = value;
                          });
                        })
                  ],
                ),
                //show logs
                if (showLogs)
                  Expanded(
                      child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            followLogs = false;
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            color: Colors.grey[300],
                            child: ListView(
                              controller: _scrollController,
                              children: realTimeLog
                                  .map((e) => Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      child: Text(e)))
                                  .toList(),
                            )),
                      ),
                      //follow the log
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                followLogs = true;
                              });
                              _scrollToBottom();
                            },
                            child: const Icon(Icons.arrow_downward_rounded),
                          ),
                        ),
                      )
                    ],
                  )),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        onPressed: () async {
                          beaconController.calculateStatistics((
                            String statisticsIn,
                          ) {
                            setState(() {
                              statistics = statisticsIn;
                            });
                          },
                              test: testId == null ? false : true,
                              logs: logs,
                              useKalmanFilter: useKalman);
                        },
                        style: buttonStyle,
                        icon: const Icon(Icons.analytics_rounded)),
                    //load logs from file
                    IconButton(
                        onPressed: () async {
                          try {
                            var res = await beaconController.loadLogsFromFile(
                                (BeaconLogModel log) {
                              setState(() {
                                realTimeLog.add(log.toSimpleString());
                                logs.add(log);
                                if (followLogs) {
                                  _scrollToBottom();
                                }
                              });
                            }, test: testId == null ? false : true);

                            if (res) {
                              Fluttertoast.showToast(
                                  msg: 'Log sikeresen betöltve');
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'A log betöltése sikertelen');
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        style: buttonStyle,
                        icon: const Icon(Icons.upload_rounded)),
                    //save logs to file
                    IconButton(
                        onPressed: () async {
                          try {
                            var res1 =
                                await beaconController.copyLogsToSaveFolder(
                                    test: testId == null ? false : true);

                            if (res1) {
                              Fluttertoast.showToast(
                                  msg:
                                      'Log sikeresen átmásolva a letöltések mappába');
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'A logok átmásolása sikertelen');
                            }

                            var res2 = await beaconController
                                .createStatistics(statistics);
                            if (res2) {
                              Fluttertoast.showToast(
                                  msg:
                                      'Statisztika sikeresen létrehozva a letöltések mappába');
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'A statisztika létrehozása sikertelen');
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        style: buttonStyle,
                        icon: const Icon(Icons.save_rounded)),
                  ],
                ),
                if (statistics.isNotEmpty)
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey[300],
                    child: SingleChildScrollView(child: Text(statistics)),
                  )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

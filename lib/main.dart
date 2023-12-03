import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indoor_localization_app/controller/data_controller.dart';
import 'package:indoor_localization_app/controller/permission_controller.dart';
import 'package:indoor_localization_app/routes.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize Logging
  await FlutterLogs.initLogs(
      logLevelsEnabled: [
        LogLevel.INFO,
        LogLevel.WARNING,
        LogLevel.ERROR,
        LogLevel.SEVERE
      ],
      timeStampFormat: TimeStampFormat.TIME_FORMAT_24_FULL,
      directoryStructure: DirectoryStructure.SINGLE_FILE_FOR_DAY,
      logTypesEnabled: ["test_point", "real_time"],
      logFileExtension: LogFileExtension.LOG,
      logsWriteDirectoryName: "MyLogs",
      logsExportDirectoryName: "Exported",
      debugFileOperations: true,
      isDebuggable: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indoor Localization App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Home'),
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PermissionController _permissionController;
  late DataController _dataController;
  late Future _future;

  @override
  void initState() {
    super.initState();
    _permissionController = PermissionController();
    _dataController = DataController();
    _future = init();
  }

  Future<void> init() async {
    await _permissionController.askForPermissions();
    await flutterBeacon.initializeAndCheckScanning;
    await _dataController.loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => _dataController),
        ChangeNotifierProvider(create: (context) => _permissionController),
      ],
      child: Consumer2<DataController, PermissionController>(
          builder: (context, dataController, permissionController, child) {
        return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError ||
                      (!permissionController.permissionsGranted)) {
                    return const Center(
                      child: Text(
                        'Kérjük engedélyezze a bluetooth és a helymeghatározás használatát az alkalmazás számára!',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (!permissionController.bluetoothEnabled) {
                    return const Center(
                      child: Text(
                        'Kérjük kapcsolja be a bluetooth-t!',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return SizedBox.expand(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              color: Theme.of(context).primaryColor,
                              child: TextButton(
                                child: const Text(
                                  'Térkép hozzáadása',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  try {
                                    _dataController.selectFile().then((value) {
                                      if (value != null) {
                                        _dataController
                                            .fileExists(
                                                value.path.split('/').last)
                                            .then((exists) {
                                          if (exists) {
                                            showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      //ask if user wants to overwrite the file
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Fájl felülírása'),
                                                        content: const Text(
                                                            'A fájl már létezik, felülírja?'),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context,
                                                                    false);
                                                              },
                                                              child: const Text(
                                                                'Mégse',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              )),
                                                          TextButton(
                                                              onPressed: () {
                                                                try {
                                                                  _dataController
                                                                      .saveFileToStorage(
                                                                          value)
                                                                      .then(
                                                                          (value) {
                                                                    _dataController
                                                                        .loadFiles();
                                                                  });
                                                                } catch (e) {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              'Hiba történt a fájl betöltése közben!');
                                                                }
                                                                Navigator.pop(
                                                                    context,
                                                                    true);
                                                              },
                                                              child: const Text(
                                                                'Igen',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green),
                                                              )),
                                                        ],
                                                      );
                                                    })
                                                .then((value) => value
                                                    ? _dataController
                                                        .saveFileToStorage(
                                                            value)
                                                    : null);
                                          } else {
                                            _dataController
                                                .saveFileToStorage(value);
                                          }
                                        });
                                      }
                                    });
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Hiba történt a fájl betöltése közben!');
                                  }
                                },
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          for (var map in dataController.files)
                            Container(
                                color: Theme.of(context).primaryColor,
                                child: TextButton(
                                  child: Text(
                                    map.path
                                        .split('/')
                                        .last
                                        .replaceAll('.json', ''),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/map',
                                        arguments: map.path);
                                  },
                                )),
                        ]),
                  );
                }));
      }),
    );
  }
}

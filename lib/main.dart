import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:indoor_localization_app/controller/beacon_controller.dart';
import 'package:indoor_localization_app/routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  late StreamSubscription bluetoothState;

  bool bluetoothEnabled = false;

  Future<bool> askForPermissions() async {
    PermissionStatus permissionStatus = await Permission.bluetooth.status;
    if (permissionStatus.isDenied) {
      await Permission.bluetooth.request();
    }

    permissionStatus = await Permission.bluetoothScan.status;

    if (permissionStatus.isDenied) {
      await Permission.bluetoothScan.request();
    }

    permissionStatus = await Permission.bluetoothConnect.status;

    if (permissionStatus.isDenied) {
      await Permission.bluetoothConnect.request();
    }

    permissionStatus = await Permission.location.status;

    if (permissionStatus.isDenied) {
      await Permission.location.request();
    }

    //check if bluetooth is enabled with FlutterBluePlus.adapterState

    bluetoothState = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        setState(() {
          bluetoothEnabled = false;
        });
      } else if (state == BluetoothAdapterState.on) {
        setState(() {
          bluetoothEnabled = true;
        });
      }
    });

    if (!await Permission.bluetooth.isGranted ||
        !await Permission.bluetoothScan.isGranted ||
        !await Permission.location.isGranted) {
      return false;
    }
    return true;
  }

  late Future _permissionFuture;
  late BeaconController _beaconController;
  late Future _beaconFuture;

  @override
  void initState() {
    super.initState();
    _permissionFuture = askForPermissions();
    _beaconController = BeaconController();

    _beaconFuture = _beaconController.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
            future: _permissionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError ||
                  (!snapshot.hasData && snapshot.data as bool == false)) {
                return const Center(
                  child: Text(
                    'Kérjük engedélyezze a bluetooth és a helymeghatározás használatát az alkalmazás számára!',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (!bluetoothEnabled) {
                return const Center(
                  child: Text(
                    'Kérjük kapcsolja be a bluetooth-ot!',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return FutureBuilder(
                  future: _beaconFuture,
                  builder: (context, future) {
                    return SizedBox.expand(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                color: Theme.of(context).primaryColor,
                                child: TextButton(
                                  child: const Text(
                                    'Térkép',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/map');
                                  },
                                )),
                          ]),
                    );
                  });
            }));
  }
}

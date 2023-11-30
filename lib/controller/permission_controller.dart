import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController extends ChangeNotifier {
  bool bluetoothEnabled = false;
  bool permissionsGranted = false;
  late StreamSubscription bluetoothState;

  Future askForPermissions() async {
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
        bluetoothEnabled = false;
      } else if (state == BluetoothAdapterState.on) {
        bluetoothEnabled = true;
      }
      notifyListeners();
    });

    if (!await Permission.bluetooth.isGranted ||
        !await Permission.bluetoothScan.isGranted ||
        !await Permission.location.isGranted) {
      permissionsGranted = false;
    } else {
      permissionsGranted = true;
    }
    notifyListeners();
  }
}

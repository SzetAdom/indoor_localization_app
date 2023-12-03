import 'package:flutter/material.dart';
import 'package:indoor_localization_app/controller/beacon_controller.dart';
import 'package:indoor_localization_app/controller/map_controller.dart';
import 'package:indoor_localization_app/controller/map_painter.dart';
import 'package:indoor_localization_app/pages/log_page.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController mapController;
  late BeaconController beaconController;

  late Future<bool> future;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    beaconController = BeaconController();
  }

  bool showLogPopUp = false;

  Future<void> init() async {
    await beaconController.init();
  }

  @override
  Widget build(BuildContext context) {
    if (mapController.map == null) {
      var args = ModalRoute.of(context)!.settings.arguments as String;
      future = mapController.loadMap(args);
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapController>(
          create: (context) => mapController,
        ),
        ChangeNotifierProvider(create: (context) => beaconController),
      ],
      child: Consumer2<MapController, BeaconController>(
          builder: (context, mapController, beaconController, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 10,
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      showLogPopUp = !showLogPopUp;
                    });
                  },
                  icon: const Icon(Icons.list))
            ],
          ),
          body: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (mapController.map == null) {
                    return const Text('Hiba történt betöltés közben');
                  }

                  return Stack(
                    children: [
                      MatrixGestureDetector(
                        onMatrixUpdate: (m, tm, sm, rm) {
                          mapController.onMatrixUpdate(m, tm, sm, rm);
                        },
                        child: Container(
                          color: Colors.blueGrey,
                          child: Column(
                            children: [
                              Expanded(
                                child: Transform(
                                  transform: mapController.matrix,
                                  child: Container(
                                    color: Colors.grey,
                                    child: LayoutBuilder(
                                        builder: (context, constrains) {
                                      return SizedBox(
                                        width: mapController.map!.width,
                                        height: mapController.map!.height,
                                        child: CustomPaint(
                                          painter: MapEditorPainter(
                                            map: mapController.map!,
                                            canvasOffset:
                                                mapController.canvasOffset,
                                            gridStep: mapController.gridStep,
                                            zoomLevel: mapController.zoomLevel,
                                            mapEditPointSize:
                                                mapController.mapEditPointSize,
                                            pointSize: mapController.pointSize,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (showLogPopUp)
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: const LogPage(),
                        )
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        );
      }),
    );
  }
}

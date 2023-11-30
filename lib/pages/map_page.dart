import 'package:flutter/material.dart';
import 'package:indoor_localization_app/controller/map_controller.dart';
import 'package:indoor_localization_app/controller/map_painter.dart';
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
  late MapController controller;

  late Future<bool> future;

  @override
  void initState() {
    super.initState();
    controller = MapController();
    future = controller.loadMap();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapController>(
      create: (context) => controller,
      child: Consumer<MapController>(builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 10,
          ),
          body: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (!snapshot.hasData ||
                      (snapshot.hasData && snapshot.data == false)) {
                    return const Text('Hiba történt betöltés közben');
                  }
                  return MatrixGestureDetector(
                    onMatrixUpdate: (m, tm, sm, rm) {
                      controller.onMatrixUpdate(m, tm, sm, rm);
                    },
                    child: Container(
                      color: Colors.blueGrey,
                      child: Column(
                        children: [
                          Expanded(
                            child: Transform(
                              transform: controller.matrix,
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                                color: Colors.grey,
                                child: ClipRect(
                                  clipBehavior: Clip.hardEdge,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: controller.map.width,
                                      maxHeight: controller.map.height,
                                    ),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: controller.map.width,
                                        minHeight: controller.map.height,
                                      ),
                                      child: LayoutBuilder(
                                          builder: (context, constrains) {
                                        controller.canvasSize =
                                            constrains.biggest;
                                        return CustomPaint(
                                          painter: MapEditorPainter(
                                            map: controller.map,
                                            canvasOffset:
                                                controller.canvasOffset,
                                            gridStep: controller.gridStep,
                                            zoomLevel: controller.zoomLevel,
                                            mapEditPointSize:
                                                controller.mapEditPointSize,
                                            pointSize: controller.pointSize,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

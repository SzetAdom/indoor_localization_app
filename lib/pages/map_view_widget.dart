import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class MapViewWidget extends StatefulWidget {
  const MapViewWidget(this.mapObjectsPositioned, {Key? key}) : super(key: key);

  // final List<MapObjecWidget> mapObjects;
  final List<Positioned> mapObjectsPositioned;

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  Matrix4 matrix = Matrix4.identity();
  ValueNotifier<int> notifier = ValueNotifier(0);

  Offset offset = const Offset(400, 400);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Listener(
            child: Container(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (ctx, constraints) {
                      return MatrixGestureDetector(
                        shouldRotate: false,
                        shouldScale: true,
                        shouldTranslate: true,
                        onMatrixUpdate: (m, tm, sm, rm) {
                          matrix = MatrixGestureDetector.compose(
                              matrix, tm, sm, null);

                          notifier.value++;
                        },
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.topLeft,
                          color: const Color(0xff444444),
                          child: AnimatedBuilder(
                            animation: notifier,
                            builder: (ctx, child) {
                              return Transform(
                                transform: matrix,
                                child: OverflowBox(
                                  minHeight: 0,
                                  minWidth: 0,
                                  maxHeight: double.infinity,
                                  maxWidth: double.infinity,
                                  child: Container(
                                    width: 800,
                                    height: 800,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Container(
                                      color: Colors.grey.shade200,
                                      child: GridPaper(
                                        color: Colors.black,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: widget.mapObjectsPositioned
                                              .map<Positioned>((element) {
                                            var newElement = Positioned(
                                              left: element.left! + offset.dx,
                                              top: element.top! + offset.dy,
                                              width: element.width,
                                              height: element.height,
                                              child: element.child,
                                            );
                                            return newElement;
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:indoor_localization_app/map_object/map_object_model.dart';

class MapObjecWidget extends StatelessWidget {
  const MapObjecWidget(this.mapObjectModel,
      {required this.child, this.withoutRotation = false, Key? key})
      : super(key: key);
  final bool withoutRotation;

  final MapObjectModel mapObjectModel;
  final Widget Function(Widget child) child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: Rect.fromCenter(
        center: Offset(mapObjectModel.data.x, mapObjectModel.data.y),
        width: mapObjectModel.data.width,
        height: mapObjectModel.data.height,
      ),
      child: Transform.rotate(
        angle: withoutRotation ? 0 : mapObjectModel.data.angleInRadiant,
        child: child.call(Container(
          color: withoutRotation ? Colors.red : mapObjectModel.color,
        )),
      ),
    );
  }
}

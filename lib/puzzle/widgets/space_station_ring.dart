import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import '../../models/app_state.dart';
import '../../models/ui_state.dart';

// TODO: replace with rive widget
class SpaceStationRing extends StatelessWidget {
  const SpaceStationRing({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Provider.of<UIState>(context, listen: true).stationDiameter.value,
      width: Provider.of<UIState>(context, listen: true).stationDiameter.value,
      child: Rive(
        artboard: Provider.of<AppState>(context, listen: true).ringArtboard!,
      ),

      // ClipPath(
      //   clipper: StationHoleClipper(
      //       stationDiameter: Provider.of<UIState>(context, listen: true).stationDiameter.value),
      //   child: Container(
      //     height: Provider.of<UIState>(context, listen: true).stationDiameter.value,
      //     width: Provider.of<UIState>(context, listen: true).stationDiameter.value,
      //     decoration: BoxDecoration(
      //       //gradient: LinearGradient(colors: [Colors.black, Colors.red, Colors.yellow]),
      //       color: Colors.grey[400],
      //       shape: BoxShape.circle,
      //     ),
      //   ),
      // ),
    );
  }
}

class StationHoleClipper extends CustomClipper<Path> {
  StationHoleClipper({required this.stationDiameter});

  final double stationDiameter;

  @override
  getClip(Size size) {
    Path path = Path();
    path.addOval(Rect.fromCircle(
      center: Offset(stationDiameter / 2, stationDiameter / 2),
      radius: stationDiameter / 2 - stationDiameter / 24,
    ));
    path.addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

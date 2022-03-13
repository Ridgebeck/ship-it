import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/ui_state.dart';

double _calcPlayAreaWidth(BoxConstraints constraints) {
  return max(
      min(
          min(constraints.maxWidth * kPlayAreaWidthFactor,
              constraints.maxHeight * kPlayAreaHeightFactor / kPlayAreaAspectRatio),
          kMaximumWidth),
      kMinimumWidth);
}

double _calcPlayAreaHeight(BoxConstraints constraints) {
  return max(
      min(
          min(constraints.maxWidth * kPlayAreaWidthFactor * kPlayAreaAspectRatio,
              constraints.maxHeight * kPlayAreaHeightFactor),
          kMaximumWidth * kPlayAreaAspectRatio),
      kMinimumWidth * kPlayAreaAspectRatio);
}

calculatePlayAreaDimensions(BuildContext context, BoxConstraints constraints) {
  // calculate play area width and height
  double playAreaWidth = _calcPlayAreaWidth(constraints);
  double playAreaHeight = _calcPlayAreaHeight(constraints);
  // calculate where there is more space for the menu buttons
  bool showMenuAtBottom =
      constraints.maxHeight - playAreaHeight > constraints.maxWidth - playAreaWidth;
  // define bottom menu height and side menu width
  double sideMenuPosition = constraints.maxWidth - ((constraints.maxWidth - playAreaWidth) / 2);
  double bottomMenuHeight = (constraints.maxHeight - playAreaHeight) / 2;
  double sideMenuWidth = min((constraints.maxWidth - playAreaWidth) / 2, playAreaWidth / 3);
  //calculate station diameter
  double stationDiameter = kStationDiameterFactor * playAreaWidth;

  // use future delayed to avoid error while building screen
  Future.delayed(Duration.zero, () async {
    // save width, height, station diameter in UI state
    Provider.of<UIState>(context, listen: false).playAreaWidth.value = playAreaWidth;
    Provider.of<UIState>(context, listen: false).playAreaHeight.value = playAreaHeight;
    Provider.of<UIState>(context, listen: false).stationDiameter.value = stationDiameter;
    Provider.of<UIState>(context, listen: false).sideMenuPosition.value = sideMenuPosition;
    Provider.of<UIState>(context, listen: false).bottomMenuHeight.value = bottomMenuHeight;
    Provider.of<UIState>(context, listen: false).sideMenuWidth.value = sideMenuWidth;
    Provider.of<UIState>(context, listen: false).showMenuAtBottom.value = showMenuAtBottom;
  });
}

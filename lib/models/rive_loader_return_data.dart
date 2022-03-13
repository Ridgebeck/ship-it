import 'package:rive/rive.dart';

class RiveLoaderReturnData {
  RiveLoaderReturnData({
    required this.artboard,
    this.doubleInputs = const [],
    this.boolInputs = const [],
    this.triggerInputs = const [],
    this.controller,
  });
  final Artboard artboard;
  final List<SMIInput<double>> doubleInputs;
  final List<SMIInput<bool>> boolInputs;
  final List<SMITrigger> triggerInputs;
  final StateMachineController? controller;
}

class ArtBoardAndInputs {
  ArtBoardAndInputs({
    required this.artboard,
    this.doubleInputs = const [],
    this.boolInputs = const [],
    this.controller,
  });
  final Artboard artboard;
  final List<SMIInput<double>> doubleInputs;
  final List<SMIInput<bool>> boolInputs;
  final StateMachineController? controller;
}

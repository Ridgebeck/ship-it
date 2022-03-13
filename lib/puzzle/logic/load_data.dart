import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:rive/src/rive_core/component.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ship_it/models/models.dart';

import '../../constants.dart';

class LoadData {
  /// start loading all rive assets
  loadAllRiveAssets({required BuildContext context}) {
    // callback function for state changes of logo animation
    void _onLogoStateChange(String stateMachineName, String stateName) {
      // notify when animation is in idle state
      if (stateName == "idle") {
        // todo: load sound
        Provider.of<AppState>(context, listen: false).loadBGMusic();
        Provider.of<AppState>(context, listen: false).introAnimationIsFinished = true;
      }
      // notify when animation is completely done
      if (stateName == "ExitState") {
        Provider.of<AppState>(context, listen: false).startMenuIsFinished = true;
      }
    }

    void _saveLogoInputAndArtBoard(List<RiveLoaderReturnData> loadedData) {
      // save ref to SMI input input in app state
      if (loadedData.first.boolInputs.isNotEmpty) {
        Provider.of<AppState>(context, listen: false).shouldFadeOut =
            loadedData.first.boolInputs.firstWhere((element) => element.name == "fadeOut");
      }
      // save logo art board in app state
      Provider.of<AppState>(context, listen: false).logoArtboard = loadedData.first.artboard;
    }

    void _saveBGInputAndArtBoard(List<RiveLoaderReturnData> loadedData) {
      // // save ref to SMI input input in app state
      // if (loadedData.boolInputs.isNotEmpty) {
      //   Provider.of<AppState>(context, listen: false).shouldFadeOut =
      //       loadedData.boolInputs.firstWhere((element) => element.name == "fadeOut");
      // }
      // save bg art board in app state
      Provider.of<AppState>(context, listen: false).bgArtboard = loadedData.first.artboard;
    }

    void _saveRingInputAndArtBoard(List<RiveLoaderReturnData> loadedData) {
      // save ref to SMI input in app state
      if (loadedData.first.boolInputs.isNotEmpty) {
        Provider.of<AppState>(context, listen: false).ringInput =
            loadedData.first.triggerInputs.firstWhere((element) => element.name == "ring input");
      }
      // save ring art board in app state
      Provider.of<AppState>(context, listen: false).ringArtboard = loadedData.first.artboard;
    }

    void _saveStationInputAndArtBoard(List<RiveLoaderReturnData> loadedData) {
      print("loaded station data length: ${loadedData.length}");
      // save ref to SMI input input in app state
      if (loadedData[1].boolInputs.isNotEmpty) {
        Provider.of<AppState>(context, listen: false).rocketIsStarting =
            loadedData[1].boolInputs.firstWhere((element) => element.name == "start");
      }

      // TODO: all versions for each of the 3 levels
      for (int boards = 0; boards < 1; boards++) {
        for (int i = 0; i < kSpaceStationVariants; i++) {
          // save the art boards in app state as a map with the numbers as keys
          Provider.of<AppState>(context, listen: false)
              .addStationArtboard(i, loadedData[i].artboard);
        }
      }
    }

    void _saveShipArtBoards(List<RiveLoaderReturnData> loadedData) {
      // go through list of return data
      for (RiveLoaderReturnData returnEntry in loadedData) {
        // get the art board for each entry
        Artboard ab = returnEntry.artboard;
        // check if the art board has a number in the name
        if (ab.name[0].contains(RegExp(r'[0-9]'))) {
          // extract number from art board name
          int size = int.parse(ab.name.replaceAll(new RegExp(r'[^0-9]'), ''));
          // save the art boards in app state as a map with the numbers as keys
          Provider.of<AppState>(context, listen: false).addShipArtboard(size, ab);
        }
      }
    }

    void _saveConnectorInputsAndArtBoards(List<RiveLoaderReturnData> loadedData) {
      Provider.of<AppState>(context, listen: false).addConnectors(loadedData);
      //Provider.of<AppState>(context, listen: false).resetAllIndicators();
    }

    void _saveIndicatorInputsAndArtBoards(List<RiveLoaderReturnData> loadedData) {
      Provider.of<AppState>(context, listen: false).addIndicators(loadedData);
      Provider.of<AppState>(context, listen: false).resetAllIndicators();
    }

    // start loading logo animation data
    _loadRiveData(
            fileName: "ship_it_font",
            stateMachineName: 'Fade State Machine',
            onStateChange: _onLogoStateChange)
        .then(_saveLogoInputAndArtBoard);

    // start loading bg animation data
    _loadRiveData(
      fileName: "background",
      stateMachineName: 'BG State Machine',
    ).then(_saveBGInputAndArtBoard);

    // start loading space ring data
    _loadRiveData(
      fileName: "space_ring",
      stateMachineName: 'Ring State Machine',
    ).then(_saveRingInputAndArtBoard);

    // start loading space station data
    _loadRiveData(
      fileName: "space_station",
      stateMachineName: 'Station State Machine',
      copies: kSpaceStationVariants,
      //onSameController: true,
    ).then(_saveStationInputAndArtBoard);

    // start loading ship animation data
    _loadRiveData(
      fileName: "ship",
    ).then(_saveShipArtBoards);

    // start loading connector data
    _loadRiveData(
      fileName: "connector",
      //stateMachineName: 'Indicator State Machine',
      copies: kRegularShipWidthDivider * kRowsPerLevel * kDisplayedLevels,
    ).then(_saveConnectorInputsAndArtBoards);

    // start loading indicator data
    _loadRiveData(
      fileName: "color_indicator",
      stateMachineName: 'Indicator State Machine',
      copies: kRegularShipWidthDivider * kRowsPerLevel * kDisplayedLevels,
    ).then(_saveIndicatorInputsAndArtBoards);
  }

  /// load data from local memory
  void sharedPrefInit(context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // look for saved app state
      String? name = prefs.getString("app-name");
      // look for saved level
      int? level = prefs.getInt("level");

      // set app name if it doesn't exist
      if (name == null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("app-name", "ship-it");
      }
      // check on last saved level
      if (level == null) {
        print("initializing level: 1");
        // initialize level 1
        Provider.of<AppState>(context, listen: false).initializeLevel(lvl: 1);
      } else {
        print("initializing level: $level");
        // initialize saved level
        Provider.of<AppState>(context, listen: false).initializeLevel(lvl: level);
      }
    } catch (err) {
      /// set app name variable
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("app-name", "ship-it");
    }
    // update state about local data
    Provider.of<AppState>(context, listen: false).localDataHasBeenLoaded = true;
  }

  /// load rive data and set up state machines, return art boards and inputs
  Future<List<RiveLoaderReturnData>> _loadRiveData({
    required String fileName,
    String? stateMachineName,
    Function(String, String)? onStateChange,
    int copies = 1,
    // TODO: ISSUE: same controller changes playback speed
    bool onSameController = false,
  }) async {
    List<RiveLoaderReturnData> returnData = [];
    // define possible inputs as return variables
    List<SMIInput<double>> doubleInputs = [];
    List<SMIInput<bool>> boolInputs = [];
    List<SMITrigger> triggerInputs = [];
    // state machine controller
    StateMachineController? controller;

    // load byte data
    ByteData data = await rootBundle.load('assets/rive/$fileName.riv');

    // import data as rive file
    final file = RiveFile.import(data);

    // create multiple copies if needed
    for (int i = 0; i < copies; i++) {
      // create instance of main art board for each copy
      final Artboard artboard = file.mainArtboard.instance();

      // check if loader should look for a state machine (name was given)
      if (stateMachineName != null) {
        if (!onSameController || i == 0) {
          // var
          controller = StateMachineController.fromArtboard(
            artboard,
            stateMachineName,
            onStateChange: onStateChange,
          );
        }
        if (controller != null) {
          artboard.addController(controller);
          doubleInputs = controller.inputs.whereType<SMIInput<double>>().toList();
          boolInputs = controller.inputs.whereType<SMIInput<bool>>().toList();
          triggerInputs = controller.inputs.whereType<SMITrigger>().toList();
        }
      }
      returnData.add(RiveLoaderReturnData(
        artboard: artboard,
        doubleInputs: doubleInputs,
        boolInputs: boolInputs,
        triggerInputs: triggerInputs,
      ));
    }

    // add all other other art boards to return data
    for (Artboard ab in file.artboards) {
      if (ab != file.mainArtboard) {
        returnData.add(RiveLoaderReturnData(
          artboard: ab,
        ));
      }
    }

    return returnData;
  }
}

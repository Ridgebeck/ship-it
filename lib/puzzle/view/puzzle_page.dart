import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:ship_it/colors/colors.dart';
import 'package:ship_it/levels/levels.dart';
import 'package:ship_it/models/models.dart';
import 'package:ship_it/puzzle/puzzle_state.dart';
import 'package:ship_it/puzzle/widgets/end_dialog.dart';
import 'package:ship_it/puzzle/widgets/rating_dialog.dart';
import 'package:provider/provider.dart';
import 'package:ship_it/constants.dart';
import 'package:ship_it/theme/basic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ship_it/theme/puzzle_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/continue_dialog.dart';
import '../widgets/start_dialog.dart';

//TODO: CHANGE GLOBAL VARIABLE
Artboard? artboard;
Artboard? artboardConnector;
Artboard? artboardBackground;
Artboard? colorIndicator;

Map<int, Artboard> shipArtboards = {};
Map<String, Artboard> shipEnds = {};

void sharedPrefInit(context) async {
  try {
    /// Checks if shared preference exist
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // look for saved app state
    String? name = prefs.getString("app-name");
    // look for saved level
    int? level = prefs.getInt("level");

    if (name == null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("app-name", "ship-it");
      Future.delayed(Duration.zero, () {
        return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const AlertDialog(
              backgroundColor: Colors.black,
              content: StartDialog(),
            );
          },
        );
      });
    } else if (level != null) {
      Future.delayed(Duration.zero, () {
        return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              content: ContinueDialog(levelLeftOff: level),
            );
          },
        );
      });
    }
  } catch (err) {
    /// set app name variable
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("app-name", "ship-it");
  }
}

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({Key? key}) : super(key: key);

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> with TickerProviderStateMixin {
  late Animation<double> rotateAnimation;
  late AnimationController rotateController;

  // todo: test variable --> need triggers for each rive widget
  SMITrigger? trigger;
  RiveAnimationController? riveController;

  @override
  void initState() {
    super.initState();
    Provider.of<AppState>(context, listen: false).initializeLevel(lvl: 1);

    /// check if there was a saved level
    sharedPrefInit(context);

    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    rotateAnimation = Tween<double>(begin: 0.0, end: kAngularOffset)
        .animate(CurvedAnimation(parent: rotateController, curve: Curves.easeInOut))
      ..addListener(() {
        //print(rotateAnimation.value);
        Provider.of<AppState>(context, listen: false).rotationAngle = rotateAnimation.value;
        setState(() {});
      })
      ..addStatusListener((status) {
        //print(status);
        // if (status == AnimationStatus.forward) {
        //   //isRotating = true;
        // }

        if (status == AnimationStatus.completed) {
          // otherwise move to next level
          rotateController.reset();
          // go to next level
          print("moving to next level");
          Provider.of<AppState>(context, listen: false).moveToNextLevel();
        }
      });

    loadRiveData();
  }

  void loadRiveData() async {
    // TODO: MOVE TO SEPARATE LOADER
    await rootBundle.load('/rive/space_dock.riv').then((data) {
      final file = RiveFile.import(data);
      setState(() {
        artboard = file.mainArtboard;
      });
    });

    void _onStateChanged(String stateMachineName, String stateName) {
      print("State of State Machine $stateMachineName changed to $stateName!");
    }

    // TODO: MOVE TO SEPARATE LOADER
    await rootBundle.load('/rive/color_indicator.riv').then((data) async {
      // load rive file from binary data
      final file = RiveFile.import(data);
      // get main art board
      Artboard _artboard = file.mainArtboard;
      // get state machine controller from art board
      final controller = StateMachineController.fromArtboard(file.mainArtboard, "State Machine 1",
          onStateChange: _onStateChanged);
      //file.mainArtboard.addController(riveController!);
      // add controller to art board
      _artboard.addController(controller!);
      // get trigger
      trigger = controller.findInput<bool>('Package') as SMITrigger;
      setState(() {
        colorIndicator = _artboard; //file.mainArtboard;
      });
    });
    // TODO: MOVE TO SEPARATE LOADER
    await rootBundle.load('/rive/connector.riv').then((data) {
      final file = RiveFile.import(data);
      setState(() {
        artboardConnector = file.mainArtboard;
      });
    });
    // TODO: MOVE TO SEPARATE LOADER
    await rootBundle.load('/rive/ship.riv').then((data) {
      final file = RiveFile.import(data);

      for (Artboard ab in file.artboards) {
        //print(ab.name);
        // print(ab.name[0]);
        if (ab.name[0].contains(RegExp(r'[0-9]'))) {
          shipArtboards[int.parse(ab.name[0])] = ab;
        } else {
          shipEnds[ab.name] = ab;
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    rotateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: change to individual triggers
    if (Provider.of<AppState>(context, listen: true).currentPuzzleState.numberOfMoves > 1) {
      trigger?.value = true;
    }
    if (Provider.of<AppState>(context, listen: true).currentPuzzleState.numberOfMoves > 2) {
      trigger?.value = false;
    }

    // detect if puzzle has been completed
    if (Provider.of<AppState>(context, listen: true).currentStatus == PuzzleStatus.complete) {
      // calculate time difference
      int secondsForLvl = DateTime.now()
          .difference(Provider.of<AppState>(context, listen: false).startTime)
          .inSeconds;
      // save data in Firestore
      FirebaseFirestore.instance.collection("testStats").add({
        "UID": FirebaseAuth.instance.currentUser!.uid,
        "level": Provider.of<AppState>(context, listen: false).currentLevel,
        "moves": Provider.of<AppState>(context, listen: false).currentMoves,
        "resets": Provider.of<AppState>(context, listen: false).currentResets,
        "secondsNeeded": secondsForLvl,
        "timeStamp": DateTime.now(),
      });

      Future.delayed(Duration.zero, () {
        int nextLvl = Provider.of<AppState>(context, listen: false).currentLevel + 1;
        // check if there are any levels left
        if (nextLvl + 1 >= levels.length) {
          return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: EndDialog(),
              );
            },
          );
        }
        // show message every 3 levels
        if (Provider.of<AppState>(context, listen: false).currentLevel % 3 == 0) {
          return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: RatingDialog(),
              );
            },
          ).then((value) {
            Provider.of<AppState>(context, listen: false).puzzleStatus = PuzzleStatus.inactive;
            // rotate to new puzzle
            rotateController.forward();
          });
        } else {
          Provider.of<AppState>(context, listen: false).puzzleStatus = PuzzleStatus.inactive;
          // rotate to new puzzle
          rotateController.forward();
        }
      });
    }

    const theme = BasicTheme();
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: LayoutBuilder(builder: (context, constraints) {
        // calculate play area width and height
        double playAreaWidth = _calcPlayAreaWidth(constraints);
        double playAreaHeight = _calcPlayAreaHeight(constraints);
        // calculate where there is more space for the menu buttons
        bool showMenuAtBottom =
            constraints.maxHeight - playAreaHeight > constraints.maxWidth - playAreaWidth;
        // define bottom menu height and side menu width
        double sideMenuPosition =
            constraints.maxWidth - ((constraints.maxWidth - playAreaWidth) / 2);
        double bottomMenuHeight = (constraints.maxHeight - playAreaHeight) / 2;
        double sideMenuWidth = min((constraints.maxWidth - playAreaWidth) / 2, playAreaWidth / 3);
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/basic_art_style.PNG"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // build background based on screen size and app state
            //theme.layoutDelegate.backgroundBuilder(),
            SingleChildScrollView(
              // extend screen to full size (scaffold issue)
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  minWidth: constraints.maxWidth,
                ),
                child: Center(
                  child: PlayArea(
                    playAreaWidth: playAreaWidth,
                    playAreaHeight: playAreaHeight,
                    showMenuAtBottom: showMenuAtBottom,
                  ),
                ),
              ),
            ),
            // don't show menu when screen is smaller than minimum size
            constraints.maxWidth <= kMinimumWidth ||
                    constraints.maxHeight <= kMinimumWidth * kPlayAreaAspectRatio
                ? Container()
                : showMenuAtBottom
                    ? Positioned(
                        bottom: 0,
                        width: constraints.maxWidth,
                        height: bottomMenuHeight,
                        child: BottomMenu(playAreaWidth: playAreaWidth),
                      )
                    : Positioned(
                        right: sideMenuPosition,
                        width: sideMenuWidth,
                        height: constraints.maxHeight,
                        child: SideMenu(playAreaWidth: playAreaWidth),
                      ),
          ],
        );
      }),
    );
  }
}

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

class PlayArea extends StatelessWidget {
  const PlayArea({
    Key? key,
    required this.playAreaWidth,
    required this.playAreaHeight,
    required this.showMenuAtBottom,
  }) : super(key: key);

  final double playAreaWidth;
  final double playAreaHeight;
  final bool showMenuAtBottom;

  @override
  Widget build(BuildContext context) {
    // TODO: change theme?
    final theme = const BasicTheme();

    double stationDiameter = kStationDiameterFactor * playAreaWidth;

    return Transform(
      // TODO: rotate all levels and station at the same time when level changes
      transform:
          Matrix4.rotationZ(Provider.of<AppState>(context, listen: true).rotationAngle * pi / 180),
      origin: Offset(stationDiameter / 2, 0),
      alignment: FractionalOffset.centerRight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: showMenuAtBottom ? Alignment.centerLeft : Alignment.center,
        children: [
          // todo: get levels from app state
          RotatedPuzzle(
            level: Provider.of<AppState>(context, listen: true).previousPuzzleState.level,
            playAreaHeight: playAreaHeight,
            playAreaWidth: playAreaWidth,
            stationDiameter: stationDiameter,
            rotationAngle: kAngularOffset,
          ),
          RotatedPuzzle(
            level: Provider.of<AppState>(context, listen: true).currentPuzzleState.level,
            playAreaHeight: playAreaHeight,
            playAreaWidth: playAreaWidth,
            stationDiameter: stationDiameter,
            rotationAngle: 0.0,
          ),
          RotatedPuzzle(
            level: Provider.of<AppState>(context, listen: true).nextPuzzleState.level,
            playAreaHeight: playAreaHeight,
            playAreaWidth: playAreaWidth,
            stationDiameter: stationDiameter,
            rotationAngle: -kAngularOffset,
          ),
          Positioned(
            left: playAreaWidth,
            child: SpaceStation(stationDiameter: stationDiameter),
          ),
        ],
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
    required this.playAreaWidth,
  }) : super(key: key);

  final double playAreaWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container()),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RestartButton(),
              SizedBox(height: playAreaWidth / 10),
              const MoveBackButton(),
              //SizedBox(height: playAreaWidth / 10),
              //const SettingsButton(),
            ],
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }
}

class BottomMenu extends StatelessWidget {
  const BottomMenu({
    Key? key,
    required this.playAreaWidth,
  }) : super(key: key);

  final double playAreaWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 3, child: Container()),
        Expanded(
          flex: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RestartButton(),
              SizedBox(width: playAreaWidth / 10),
              const MoveBackButton(),
              //SizedBox(width: playAreaWidth / 10),
              //const SettingsButton(),
            ],
          ),
        ),
        Expanded(flex: 2, child: Container()),
      ],
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Future.delayed(Duration.zero, () {
          return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: EndDialog(),
              );
            },
          );
        });
      },
      child: Text("set"),
    );
  }
}

class RestartButton extends StatelessWidget {
  const RestartButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        print("restarting");
        Provider.of<AppState>(context, listen: false).restart();
      },
      child: const Icon(Icons.repeat),
    );
  }
}

class MoveBackButton extends StatelessWidget {
  const MoveBackButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        print("move back button pressed");
        Provider.of<AppState>(context, listen: false).oneMoveBack();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FittedBox(
            child: Icon(
              Icons.arrow_back_ios,
              size: 20.0,
            ),
          ),
          Text(Provider.of<AppState>(context, listen: true)
              .currentPuzzleState
              .goBackAttempts
              .toString()),
        ],
      ),
    );
  }
}

class RotatedPuzzle extends StatelessWidget {
  // TODO: store play area dimensions, station diameter in app state?
  const RotatedPuzzle({
    Key? key,
    required this.level,
    required this.playAreaWidth,
    required this.playAreaHeight,
    required this.stationDiameter,
    required this.rotationAngle,
  }) : super(key: key);

  final Level level;
  final double playAreaWidth;
  final double playAreaHeight;
  final double stationDiameter;
  final double rotationAngle;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.rotationZ(rotationAngle * pi / 180),
      origin: Offset(stationDiameter / 2, 0),
      alignment: FractionalOffset.centerRight,
      child: SizedBox(
        width: playAreaWidth,
        height: playAreaHeight,
        child: Puzzle(
          playAreaWidth: playAreaWidth,
          level: level,
        ),
      ),
    );
  }
}

class Puzzle extends StatelessWidget {
  const Puzzle({
    Key? key,
    required this.playAreaWidth,
    required this.level,
  }) : super(key: key);

  final double playAreaWidth;
  final Level level;

  @override
  Widget build(BuildContext context) {
    double normalShipWidth = playAreaWidth / kRegularShipWidthDivider;

    List<DockingSpace> dockingSpaces = List.generate(
      level.blueprints.length,
      (index) {
        return DockingSpace(
          width: normalShipWidth,
          blueprint: level.blueprints[index],
          position: index,
          isTopRow: index < (level.blueprints.length / 2).round(),
        );

        // level.blueprints[index].isWarehouse
        //   ? DockingSpace(
        //       width: normalShipWidth,
        //       blueprint: level.blueprints[index],
        //       position: index,
        //     )
        //   : DockingSpace(
        //       width: normalShipWidth,
        //       blueprint: level.blueprints[index],
        //       position: index,
        //     );
      },
    );

    int firstRowItems = (level.blueprints.length / 2).round();

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                //color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: dockingSpaces.sublist(0, firstRowItems).toList(),
                ),
              ),
            ),
            Expanded(flex: 1, child: Container()),
            Expanded(
              flex: 4,
              child: Container(
                //color: Colors.green,
                child: Transform.rotate(
                  angle: pi * 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: dockingSpaces.sublist(firstRowItems).reversed.toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
        IgnorePointer(
          child: SpaceDock(playAreaWidth: playAreaWidth),
        ),
      ],
    );
  }
}

class SpaceDock extends StatelessWidget {
  const SpaceDock({
    Key? key,
    required this.playAreaWidth,
  }) : super(key: key);

  final double playAreaWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        artboard != null
            ? Rive(
                artboard: artboard!,
                useArtboardSize: false,
              )
            : Container(),
        // level number
        Positioned(
          left: playAreaWidth * 0.075,
          width: playAreaWidth * 0.10,
          height: playAreaWidth * 0.10,
          child: FittedBox(
            child: Text(
              "${Provider.of<AppState>(context, listen: true).currentLevel}",
              style: GoogleFonts.orbitron(
                fontSize: 100,
                color: Colors.deepPurple[800],
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
          ),
        ),
        // moves counter
        Positioned(
          right: playAreaWidth * 0.075,
          width: playAreaWidth * 0.15,
          height: playAreaWidth * 0.07,
          child: FittedBox(
            child: Text(
              "${Provider.of<AppState>(context, listen: true).currentPuzzleState.numberOfMoves}",
              style: GoogleFonts.orbitron(
                fontSize: 100,
                color: Colors.lightBlueAccent,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class DockingSpace extends StatelessWidget {
  const DockingSpace({
    Key? key,
    required this.width,
    required this.position,
    required this.blueprint,
    required this.isTopRow,
  }) : super(key: key);

  final double width;
  final int position;
  final Blueprint blueprint;
  final bool isTopRow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("tapped");

        Provider.of<AppState>(context, listen: false).clickOnPosition(position);
      },
      child: ShipTugboatAndConnection(
        shipWidth: width,
        blueprint: blueprint,
        isTopRow: isTopRow,
        isWarehouse: blueprint.isWarehouse,
      ),

      // blueprint.isWarehouse
      //     ? WarehouseAndConnection(
      //         width: width,
      //         blueprint: blueprint,
      //         isTopRow: isTopRow,
      //       )
      //     : ShipTugboatAndConnection(
      //         shipWidth: width,
      //         blueprint: blueprint,
      //         isTopRow: isTopRow,
      //   isWarehouse: blueprint.isWarehouse,
      //       ),
    );
  }
}

class WarehouseAndConnection extends StatelessWidget {
  const WarehouseAndConnection({
    Key? key,
    required this.width,
    required this.blueprint,
    required this.isTopRow,
  }) : super(key: key);

  final double width;
  final Blueprint blueprint;
  final bool isTopRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        WarehouseWidget(
          width: width,
          blueprint: blueprint,
        ),
        // todo: create connection widget
        SizedBox(
          height: width / 4,
          width: width / 2,
          //color: Colors.grey[400],
        ),
      ],
    );
  }
}

class ShipTugboatAndConnection extends StatelessWidget {
  const ShipTugboatAndConnection({
    Key? key,
    required this.shipWidth,
    required this.blueprint,
    required this.isTopRow,
    required this.isWarehouse,
  }) : super(key: key);

  final double shipWidth;
  final Blueprint blueprint;
  final bool isTopRow;
  final bool isWarehouse;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Provider.of<AppState>(context, listen: true).currentPuzzleState.level.isRotatingMode
        //     ?
        // todo: create tug boat widget
        // SizedBox(
        //   width: shipWidth,
        //   height: shipWidth,
        //   child: Container(
        //     decoration: const BoxDecoration(
        //       shape: BoxShape.circle,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
        // : Container(),

        ShipWidget(
          shipWidth: shipWidth,
          blueprint: blueprint,
          isTopRow: isTopRow,
          isWarehouse: isWarehouse,
        ),
        // todo: design and animate docking mechanism
        SizedBox(
          height: shipWidth / 4,
          width: shipWidth / 2,
          //color: Colors.grey[400],
        ),
      ],
    );
  }
}

// List<Widget> _createEmptySpaces({
//   required int number,
//   required double contentWidth,
//   required bool withOtherContents,
//   isWarehouse = false,
//   isHazardMode = false,
// }) {
//   return List.generate(
//     number,
//     (index) => Column(
//       children: [
//         withOtherContents && index == 0
//             ? SizedBox(
//                 height: kConnectorRatio * contentWidth,
//               )
//             : Container(),
//         Container(
//           width: contentWidth,
//           height: contentWidth,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[600]!),
//             //color: Colors.grey[600],
//           ),
//           child: isWarehouse && isHazardMode
//               ? FittedBox(
//                   child: Icon(
//                     Icons.no_cell_outlined,
//                     color: Colors.grey[800],
//                   ),
//                 )
//               : null,
//         ),
//         index != number - 1
//             ? SizedBox(
//                 height: kSmallGapRatio * contentWidth,
//               )
//             : Container(),
//       ],
//     ),
//   );
// }

class WarehouseWidget extends StatelessWidget {
  const WarehouseWidget({
    Key? key,
    required this.width,
    required this.blueprint,
  }) : super(key: key);

  final double width;
  final Blueprint blueprint;

  @override
  Widget build(BuildContext context) {
    double contentWidth = width * kContentWidthFactor;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Positioned(
        //   top: width * 4.6 * 0.98,
        //   left: (width - width * 0.4) / 2,
        //   child: Container(
        //     color: Colors.green,
        //     height: width,
        //     width: width * 0.4,
        //   ),
        // ),
        Container(
          height: 2 * width * kConnectorRatio +
              blueprint.size * width * kContentWidthFactor +
              (blueprint.size - 1) * width * kSmallGapRatio,

          // width *
          //     (kMaxNumberOfContents * kContentWidthFactor +
          //         (kMaxNumberOfContents - 1) * kSmallGapRatio +
          //         2 * kConnectorRatio),
          width: width,
          color: blueprint.isSelected ? PuzzleColors.selectedColor : Colors.grey[700],
          child: Column(
            children: [
              // SizedBox(
              //   height: width *
              //       (kConnectorRatio +
              //           (kMaxNumberOfContents - blueprint.size) *
              //               (kSmallGapRatio + kContentWidthFactor)),
              //   //(kContentWidthFactor + kContentWidthFactor * kConnectorRatio) *
              //   //(kMaxNumberOfContents - blueprint.size),
              // ),
              SizedBox(height: width * kConnectorRatio),
              ..._createContentWidgets(
                contents: blueprint.containerContents,
                contentWidth: contentWidth,
                shipWidth: width,
                shipSize: blueprint.size,
                theme: Provider.of<AppState>(context, listen: true).puzzleTheme,
              ),
              // ..._createEmptySpaces(
              //   number: blueprint.size - blueprint.containerContents.length,
              //   contentWidth: contentWidth,
              //   withOtherContents: blueprint.containerContents.isNotEmpty,
              //   isWarehouse: true,
              //   isHazardMode: levels[Provider.of<AppState>(context).currentLevel].isHazardMode,
              // ),
              SizedBox(height: width * kConnectorRatio),
            ],
          ),
        ),
      ],
    );
  }
}

class ShipWidget extends StatelessWidget {
  const ShipWidget({
    Key? key,
    required this.shipWidth,
    required this.blueprint,
    required this.isTopRow,
    required this.isWarehouse,
  }) : super(key: key);

  final double shipWidth;
  final Blueprint blueprint;
  final bool isTopRow;
  final bool isWarehouse;

  @override
  Widget build(BuildContext context) {
    double contentWidth = shipWidth * kContentWidthFactor;
    double smallGap = shipWidth * kSmallGapRatio;
    double regularGap = shipWidth * kRegularGapRatio;
    double gapBetweenContainers = shipWidth * kGapBetweenContainerRatio;

    List<Widget> contentWidgetList = _createContentWidgets(
      contents: blueprint.containerContents,
      contentWidth: contentWidth,
      shipWidth: shipWidth,
      shipSize: blueprint.size,
      theme: Provider.of<AppState>(context, listen: true).puzzleTheme,
    );

    double shipHeight = blueprint.size * contentWidth +
        blueprint.size ~/ 2 * regularGap +
        (blueprint.size - 1) ~/ 2 * (gapBetweenContainers + 2 * smallGap) +
        2 * smallGap;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // connector to station
        Positioned(
          top: shipHeight * 0.98,
          left: (shipWidth - shipWidth * 0.4) / 2,
          child: Container(
            //color: Colors.green,
            height: shipWidth,
            width: shipWidth * 0.4,
            child: artboardConnector != null
                ? Rive(
                    artboard: artboardConnector!,
                    useArtboardSize: false,
                  )
                : Container(),
          ),
        ),
        // color/done indicator
        Positioned(
          bottom: shipHeight + shipWidth * 0.1,
          left: (shipWidth - shipWidth * 0.8) / 2,
          child: SizedBox(
            width: shipWidth * 0.8,
            height: shipWidth * 0.45,
            // TODO: add rive animation
            child: colorIndicator != null && !blueprint.isWarehouse
                ? Stack(
                    children: [
                      Center(
                        child: Container(
                          height: shipWidth * 0.4,
                          width: shipWidth * 0.7,
                          color: theme.colorPalette[blueprint.shipColorNumber!],
                        ),
                      ),
                      Transform.rotate(
                        angle: isTopRow ? 0.0 : 180 * pi / 180,
                        child: Rive(
                          artboard: colorIndicator!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  )
                : Container(),
          ),
        ),
        // shadow
        Positioned(
          top: 0.0, //0.8 * shipWidth,
          child: SizedBox(
            width: shipWidth,
            height: shipHeight, // - 0.8 * shipWidth,
            child: FractionallySizedBox(
              widthFactor: 0.8 * 0.9, //0.9,
              heightFactor: 1.0, //0.9,
              child: Container(
                decoration: BoxDecoration(
                  //color: theme.emptyVesselColor,
                  boxShadow: blueprint.isSelected
                      ? [
                          BoxShadow(
                            color: theme.glowColor,
                            // color: isWarehouse
                            //     ? Colors.white
                            //     : theme.colorPalette[Provider.of<AppState>(context)
                            //         .selectedContent!
                            //         .colorNoOfSelection!],
                            //theme
                            // .colorPalette[blueprint
                            // .shipColorNumber!],
                            blurRadius: 12.0,
                            spreadRadius: 1.0,
                          )
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
        // contents
        SizedBox(
          width: shipWidth,
          height: shipHeight,
          child: Column(
            children: [
              // first distance
              SizedBox(
                height: smallGap,
              ),
              ...contentWidgetList,
              SizedBox(
                height: smallGap,
              ),
            ],
          ),
        ),
        shipArtboards[2] == null ||
                shipArtboards[3] == null ||
                shipArtboards[4] == null ||
                shipArtboards[5] == null ||
                shipArtboards[6] == null
            ? Container()
            : isTopRow
                ? SizedBox(
                    width: shipWidth,
                    height: shipHeight,
                    child: Rive(artboard: shipArtboards[blueprint.size]!),
                  )
                : SizedBox(
                    width: shipWidth,
                    height: shipHeight,
                    child: Rive(artboard: shipArtboards[blueprint.size]!),
                  ),
      ],
    );
  }
}

List<Widget> _createContentWidgets({
  required List<ContainerContent> contents,
  required double contentWidth,
  required double shipWidth,
  required int shipSize,
  required PuzzleTheme theme,
}) {
  return List.generate(
    shipSize,
    //contents.length,
    // todo: make own ContainerWidget with styling / animation
    (index) => Column(
      children: [
        index < contents.length
            ? Container(
                color: theme.colorPalette[contents[index].colorNumber],
                width: contentWidth,
                height: contentWidth,
                child: contents[index].isHazardous
                    ? FittedBox(
                        child: Icon(
                          Icons.smartphone,
                          color: Colors.grey[800],
                        ),
                      )
                    : null,
              )
            : Container(
                color: theme.emptyVesselColor,
                width: contentWidth,
                height: contentWidth,
              ),
        //index != contents.length - 1
        index != shipSize - 1
            ? index % 2 == 0
                ? SizedBox(
                    height: kRegularGapRatio * shipWidth,
                    //color: PuzzleColors.white,
                    child: index + 1 < contents.length
                        ? Center(
                            child: Container(
                              width: shipWidth * 0.2,
                              color: contents[index].colorNumber == contents[index + 1].colorNumber
                                  ? theme.colorPalette[contents[index].colorNumber]
                                  : theme.emptyVesselColor,
                            ),
                          )
                        : Container(
                            width: shipWidth * 0.2,
                            color: theme.emptyVesselColor,
                          ),
                  )
                : SizedBox(
                    height: (kGapBetweenContainerRatio + 2 * kSmallGapRatio) * shipWidth,
                    child: index + 1 < contents.length
                        ? Center(
                            child: Container(
                              width: shipWidth * 0.2,
                              color: contents[index].colorNumber == contents[index + 1].colorNumber
                                  ? theme.colorPalette[contents[index].colorNumber]
                                  : theme.emptyVesselColor,
                            ),
                          )
                        : Container(
                            width: shipWidth * 0.2,
                            color: theme.emptyVesselColor,
                          ),
                  )
            : Container(),
      ],
    ),
  );
}

class SpaceStation extends StatelessWidget {
  const SpaceStation({
    Key? key,
    required this.stationDiameter,
  }) : super(key: key);

  final double stationDiameter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: stationDiameter,
      width: stationDiameter,
      child: ClipPath(
        clipper: StationHoleClipper(stationDiameter: stationDiameter),
        child: Container(
          height: stationDiameter,
          width: stationDiameter,
          decoration: BoxDecoration(
            //gradient: LinearGradient(colors: [Colors.black, Colors.red, Colors.yellow]),
            color: Colors.grey[400],
            shape: BoxShape.circle,
          ),
        ),
      ),
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

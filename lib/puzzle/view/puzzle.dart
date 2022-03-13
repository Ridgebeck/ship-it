import 'dart:html';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:ship_it/models/blueprint.dart';
import 'package:ship_it/models/ui_state.dart';
import 'package:ship_it/puzzle/puzzle_state.dart';
import 'package:ship_it/theme/basic_theme.dart';
import '../../constants.dart';
import '../../levels/levels.dart';
import '../../models/app_state.dart';
import '../../models/level.dart';
import '../../theme/puzzle_theme.dart';
import '../logic/calculate_dimensions.dart';
import '../widgets/bottom_menu.dart';
import '../widgets/end_dialog.dart';
import '../widgets/side_menu.dart';
import '../widgets/space_station_ring.dart';

class MenuAndGameLayout extends StatelessWidget {
  const MenuAndGameLayout({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // detect if puzzle has been completed
    if (Provider.of<AppState>(context, listen: true).currentStatus == PuzzleStatus.complete) {
      Future.delayed(Duration.zero, () {
        int nextLvl = Provider.of<AppState>(context, listen: false).currentLevelId + 1;
        // check if there are any levels left
        if (nextLvl + 1 >= levels.length) {
          return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.grey[900],
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                content: const EndDialog(), //MenuDialog(),
              );
            },
          );
        }
      });
    }

    return LayoutBuilder(builder: (context, constraints) {
      // calculate important UI dimensions and save in UI state
      calculatePlayAreaDimensions(context, constraints);

      return Stack(
        children: [
          SingleChildScrollView(
            // extend screen to full size (scaffold issue)
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: const Center(
                child: PlayArea(),
              ),
            ),
          ),
          // don't show menu when screen is smaller than minimum size
          constraints.maxWidth <= kMinimumWidth ||
                  constraints.maxHeight <= kMinimumWidth * kPlayAreaAspectRatio
              ? Container()
              : Provider.of<UIState>(context, listen: true).showMenuAtBottom.value
                  ? Positioned(
                      bottom: 0,
                      width: constraints.maxWidth,
                      height: Provider.of<UIState>(context, listen: true).bottomMenuHeight.value,
                      child: BottomMenu(
                          playAreaWidth:
                              Provider.of<UIState>(context, listen: true).playAreaWidth.value),
                    )
                  : Positioned(
                      right: Provider.of<UIState>(context, listen: true).sideMenuPosition.value,
                      width: Provider.of<UIState>(context, listen: true).sideMenuWidth.value,
                      height: constraints.maxHeight,
                      child: SideMenu(
                          playAreaWidth:
                              Provider.of<UIState>(context, listen: true).playAreaWidth.value),
                    ),
        ],
      );
    });
  }
}

class PlayArea extends StatefulWidget {
  const PlayArea({
    Key? key,
  }) : super(key: key);

  @override
  State<PlayArea> createState() => _PlayAreaState();
}

class _PlayAreaState extends State<PlayArea> with TickerProviderStateMixin {
  late Animation<double> rotateAnimation;
  late AnimationController rotateController;

  @override
  void initState() {
    super.initState();

    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kMillisecondsToRotate),
    );
    rotateAnimation = Tween<double>(begin: 0.0, end: kAngularOffset)
        .animate(CurvedAnimation(parent: rotateController, curve: Curves.easeInOutCubic))
      ..addListener(() {
        //print(rotateAnimation.value);
        Provider.of<AppState>(context, listen: false).rotationAngle = rotateAnimation.value;
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // otherwise move to next level
          rotateController.reset();
          // go to next level
          print("moving to next level");
          Provider.of<AppState>(context, listen: false).moveToNextLevel();
        }
      });

    // TODO: only for test --> remove
    // rotate to new puzzle
    //rotateController.forward();
    Future.delayed(Duration.zero, () async {
      Provider.of<AppState>(context, listen: false).translateIntoView = true;
    });
    // TODO: try zoom
  }

  @override
  void dispose() {
    super.dispose();
    rotateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 2500),
      curve: Curves.easeOut,
      transform: Matrix4.identity()
        ..translate(
          Provider.of<AppState>(context, listen: true).translateIntoView
              ? 0.0
              : MediaQuery.of(context).size.width,
        ),

      //transformAlignment: FractionalOffset.centerRight,
      onEnd: () {
        print("incoming transform done");
      },
      child: Transform(
        // rotate all levels and station at the same time when level changes
        transform: Matrix4.rotationZ(
            Provider.of<AppState>(context, listen: true).rotationAngle * pi / 180),
        origin: Offset(Provider.of<UIState>(context, listen: true).stationDiameter.value / 2, 0),
        alignment: FractionalOffset.centerRight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Provider.of<UIState>(context, listen: true).showMenuAtBottom.value
              ? Alignment.centerLeft
              : Alignment.center,
          children: [
            RotatedPuzzle(
              rotationAngle: kAngularOffset,
              level: Provider.of<AppState>(context, listen: true).previousLevel,
            ),
            // TODO: stagger animations, set to screen width, modify duration
            AnimatedContainer(
              duration: const Duration(milliseconds: 2500),
              curve: Curves.easeInQuart,
              transform: Matrix4.identity()
                ..translate(
                    Provider.of<AppState>(context, listen: true).currentPuzzleState.puzzleStatus ==
                                PuzzleStatus.complete &&
                            rotateAnimation.value < 8
                        ? -MediaQuery.of(context).size.width * 2.0
                        : 0.0),

              //transformAlignment: FractionalOffset.centerRight,
              onEnd: () {
                Provider.of<AppState>(context, listen: false).resetAllIndicators();
                print("translation done - rotate");
                if (Provider.of<AppState>(context, listen: false).currentPuzzleState.puzzleStatus ==
                    PuzzleStatus.complete) {
                  rotateController.forward();
                }
              },
              child: RotatedPuzzle(
                rotationAngle: 0.0,
                level: Provider.of<AppState>(context, listen: true).currentLevel,
              ),
            ),

            RotatedPuzzle(
              rotationAngle: -kAngularOffset,
              level: Provider.of<AppState>(context, listen: true).nextLevel,
            ),
            Positioned(
              left: Provider.of<UIState>(context, listen: true).playAreaWidth.value,
              child: const SpaceStationRing(),
            ),
          ],
        ),
      ),
    );
  }
}

class RotatedPuzzle extends StatelessWidget {
  const RotatedPuzzle({
    Key? key,
    required this.rotationAngle,
    required this.level,
  }) : super(key: key);

  final double rotationAngle;
  final Level level;

  @override
  Widget build(BuildContext context) {
    int armsInCurrentLvl = level.blueprints.length;
    int firstRowItems = (armsInCurrentLvl / 2).round();

    // todo: place method somewhere else (app state?)
    /// create all ship widgets for current level
    List<Widget> _createArmWidgets() {
      List<Widget> armWidgets = [];
      // TODO: FIGURE OUT FOR WHICH LEVEL ARM IS CREATED
      int levelID;
      if (level == Provider.of<AppState>(context, listen: false).previousLevel) {
        levelID = 0;
      } else if (level == Provider.of<AppState>(context, listen: false).currentLevel) {
        levelID = 1;
      } else {
        levelID = 2;
      }

      for (int i = 0; i < level.blueprints.length; i++) {
        armWidgets.add(
          Arm(
            levelID: levelID,
            blueprint: level.blueprints[i],
            isTopRow: i < firstRowItems,
          ),
        );
      }

      // for (Blueprint bp in level.blueprints) {
      //   armWidgets.add(Arm(levelID: levelID, blueprint: bp));
      // }
      return armWidgets;
    }

    return Transform(
      transform: Matrix4.rotationZ(rotationAngle * pi / 180),
      origin: Offset(Provider.of<UIState>(context, listen: true).stationDiameter.value / 2, 0),
      alignment: FractionalOffset.centerRight,
      child: SizedBox(
        width: Provider.of<UIState>(context, listen: true).playAreaWidth.value,
        height: Provider.of<UIState>(context, listen: true).playAreaHeight.value,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            Column(
              children: [
                Expanded(
                  flex: kArmAreaFlex,
                  // top row arms with contents
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ..._createArmWidgets().sublist(0, firstRowItems).toList(),
                    ],
                  ),
                ),
                Expanded(flex: kCenterFlex, child: Container()),
                Expanded(
                    flex: kArmAreaFlex,
                    // bottom row arms with contents
                    child: Transform.rotate(
                      angle: pi,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ..._createArmWidgets().sublist(firstRowItems).reversed.toList(),
                        ],
                      ),
                    )),
              ],
            ),
            Positioned(
              // TODO: define ratio
              // todo: ignore pointer?
              height: 0.161 * Provider.of<UIState>(context, listen: true).playAreaWidth.value,
              width: 16 / 9 * Provider.of<UIState>(context, listen: true).playAreaWidth.value,
              child: Rive(
                artboard:
                    Provider.of<AppState>(context, listen: true).stationArtboards[rotationAngle < 0
                        ? 0
                        : rotationAngle > 0
                            ? 2
                            : 1]!,
                //fit: BoxFit.cover,
              ),
            ),
            // display level ID
            Positioned(
              left: Provider.of<UIState>(context, listen: true).playAreaWidth.value * 0.085,
              width: Provider.of<UIState>(context, listen: true).playAreaWidth.value * 0.15,
              height: Provider.of<UIState>(context, listen: true).playAreaHeight.value *
                  kCenterFlex /
                  (2 * kArmAreaFlex + kCenterFlex) *
                  0.9,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 3,
                    child: FittedBox(
                      child: Text(
                        "${level.id}", //"284",
                        style: GoogleFonts.orbitron(
                          fontSize: 100,
                          color: Colors.deepPurple[800],
                          // TODO: center text
                          //textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: FittedBox(
                      child: Text(
                        "lvl",
                        style: GoogleFonts.orbitron(
                          fontSize: 100,
                          color: Colors.deepPurple[800],
                          // TODO: center text
                          //textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Positioned(
            //   left: Provider.of<UIState>(context, listen: true).playAreaWidth.value * 0.385,
            //   width: Provider.of<UIState>(context, listen: true).playAreaWidth.value * 0.06,
            //   height: Provider.of<UIState>(context, listen: true).playAreaHeight.value *
            //       kCenterFlex /
            //       (2 * kArmAreaFlex + kCenterFlex) *
            //       0.9,
            //   child: Column(
            //     children: [
            //       Expanded(
            //         flex: 2,
            //         child: FittedBox(
            //           child: Text(
            //             "best:",
            //             style: GoogleFonts.orbitron(
            //               fontSize: 100,
            //               color: Colors.deepPurple[800],
            //             ),
            //           ),
            //         ),
            //       ),
            //       Expanded(
            //         flex: 2,
            //         child: FittedBox(
            //           child: Text(
            //             "${level.minimumMoves}",
            //             style: GoogleFonts.orbitron(
            //               fontSize: 100,
            //               color: Colors.deepPurple[800],
            //             ),
            //           ),
            //         ),
            //       ),
            //       Expanded(
            //         flex: 2,
            //         child: FittedBox(
            //           child: Text(
            //             "mvs",
            //             style: GoogleFonts.orbitron(
            //               fontSize: 100,
            //               color: Colors.deepPurple[800],
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // display number of moves
            Positioned(
              right: Provider.of<UIState>(context, listen: true).playAreaWidth.value * 0.24,
              width: Provider.of<UIState>(context, listen: true).playAreaWidth.value * 0.15,
              height: Provider.of<UIState>(context, listen: true).playAreaHeight.value *
                  kCenterFlex /
                  (2 * kArmAreaFlex + kCenterFlex) *
                  0.7,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    // TODO: add star rating based on moves
                    child: FittedBox(
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.deepPurple[800],
                          ),
                          Provider.of<AppState>(context, listen: true).currentPuzzleState.level !=
                                      level ||
                                  Provider.of<AppState>(context, listen: true)
                                          .currentPuzzleState
                                          .numberOfMoves <=
                                      level.medianMoves + level.medianMoves ~/ 10
                              ? Icon(
                                  Icons.star,
                                  color: Colors.deepPurple[800],
                                )
                              : Container(),
                          Provider.of<AppState>(context, listen: true).currentPuzzleState.level !=
                                      level ||
                                  Provider.of<AppState>(context, listen: true)
                                          .currentPuzzleState
                                          .numberOfMoves <=
                                      level.medianMoves
                              ? Icon(
                                  Icons.star,
                                  color: Colors.deepPurple[800],
                                )
                              : Container(),
                          Provider.of<AppState>(context, listen: true).currentPuzzleState.level !=
                                      level ||
                                  Provider.of<AppState>(context, listen: true)
                                          .currentPuzzleState
                                          .numberOfMoves <=
                                      level.minimumMoves
                              ? Icon(Icons.star, color: Colors.deepPurple[800])
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: Container()),
                  Expanded(
                    flex: 3,
                    child: FittedBox(
                      child: Text(
                        level !=
                                Provider.of<AppState>(context, listen: true)
                                    .currentPuzzleState
                                    .level
                            ? "0"
                            : "${Provider.of<AppState>(context, listen: true).currentPuzzleState.numberOfMoves} / ${level.minimumMoves}",
                        style: GoogleFonts.orbitron(
                          fontSize: 100,
                          color: Colors.deepPurple[800],
                          // TODO: center text
                          //textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: FittedBox(
                      child: Text(
                        "moves",
                        style: GoogleFonts.orbitron(
                          fontSize: 100,
                          color: Colors.deepPurple[800],
                          // TODO: center text
                          //textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // todo: only for testing --> remove
            // rotationAngle == 0
            //     ? Positioned(
            //         top: 100.0,
            //         height: 0.161 * Provider.of<UIState>(context, listen: true).playAreaWidth.value,
            //         width: 5 / 3 * Provider.of<UIState>(context, listen: true).playAreaWidth.value,
            //         child: Container(
            //           child: Rive(
            //             artboard: Provider.of<AppState>(context, listen: true).stationArtboards[3]!,
            //           ),
            //         ),
            //       )
            //     : Container(),
          ],
        ),
      ),
    );
  }
}

class Arm extends StatelessWidget {
  const Arm({
    required this.levelID,
    required this.blueprint,
    required this.isTopRow,
    Key? key,
  }) : super(key: key);

  final int levelID;
  final Blueprint blueprint;
  final bool isTopRow;

  final PuzzleTheme theme = const BasicTheme();

  @override
  Widget build(BuildContext context) {
    // TODO: move somewhere else (logic)
    double armWidth =
        Provider.of<UIState>(context, listen: true).playAreaWidth.value / kRegularShipWidthDivider;
    double armHeight = blueprint.size * armWidth * kContentWidthFactor +
        blueprint.size ~/ 2 * armWidth * kRegularGapRatio +
        (blueprint.size - 1) ~/ 2 * armWidth * (kGapBetweenContainerRatio + 2 * kSmallGapRatio) +
        2 * armWidth * kSmallGapRatio;

    //const int playAreaTotalFlex = 2 * kArmAreaFlex + kCenterFlex; //9
    // const int shipAreaTotalFlex = kArmFlex + kIndicatorFlex + kConnectorFlex; //16
    //
    // final double shipAreaTotalHeight =
    //     Provider.of<UIState>(context, listen: true).playAreaHeight.value *
    //         kArmAreaFlex /
    //         playAreaTotalFlex;
    //print("arm height for ${blueprint.size}: ${armHeight / armWidth}");

    //double connectorHeight = shipAreaTotalHeight * kConnectorFlex / shipAreaTotalFlex * 2.5;
    // double indicatorHeight =
    //     shipAreaTotalHeight * kArmAreaFlex / shipAreaTotalFlex * kIndicatorFlex / kArmFlex;

    return GestureDetector(
      onTap: () {
        Provider.of<AppState>(context, listen: false).clickOnPosition(blueprint.position);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: armWidth,
            height: armHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // todo: indicator widget

                Positioned(
                  bottom: armHeight,
                  child: Provider.of<AppState>(context, listen: true).isHazardMode(levelID) ||
                          blueprint.shipColorNumber != null
                      ? SizedBox(
                          height: armWidth * kIndicatorHeightRatio,
                          width: armWidth, //indicatorWidth,
                          child: Stack(
                            children: [
                              Rive(
                                artboard: Provider.of<AppState>(context, listen: true)
                                    .getIndicatorArtboards(levelID)[blueprint.position]!,
                              ),
                              Provider.of<AppState>(context, listen: true).isHazardMode(levelID) &&
                                      blueprint.isWarehouse
                                  ? Positioned.fill(
                                      child: Transform.rotate(
                                        angle: isTopRow ? 0 : pi,
                                        child: FractionallySizedBox(
                                          widthFactor: 0.4,
                                          heightFactor: 0.4,
                                          child: Center(
                                            child: FittedBox(
                                              child: Icon(
                                                theme.hazardIconData,
                                                color: Colors.grey[200],
                                                size: 100,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Provider.of<AppState>(context, listen: true).isHazardMode(levelID) &&
                                      blueprint.isWarehouse
                                  ? Positioned.fill(
                                      child: Transform.rotate(
                                        angle: isTopRow ? 0 : pi,
                                        child: const FractionallySizedBox(
                                          widthFactor: 0.65,
                                          heightFactor: 0.65,
                                          child: Center(
                                            child: FittedBox(
                                              child: Icon(
                                                Icons.not_interested_sharp,
                                                color: Colors.red,
                                                size: 100,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        )
                      : Container(),
                ),
                // todo: connector widget
                Positioned(
                  top: armHeight,
                  child: SizedBox(
                    width: armWidth,
                    height: armWidth,
                    child: Rive(
                        artboard: Provider.of<AppState>(context, listen: true)
                            .getConnectorArtboards(1)[blueprint.position]!),
                  ),
                ),
                // todo: container/arm widget
                Stack(
                  children: [
                    //todo: glow widget
                    Positioned(
                      top: 0.0, //0.8 * shipWidth,
                      child: SizedBox(
                        width: armWidth,
                        height: armHeight, // - 0.8 * shipWidth,
                        child: FractionallySizedBox(
                          widthFactor: 1.0, //0.8 * 0.9
                          heightFactor: 1.0, //0.9,
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: blueprint.isSelected
                                  ? [
                                      BoxShadow(
                                        color: theme.glowColor,
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
                    ArmWidget(blueprint: blueprint, armWidth: armWidth, isTopRow: isTopRow),
                    Positioned(
                      top: 0.0, //0.8 * shipWidth,
                      child: SizedBox(
                        width: armWidth,
                        height: armHeight,
                        child: Rive(
                            artboard: Provider.of<AppState>(context, listen: true)
                                .shipArtboards[blueprint.size]!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArmWidget extends StatelessWidget {
  const ArmWidget({
    required this.blueprint,
    required this.armWidth,
    required this.isTopRow,
    Key? key,
  }) : super(key: key);

  final Blueprint blueprint;
  final double armWidth;
  final bool isTopRow;

  // todo: theme in app state?
  final PuzzleTheme theme = const BasicTheme();

  List<Widget> _calculateContents() {
    return List.generate(
      blueprint.size,
      (i) => Column(children: [
        i < blueprint.containerContents.length
            ? Container(
                width: armWidth * kContentWidthFactor,
                height: armWidth * kContentWidthFactor,
                color: theme.colorPalette[blueprint.containerContents[i].colorNumber],
                child: blueprint.containerContents[i].isHazardous
                    ? Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          heightFactor: 0.8,
                          child: Transform.rotate(
                            angle: isTopRow ? 0 : pi,
                            child: FittedBox(
                              child: Icon(
                                theme.hazardIconData,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      )
                    : null,
              )
            : Container(
                width: armWidth * kContentWidthFactor,
                height: armWidth * kContentWidthFactor,
                color: theme.emptyVesselColor,
              ),
        i != blueprint.size - 1
            ? i % 2 == 0
                ? SizedBox(
                    height: kRegularGapRatio * armWidth,
                    //color: PuzzleColors.white,
                    child: i + 1 < blueprint.containerContents.length
                        ? Center(
                            child: Container(
                              width: armWidth * 0.2,
                              color: blueprint.containerContents[i].colorNumber ==
                                      blueprint.containerContents[i + 1].colorNumber
                                  ? theme.colorPalette[blueprint.containerContents[i].colorNumber]
                                  : theme.emptyVesselColor,
                            ),
                          )
                        : Container(
                            width: armWidth * 0.2,
                            color: theme.emptyVesselColor,
                          ),
                  )
                : SizedBox(
                    height: (kGapBetweenContainerRatio + 2 * kSmallGapRatio) * armWidth,
                    child: i + 1 < blueprint.containerContents.length
                        ? Center(
                            child: Container(
                              width: armWidth * 0.2,
                              color: blueprint.containerContents[i].colorNumber ==
                                      blueprint.containerContents[i + 1].colorNumber
                                  ? theme.colorPalette[blueprint.containerContents[i].colorNumber]
                                  : theme.emptyVesselColor,
                            ),
                          )
                        : Container(
                            width: armWidth * 0.2,
                            color: theme.emptyVesselColor,
                          ),
                  )
            : Container(),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: kSmallGapRatio * armWidth),
        ..._calculateContents(),
        SizedBox(height: kSmallGapRatio * armWidth),
      ],
    );
  }
}

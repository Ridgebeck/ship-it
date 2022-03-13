import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../theme/basic_theme.dart';

const theme = BasicTheme();

class StartMenu extends StatefulWidget {
  const StartMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<StartMenu> createState() => _StartMenuState();
}

class _StartMenuState extends State<StartMenu> {
  bool _onButtonOne = false;
  bool _onButtonTwo = false;
  bool _onButtonThree = false;
  bool _onIcon = false;

  bool _subMenuIsOpen = false;
  bool _yesPressed = false;
  bool _onSubMenuButtonOne = false;
  bool _onSubMenuButtonTwo = false;

  void _startGame({int level = 1}) {
    Provider.of<AppState>(context, listen: false).initializeLevel(lvl: level);
    Provider.of<AppState>(context, listen: false).gameIsStarted = true;
    Provider.of<AppState>(context, listen: false).shouldFadeOut!.value = true;

    // TODO: start player in app state
    if (Provider.of<AppState>(context, listen: false).soundIsOn) {
      Provider.of<AppState>(context, listen: false).startBGMusic();
    }
  }

  void _toggleSound() {
    Provider.of<AppState>(context, listen: false).toggleSound();
  }

  void _showSubMenu() {
    setState(() {
      _subMenuIsOpen = true;
    });
  }

  void _hideSubMenu() {
    setState(() {
      _subMenuIsOpen = false;
    });
  }

  List<Widget> _buildStartMenu({required BuildContext context}) {
    List<Widget> widgets = [];
    widgets.add(Expanded(flex: 2, child: Container()));
    // check if all data has been loaded to show menu
    if (Provider.of<AppState>(context, listen: true).allDataHasBeenLoaded) {
      // check if saved level data is available
      if (Provider.of<AppState>(context, listen: false).currentLevelId > 1 || _yesPressed) {
        widgets.add(
          _subMenuIsOpen
              ? const FractionallySizedBox(
                  widthFactor: 0.7,
                  child: FittedBox(
                    child: HoverText(
                      text: "restart at first level?",
                      canInteractWith: false,
                    ),
                  ),
                )
              : FractionallySizedBox(
                  widthFactor: 0.6,
                  child: FittedBox(
                    child: HoverText(
                      text:
                          "continue at level ${Provider.of<AppState>(context, listen: false).currentLevelId}",
                      onButton: _onButtonOne,
                      onHoverFunction: (onTarget) {
                        setState(() {
                          _onButtonOne = onTarget;
                        });
                      },
                      onTapFunction: () {
                        _startGame(
                            level: Provider.of<AppState>(context, listen: false).currentLevelId);
                      },
                    ),
                  ),
                ),
        );
        widgets.add(Expanded(child: Container()));
        widgets.add(
          FractionallySizedBox(
            widthFactor: 0.4,
            child: FittedBox(
              child: _subMenuIsOpen
                  ? Row(
                      children: [
                        HoverText(
                          text: "   no    ",
                          onButton: _onSubMenuButtonOne,
                          onHoverFunction: (onTarget) {
                            setState(() {
                              _onSubMenuButtonOne = onTarget;
                            });
                          },
                          onTapFunction: _hideSubMenu,
                        ),
                        HoverText(
                          text: "    yes   ",
                          onButton: _onSubMenuButtonTwo,
                          onHoverFunction: (onTarget) {
                            setState(() {
                              _onSubMenuButtonTwo = onTarget;
                            });
                          },
                          onTapFunction: () async {
                            _yesPressed = true;
                            // save current level locally
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setInt("level", 1);
                            _startGame(level: 1);
                          },
                        ),
                      ],
                    )
                  : HoverText(
                      text: "restart game",
                      onButton: _onButtonTwo,
                      onHoverFunction: (onTarget) {
                        setState(() {
                          _onButtonTwo = onTarget;
                        });
                      },
                      onTapFunction: _showSubMenu,
                    ),
            ),
          ),
        );
      } else {
        widgets.add(
          FractionallySizedBox(
            widthFactor: 0.4,
            child: FittedBox(
              child: HoverText(
                text: "start game",
                onButton: _onButtonThree,
                onHoverFunction: (onTarget) {
                  setState(() {
                    _onButtonThree = onTarget;
                  });
                },
                onTapFunction: _startGame,
              ),
            ),
          ),
        );
      }
      widgets.add(Expanded(flex: 2, child: Container()));
      widgets.add(
        FractionallySizedBox(
          widthFactor: 0.05,
          child: FittedBox(
            child: VolumeIcon(
              onTapFunction: _toggleSound,
              onButton: _onIcon,
              onHoverFunction: (onTarget) {
                setState(() {
                  _onIcon = onTarget;
                });
              },
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: max(min(600, MediaQuery.of(context).size.width * 0.8), 200),
          height: max(min(600, MediaQuery.of(context).size.height * 0.8), 300),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Expanded(flex: 2, child: Container()),
              SizedBox(
                height: 1 / 3 * max(min(600, MediaQuery.of(context).size.height * 0.8), 300),
              ),
              AspectRatio(
                aspectRatio: 5.0,
                child: Rive(
                  artboard: Provider.of<AppState>(context, listen: true).logoArtboard!,
                  fit: BoxFit.contain,
                ),
              ),
              // show start menu (after loading)
              ..._buildStartMenu(context: context),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverText extends StatelessWidget {
  const HoverText({
    Key? key,
    required this.text,
    this.canInteractWith = true,
    this.onButton,
    this.onHoverFunction,
    this.onTapFunction,
  }) : super(key: key);

  final String text;
  final bool canInteractWith;
  final bool? onButton;
  final Function? onHoverFunction;
  final Function? onTapFunction;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      opacity: Provider.of<AppState>(context, listen: true).introAnimationIsFinished
          ? Provider.of<AppState>(context, listen: true).gameIsStarted
              ? 0.0
              : 1.0
          : 0.0,
      child: canInteractWith
          ? InkWell(
              onTap: () {
                onTapFunction!();
              },
              onHover: (onTarget) {
                onHoverFunction!(onTarget);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                transform: onButton! ? theme.hoveredTransform : Matrix4.identity(),
                transformAlignment: Alignment.center,
                child: Text(
                  text,
                  style: GoogleFonts.orbitron(
                    color: onButton! ? theme.textHoverColor : theme.textColor,
                    fontSize: 50.0,
                  ),
                ),
              ),
            )
          : Text(
              text,
              style: GoogleFonts.orbitron(
                color: theme.textHoverColor,
                fontSize: 50.0,
              ),
            ),
    );
  }
}

class VolumeIcon extends StatelessWidget {
  const VolumeIcon({
    Key? key,
    required this.onButton,
    required this.onHoverFunction,
    required this.onTapFunction,
  }) : super(key: key);
  final bool onButton;
  final Function onHoverFunction;
  final Function onTapFunction;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      opacity: Provider.of<AppState>(context, listen: true).introAnimationIsFinished
          ? Provider.of<AppState>(context, listen: true).gameIsStarted
              ? 0.0
              : 1.0
          : 0.0,
      child: InkWell(
        onTap: () {
          onTapFunction();
        },
        onHover: (onTarget) {
          onHoverFunction(onTarget);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: onButton ? theme.hoveredTransform : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Icon(
            Provider.of<AppState>(context, listen: true).soundIsOn
                ? Icons.volume_up
                : Icons.volume_off,
            color: onButton ? theme.textHoverColor : theme.textColor,
          ),
        ),
      ),
    );
  }
}

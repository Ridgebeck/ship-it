import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:ship_it/puzzle/view/puzzle.dart';

import '../../models/app_state.dart';
import '../../theme/basic_theme.dart';
import '../widgets/start_menu.dart';

class PuzzlePageNew extends StatelessWidget {
  const PuzzlePageNew({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const theme = BasicTheme();
    return Scaffold(
      // dark background color
      backgroundColor: theme.backgroundColor,
      body: Stack(
        children: [
          // when game has been started
          Provider.of<AppState>(context, listen: true).gameIsStarted &&
                  Provider.of<AppState>(context, listen: true).bgArtboard != null
              ?
              // show animated background
              Rive(
                  artboard: Provider.of<AppState>(context, listen: true).bgArtboard!,
                  fit: BoxFit.cover,
                )
              : Container(),
          // // dynamic backdrop filter for depth effect
          // BackdropFilter(
          //   filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          //   child: Container(color: Colors.black.withOpacity(0.25)),
          // ),

          // display game as soon as start menu has been finished
          Provider.of<AppState>(context, listen: true).startMenuIsFinished
              ?
              // puzzle is displayed in foreground
              const MenuAndGameLayout()
              :
              // display menu as soon as art board and SMIInput is loaded
              Provider.of<AppState>(context, listen: true).logoArtboard != null &&
                      Provider.of<AppState>(context, listen: true).shouldFadeOut != null
                  ? const StartMenu()
                  : const SizedBox(),
        ],
      ),
    );
  }
}

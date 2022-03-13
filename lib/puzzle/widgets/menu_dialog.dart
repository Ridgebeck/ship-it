import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ship_it/models/app_state.dart';
import 'package:ship_it/theme/basic_theme.dart';

import '../../theme/puzzle_theme.dart';

class MenuDialog extends StatefulWidget {
  const MenuDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<MenuDialog> createState() => _MenuDialogState();
}

class _MenuDialogState extends State<MenuDialog> {
  PuzzleTheme theme = const BasicTheme();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: min(MediaQuery.of(context).size.width * 0.8, 500),
      height: min(MediaQuery.of(context).size.height * 0.8, 700),
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: FittedBox(
                  child: Icon(
                    Icons.close,
                    color: theme.textColor,
                    size: 100,
                  ),
                ),
              ),
            ),
          ),
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 1,
            child: Center(
              child: FittedBox(
                child: Text(
                  "How To Play",
                  style: GoogleFonts.orbitron(
                    color: theme.textColor,
                    fontSize: 50.0,
                  ),
                ),
              ),
            ),
          ),
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 18,
            child: Carroussel(),
          ),
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 1,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    activeColor: theme.accentColor,
                    inactiveThumbColor: theme.accentColor,
                    activeTrackColor: theme.accentColor,
                    inactiveTrackColor: Colors.grey[800],

                    //thumbColor: theme.accentColor,
                    value: Provider.of<AppState>(context, listen: true).soundIsOn,
                    onChanged: Provider.of<AppState>(context, listen: false).changeSound,
                  ),
                  FittedBox(
                    child: Icon(
                        Provider.of<AppState>(context, listen: true).soundIsOn
                            ? Icons.volume_up
                            : Icons.volume_off,
                        size: 100.0,
                        color: Provider.of<AppState>(context, listen: true).soundIsOn
                            ? theme.accentColor
                            : Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ),
          Expanded(flex: 1, child: Container()),
        ],
      ),
    );
  }
}

class Carroussel extends StatefulWidget {
  @override
  _CarrousselState createState() => _CarrousselState();
}

class _CarrousselState extends State<Carroussel> {
  late PageController controller;
  int currentpage = 0;

  @override
  initState() {
    /// precache image assets
    Future<void>.delayed(const Duration(milliseconds: 5), () {
      // precacheImage(const AssetImage('assets/images/sort.jpg'), context);
      // precacheImage(const AssetImage('assets/images/move.jpg'), context);
      // precacheImage(const AssetImage('assets/images/back.jpg'), context);
      // precacheImage(const AssetImage('assets/images/reset.jpg'), context);
      // precacheImage(const AssetImage('assets/images/space.jpg'), context);

      precacheImage(Image.asset('assets/images/sort.jpg').image, context);
      precacheImage(Image.asset('assets/images/move.jpg').image, context);
      precacheImage(Image.asset('assets/images/back.jpg').image, context);
      precacheImage(Image.asset('assets/images/reset.jpg').image, context);
      precacheImage(Image.asset('assets/images/space.jpg').image, context);
    });

    super.initState();
    controller = PageController(
      initialPage: currentpage,
      keepPage: false,
      viewportFraction: 0.70,
    );
    Future.delayed(const Duration(milliseconds: 20), () {
      setState(() {
        controller.animateToPage(0,
            duration: const Duration(milliseconds: 1), curve: Curves.bounceIn);
      });
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   precacheImage(Image.asset('assets/images/sort.jpg').image, context);
  //   precacheImage(Image.asset('assets/images/move.jpg').image, context);
  //   precacheImage(Image.asset('assets/images/back.jpg').image, context);
  //   precacheImage(Image.asset('assets/images/reset.jpg').image, context);
  //   precacheImage(Image.asset('assets/images/space.jpg').image, context);
  // }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: PageView.builder(
            onPageChanged: (value) {
              setState(() {
                currentpage = value;
              });
            },
            controller: controller,
            itemCount: images.length,
            itemBuilder: (context, index) => builder(index)),
      ),
    );
  }

  builder(int index) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double value = 1.0;
        if (controller.position.haveDimensions) {
          value = controller.page! - index;
          value = (1 - (value.abs() * .5)).clamp(0.0, 1.0);
        }

        return Center(
          child: SizedBox(
            height: Curves.easeOut.transform(value) * 500,
            width: Curves.easeOut.transform(value) * 600,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: const BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        margin: const EdgeInsets.all(5.0),
        child: FractionallySizedBox(
          widthFactor: 0.90,
          heightFactor: 0.90,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AutoSizeText(
                    textDescriptions[index],
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      height: 1.3,
                    ),
                    //presetFontSizes: const [20, 18, 15, 12, 10],
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.asset("assets/images/${images[index]}"),
                  // Image(image:
                  // AssetImage("assets/images/${images[index]}")),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // return Container(
    //   decoration: BoxDecoration(
    //     color: Colors.grey[800],
    //     borderRadius: const BorderRadius.all(
    //       Radius.circular(20.0),
    //     ),
    //   ),
    //   margin: const EdgeInsets.all(8.0),
    //   child: FractionallySizedBox(
    //     widthFactor: 0.9,
    //     heightFactor: 0.9,
    //     child: Column(
    //       children: [
    //         Expanded(child: Container(color: Colors.yellow)),
    //         Expanded(
    //           flex: 3,
    //           child: Image.asset("assets/images/${images[index]}"),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

List<String> images = [
  "sort.jpg",
  "move.jpg",
  "space.jpg",
  "hazard.jpg",
  "back.jpg",
  "reset.jpg",
];
List<String> textDescriptions = [
  "Sort the colors. The color indicator at the top of each container tells you where each color "
      "belongs.",
  "you can only move to completely empty containers or spaces with the same color being adjacent",
  "once combined, all adjacent spaces with the same color move together",
  "hazardous liquids can not be stored in all containers",
  "you can move back up to 3 steps for each try",
  "you can reset the level if you get stuck",
];

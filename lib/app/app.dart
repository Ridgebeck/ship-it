import 'package:flutter/material.dart';
import '/puzzle/puzzle.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// precache image assets
    //    Future<void>.delayed(const Duration(milliseconds: 20), () {
    //       precacheImage(
    //         Image.asset('assets/images/shuffle_icon.png').image,
    //         context,
    //       );
    //       precacheImage(
    //         Image.asset('assets/images/simple_dash_large.png').image,
    //         context,
    //       );
    //       precacheImage(
    //         Image.asset('assets/images/simple_dash_medium.png').image,
    //         context,
    //       );
    //       precacheImage(
    //         Image.asset('assets/images/simple_dash_small.png').image,
    //         context,
    //       );
    //     });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          // TODO: define color scheme here

          ),
      home: const PuzzlePage(),
    );
  }
}

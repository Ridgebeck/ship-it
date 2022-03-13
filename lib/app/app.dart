import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../puzzle/logic/load_data.dart';
import '../puzzle/view/layout_new.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    // /// precache image assets
    // Future<void>.delayed(const Duration(milliseconds: 20), () {
    //   precacheImage(
    //     Image.asset('assets/images/sort.jpg').image,
    //     context,
    //   );
    //   precacheImage(
    //     Image.asset('assets/images/move.jpg').image,
    //     context,
    //   );
    //   precacheImage(
    //     Image.asset('assets/images/back.jpg').image,
    //     context,
    //   );
    //   precacheImage(
    //     Image.asset('assets/images/reset.jpg').image,
    //     context,
    //   );
    //   precacheImage(
    //     Image.asset('assets/images/space.jpg').image,
    //     context,
    //   );
    //
    //   //       precacheImage(
    //   //         Image.asset('assets/images/shuffle_icon.png').image,
    //   //         context,
    //   //       );
    //   //       precacheImage(
    //   //         Image.asset('assets/images/simple_dash_large.png').image,
    //   //         context,
    //   //       );
    //   //       precacheImage(
    //   //         Image.asset('assets/images/simple_dash_medium.png').image,
    //   //         context,
    //   //       );
    //   //       precacheImage(
    //   //         Image.asset('assets/images/simple_dash_small.png').image,
    //   //         context,
    //   //       );
    // });

    /// start loading all rive assets
    LoadData().loadAllRiveAssets(context: context);

    /// load data from local memory
    LoadData().sharedPrefInit(context);

    // TODO: start load sound assets
    // TODO: issue: loading is stopping animation
    //Provider.of<AppState>(context, listen: false).loadBGMusic();
  }

  @override
  void dispose() {
    super.dispose();
    Provider.of<AppState>(context, listen: false).disposeAudioPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),
      theme: ThemeData(
          // TODO: define color scheme here

          ),
      home: const PuzzlePageNew(), //const PuzzlePage(),
    );
  }
}

/// allow swiping with mouse
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

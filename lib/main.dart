import 'dart:html';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/models.dart';
import 'models/ui_state.dart';

import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;

void main() async {
  // initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //sign in anonymously
  await FirebaseAuth.instance.signInAnonymously();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // todo: blank page issue
  // // try to maximize screen for web
  // if (kIsWeb && document.documentElement != null) {
  //   document.documentElement!.requestFullscreen();
  // }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppState(),
        ),
        ChangeNotifierProvider(
          create: (context) => UIState(),
        ),
      ],
      child: const App(),
    ),
  );
}

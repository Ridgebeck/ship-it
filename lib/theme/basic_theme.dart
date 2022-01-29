import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ship_it/layout/layout_delegate.dart';
import 'package:ship_it/layout/standard_puzzle_layout_delegate.dart';
import 'package:ship_it/theme/puzzle_theme.dart';

class BasicTheme extends PuzzleTheme {
  const BasicTheme() : super();

  @override
  String get name => 'Basic';

  @override
  Color get backgroundColor => Colors.black;

  @override
  bool get allowRotating => false;

  @override
  List<Color> get colorPalette => [
        Colors.red,
        Colors.green,
        Colors.indigo,
        Colors.yellow,
        Colors.deepPurple,
        Colors.green[900]!,
        Colors.blue[700]!,
        Colors.orange,
        Colors.brown[600]!,
        Colors.pink,
        Colors.greenAccent,
        Colors.black,
      ];

  @override
  PuzzleLayoutDelegate get layoutDelegate => const SimplePuzzleLayoutDelegate();

  @override
  // TODO: implement props
  List<Object?> get props => [
        name,
        backgroundColor,
        allowRotating,
      ];
}

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_it/layout/layout_delegate.dart';

/// abstract class that defines the options of the specific game mode
abstract class PuzzleTheme extends Equatable {
  const PuzzleTheme();

  /// The display name of this theme.
  String get name;

  /// The background color of this theme.
  /// TODO: replace with animated background? or builder
  Color get backgroundColor;

  /// Whether this theme displays the tug boats for rotation
  bool get allowRotating;

  /// Color palette
  List<Color> get colorPalette;

  /// The puzzle layout delegate of this theme.
  ///
  /// Used for building different sections of the puzzle UI.
  PuzzleLayoutDelegate get layoutDelegate;
}

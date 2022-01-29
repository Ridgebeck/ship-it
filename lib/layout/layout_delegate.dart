import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

abstract class PuzzleLayoutDelegate extends Equatable {
  const PuzzleLayoutDelegate();

  //Widget backgroundBuilder(PuzzleState state);
  /// builds background widgets based on screen size
  Widget backgroundBuilder();

  /// builds play area based on screen size
  Widget playAreaBuilder();
}

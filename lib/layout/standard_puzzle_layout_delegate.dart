import 'package:flutter/material.dart';

import 'package:ship_it/layout/responsive_layout_builder.dart';
import 'layout_delegate.dart';

class SimplePuzzleLayoutDelegate extends PuzzleLayoutDelegate {
  const SimplePuzzleLayoutDelegate();

  @override
  Widget backgroundBuilder() {
    return Positioned(
      left: 0,
      bottom: 0,
      child: ResponsiveLayoutBuilder(
        small: (_, __) => SizedBox(
          width: 100,
          height: 100,
          child: Image.asset('images/moon.png'),
        ),
        // medium: (_, __) => SizedBox(
        //   width: 250,
        //   height: 250,
        //   child: Image.asset('assets/images/moon.png'),
        // ),
        large: (_, __) => SizedBox(
          width: 400,
          height: 400,
          child: Image.asset('images/moon.png'),
        ),
      ),
    );
  }

  @override
  Widget playAreaBuilder() {
    return Container(
      width: 500,
      height: 500,
      color: Colors.green,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

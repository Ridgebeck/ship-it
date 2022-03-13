import 'package:flutter/material.dart';
import 'buttons.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu({
    Key? key,
    required this.playAreaWidth,
  }) : super(key: key);

  final double playAreaWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 3, child: Container()),
        Expanded(
          flex: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RestartButton(),
              SizedBox(width: playAreaWidth / 10),
              const MoveBackButton(),
              SizedBox(width: playAreaWidth / 10),
              const SettingsButton(),
            ],
          ),
        ),
        Expanded(flex: 2, child: Container()),
      ],
    );
  }
}

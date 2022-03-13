import 'package:flutter/material.dart';
import 'buttons.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
    required this.playAreaWidth,
  }) : super(key: key);

  final double playAreaWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container()),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RestartButton(),
              SizedBox(height: playAreaWidth / 10),
              const MoveBackButton(),
              SizedBox(height: playAreaWidth / 10),
              const SettingsButton(),
            ],
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ship_it/puzzle/widgets/end_dialog.dart';

import '../../models/app_state.dart';
import 'menu_dialog.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Future.delayed(Duration.zero, () {
          return showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.grey[900],
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                content: const MenuDialog(),
              );
            },
          );
        });
      },
      child: const Icon(Icons.settings), //Text("set"),
    );
  }
}

class RestartButton extends StatelessWidget {
  const RestartButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        print("restarting");
        Provider.of<AppState>(context, listen: false).restart();
      },
      child: const Icon(Icons.repeat),
    );
  }
}

class MoveBackButton extends StatelessWidget {
  const MoveBackButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        print("move back button pressed");
        Provider.of<AppState>(context, listen: false).oneMoveBack();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FittedBox(
            child: Icon(
              Icons.arrow_back_ios,
              size: 20.0,
            ),
          ),
          Text(Provider.of<AppState>(context, listen: true)
              .currentPuzzleState
              .goBackAttempts
              .toString()),
        ],
      ),
    );
  }
}

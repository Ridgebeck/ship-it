import 'package:flutter/material.dart';
import 'package:ship_it/models/app_state.dart';
import 'package:provider/provider.dart';

class ContinueDialog extends StatefulWidget {
  const ContinueDialog({
    Key? key,
    required this.levelLeftOff,
  }) : super(key: key);

  final int levelLeftOff;

  @override
  State<ContinueDialog> createState() => _ContinueDialogState();
}

Color unselectedColorD = Colors.blue;
Color selectedColorD = Colors.indigo;
late List<bool> hasBeenPressedDiff;
late List<bool> hasBeenPressedLike;

class _ContinueDialogState extends State<ContinueDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hasBeenPressedDiff = List.generate(3, (index) => false);
    hasBeenPressedLike = List.generate(2, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Column(
        children: [
          Text(
            "Hey. You left off at level ${widget.levelLeftOff}.",
            style: const TextStyle(fontSize: 20.0),
          ),
          const SizedBox(height: 20),
          const Text("Do you want to continue or start from level 1?"),
          const SizedBox(height: 15),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: hasBeenPressedDiff[0] == true ? selectedColorD : unselectedColorD),
                onPressed: () {
                  Provider.of<AppState>(context, listen: false).initializeLevel(
                    lvl: widget.levelLeftOff,
                    update: true,
                  );
                  Navigator.pop(context);
                },
                child: Text("CONTINUE"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: hasBeenPressedDiff[1] == true ? selectedColorD : unselectedColorD),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("RESTART"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

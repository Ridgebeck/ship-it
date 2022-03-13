import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ship_it/models/app_state.dart';
import 'package:provider/provider.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

Color unselectedColor = Colors.blue;
Color selectedColor = Colors.indigo;
late List<bool> hasBeenPressedDiff;
late List<bool> hasBeenPressedLike;
late Duration timePlayed;

enum diff { easy, medium, hard }
diff difficulty = diff.easy;
bool didEnjoy = false;

class _RatingDialogState extends State<RatingDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hasBeenPressedDiff = List.generate(3, (index) => false);
    hasBeenPressedLike = List.generate(2, (index) => false);

    timePlayed = DateTime.now().difference(Provider.of<AppState>(context, listen: false).startTime);
  }

  @override
  Widget build(BuildContext context) {
    int level = Provider.of<AppState>(context, listen: false).currentLevelId;

    return FittedBox(
      child: Column(
        children: [
          Text(
            "🎉 Nice! You finished level $level. 🎉",
            style: const TextStyle(fontSize: 20.0),
          ),
          const SizedBox(height: 15),
          const Text("How is the difficulty?"),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: hasBeenPressedDiff[0] == true ? selectedColor : unselectedColor),
                onPressed: () {
                  bool isPressed = !hasBeenPressedDiff[0];
                  hasBeenPressedDiff = List.generate(3, (index) => false);
                  hasBeenPressedDiff[0] = isPressed;
                  setState(() {});
                  difficulty = diff.easy;
                },
                child: Text("TOO EASY"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: hasBeenPressedDiff[1] == true ? selectedColor : unselectedColor),
                onPressed: () {
                  bool isPressed = !hasBeenPressedDiff[1];
                  hasBeenPressedDiff = List.generate(3, (index) => false);
                  hasBeenPressedDiff[1] = isPressed;
                  setState(() {});
                  difficulty = diff.medium;
                },
                child: Text("JUST RIGHT"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: hasBeenPressedDiff[2] == true ? selectedColor : unselectedColor),
                onPressed: () {
                  bool isPressed = !hasBeenPressedDiff[2];
                  hasBeenPressedDiff = List.generate(3, (index) => false);
                  hasBeenPressedDiff[2] = isPressed;
                  setState(() {});
                  difficulty = diff.hard;
                },
                child: Text("TOO HARD"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Is it fun?"),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: hasBeenPressedLike[0] == true ? selectedColor : unselectedColor),
                onPressed: () {
                  bool isPressed = !hasBeenPressedLike[0];
                  hasBeenPressedLike = List.generate(2, (index) => false);
                  hasBeenPressedLike[0] = isPressed;
                  setState(() {});
                  didEnjoy = false;
                },
                child: const Icon(Icons.thumb_down),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: hasBeenPressedLike[1] == true ? selectedColor : unselectedColor),
                onPressed: () {
                  bool isPressed = !hasBeenPressedLike[1];
                  hasBeenPressedLike = List.generate(2, (index) => false);
                  hasBeenPressedLike[1] = isPressed;
                  setState(() {});
                  didEnjoy = true;
                },
                child: const Icon(Icons.thumb_up),
              ),
            ],
          ),
          const SizedBox(height: 30),
          hasBeenPressedDiff.contains(true) && hasBeenPressedLike.contains(true)
              ? FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: () {
                    // save data in Firestore
                    FirebaseFirestore.instance.collection("feedback").add({
                      "UID": FirebaseAuth.instance.currentUser!.uid,
                      "level": Provider.of<AppState>(context, listen: false).currentLevelId,
                      "moves": Provider.of<AppState>(context, listen: false).currentMoves,
                      "resets": Provider.of<AppState>(context, listen: false).currentResets,
                      "secondsNeeded": timePlayed.inSeconds,
                      "difficultyRating": difficulty == diff.easy
                          ? "easy"
                          : difficulty == diff.medium
                              ? "medium"
                              : "hard",
                      "didEnjoy": didEnjoy,
                    });

                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.check),
                )
              : Container(),
        ],
      ),
    );
  }
}

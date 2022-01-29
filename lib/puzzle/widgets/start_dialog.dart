import 'package:flutter/material.dart';

class StartDialog extends StatefulWidget {
  const StartDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<StartDialog> createState() => _StartDialogState();
}

class _StartDialogState extends State<StartDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      height: 800,
      //heightFactor: 0.9,
      //widthFactor: 0.9,
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "HEY FRIEND!",
            style: TextStyle(fontSize: 19.0, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            "❤  Thanks for being awesome and testing SHIP-IT!  ❤",
            style: TextStyle(fontSize: 17.0, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Expanded(
            flex: 2,
            child: Text(
              "The goal of this game, developed for the 2022 flutter puzzle Hackathon, is to sort "
              "the "
              "containers of the cargo ships docking onto the space station. All colored "
              "containers have to be brought back to their respective ships. Once same color containers"
              " are combined they cannot be separated again. \n\n"
              "Design is still in the works, so please excuse some ugly stuff and missing "
              "explanations. You will figure it out :)",
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.network("https://media.giphy.com/media/E89xxATM4iZoPdr6Tb/giphy.gif"),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
            "(High five to start)",
            style: TextStyle(fontSize: 15.0, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

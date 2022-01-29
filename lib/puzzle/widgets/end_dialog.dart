import 'package:flutter/material.dart';

class EndDialog extends StatefulWidget {
  const EndDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<EndDialog> createState() => _EndDialogState();
}

class _EndDialogState extends State<EndDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Column(
        children: [
          const Text(
            "🎉 THANK YOU FOR TESTING! 🎉",
            style: TextStyle(fontSize: 20.0),
          ),
          const SizedBox(height: 30),
          Image.network("https://media.giphy.com/media/3oEdva9BUHPIs2SkGk/giphy.gif"),
          const SizedBox(height: 30),
          FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.check),
          )
        ],
      ),
    );
  }
}

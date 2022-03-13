import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EndDialog extends StatefulWidget {
  const EndDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<EndDialog> createState() => _EndDialogState();
}

class _EndDialogState extends State<EndDialog> {
  final textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Column(
        children: [
          Text(
            "🎉  YOU MADE IT!  🎉",
            style: GoogleFonts.orbitron(
              fontSize: 25.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Image.network("https://media.giphy.com/media/3oEdva9BUHPIs2SkGk/giphy.gif")),
          const SizedBox(height: 30),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              "interested in new levels, new modes, and an app coming to iOS and Android?",
              style: GoogleFonts.orbitron(
                fontSize: 18.0,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              "you can leave your email address and we will keep you in the loop",
              style: GoogleFonts.orbitron(
                fontSize: 18.0,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: TextField(
              controller: textController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                focusColor: Colors.white,
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0.0)),
                //border: OutlineInputBorder(),
                hintText: 'enter email',
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "no thanks",
                  style: GoogleFonts.orbitron(
                    fontSize: 18.0,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 25),
              FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () {
                  print(textController.value.text);
                  String email = textController.value.text;
                  if (email.contains("@") && email.length > 5) {
                    // save data in Firestore
                    FirebaseFirestore.instance.collection("email").add({
                      "UID": FirebaseAuth.instance.currentUser!.uid,
                      "email": textController.value.text,
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Icon(Icons.check),
              ),
            ],
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:robotron/components/screens/main_menu_screen.dart';
import 'package:robotron/robotron.dart';
import 'package:robotron/widgets/overlay/pause_button.dart';

class PauseMenu extends StatelessWidget {
  static const String ID = 'PauseMenu';
  final Robotron gameRef;
  const PauseMenu({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(224, 0, 0, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Text(
                  "Paused",
                  style: TextStyle(
                    fontFamily: "Playfair",
                    fontSize: 50,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Color.fromARGB(255, 7, 16, 19),
                    ),
                  ),
                  onPressed: () {
                    gameRef.resumeEngine();
                    gameRef.overlays.remove(PauseMenu.ID);
                    gameRef.overlays.add(PauseButton.ID);
                  },
                  child: Text(
                    "Resume",
                    style: TextStyle(
                        fontFamily: "Playfair",
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Color.fromARGB(255, 7, 16, 19),
                    ),
                  ),
                  onPressed: () {
                    gameRef.overlays.remove(PauseMenu.ID);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return const MainMenuScreen();
                        },
                      ),
                    );
                  },
                  child: Text(
                    "Main Menu",
                    style: TextStyle(
                        fontFamily: "Playfair",
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

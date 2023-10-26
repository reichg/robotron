import 'package:flutter/material.dart';
import 'package:robotron/components/screens/gameplay_screen.dart';
import 'package:robotron/components/screens/main_menu_screen.dart';
import 'package:robotron/robotron.dart';

class GameOverScreen extends StatelessWidget {
  static const String ID = "GameOver";
  final Robotron gameRef;
  const GameOverScreen({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 70.0),
                  child: Text(
                    "Game Over",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Color.fromARGB(255, 28, 27, 27),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => GamePlayScreen(
                                    levelName: gameRef.levelName),
                              ),
                            );
                          },
                          child: Text(
                            "Play Again",
                            style: TextStyle(
                                fontFamily: "Playfair",
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Color.fromARGB(255, 28, 27, 27),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const MainMenuScreen(),
                              ),
                            );

                            // gameRef.reset();
                          },
                          child: Text(
                            "Main Menu",
                            style: TextStyle(
                                fontFamily: "Playfair",
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

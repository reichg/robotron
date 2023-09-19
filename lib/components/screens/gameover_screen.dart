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
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        GamePlayScreen(levelName: gameRef.levelName),
                  ),
                );
              },
              child: Text("Play Again!"),
            ),
            ElevatedButton(
              onPressed: () {
                gameRef.overlays.remove(GameOverScreen.ID);

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainMenuScreen(),
                  ),
                );

                // gameRef.reset();
              },
              child: Text("Main Menu!"),
            ),
          ],
        ),
      ),
    );
  }
}

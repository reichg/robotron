import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:robotron/components/screens/gameover_screen.dart';
import 'package:robotron/robotron.dart';
import 'package:robotron/widgets/overlay/pause_button.dart';
import 'package:robotron/widgets/overlay/pause_menu.dart';

// Robotron _robotronGame = Robotron();

class GamePlayScreen extends StatelessWidget {
  final String levelName;
  const GamePlayScreen({Key? key, required this.levelName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: Robotron(levelName: levelName),
        initialActiveOverlays: [PauseButton.ID],
        overlayBuilderMap: {
          PauseButton.ID: (BuildContext context, Robotron gameRef) =>
              PauseButton(gameRef: gameRef),
          PauseMenu.ID: (BuildContext context, Robotron gameRef) =>
              PauseMenu(gameRef: gameRef),
          GameOverScreen.ID: (BuildContext context, Robotron gameRef) =>
              GameOverScreen(
                gameRef: gameRef,
              ),
        },
      ),
    );
  }
}

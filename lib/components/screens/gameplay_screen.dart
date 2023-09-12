import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:robotron/robotron.dart';
import 'package:robotron/widgets/overlay/pause_button.dart';
import 'package:robotron/widgets/overlay/pause_menu.dart';

Robotron _robotronGame = Robotron();

class GamePlayScreen extends StatelessWidget {
  const GamePlayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _robotronGame,
        initialActiveOverlays: [PauseButton.ID],
        overlayBuilderMap: {
          'PauseButton': (BuildContext context, Robotron gameRef) =>
              PauseButton(gameRef: gameRef),
          'PauseMenu': (BuildContext context, Robotron gameRef) =>
              PauseMenu(gameRef: gameRef),
        },
      ),
    );
  }
}

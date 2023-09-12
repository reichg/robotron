import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:robotron/robotron.dart';

Robotron _robotronGame = Robotron();

class GamePlayScreen extends StatelessWidget {
  const GamePlayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _robotronGame,
    );
  }
}

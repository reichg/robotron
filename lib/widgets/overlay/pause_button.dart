import 'package:flutter/material.dart';
import 'package:robotron/robotron.dart';
import 'package:robotron/widgets/overlay/pause_menu.dart';

class PauseButton extends StatelessWidget {
  static const String ID = 'PauseButton';
  final Robotron gameRef;

  const PauseButton({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        bottom: 45,
        left: 45,
        child: ElevatedButton(
          child: const Text("Pause"),
          onPressed: () {
            gameRef.pauseEngine();
            gameRef.overlays.add(PauseMenu.ID);
            gameRef.overlays.remove(PauseButton.ID);
          },
        ),
      ),
    ]);
  }
}

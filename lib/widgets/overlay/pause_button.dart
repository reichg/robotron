import 'package:flutter/material.dart';
import 'package:robotron/robotron.dart';
import 'package:robotron/widgets/overlay/pause_menu.dart';

class PauseButton extends StatelessWidget {
  static const String ID = 'PauseButton';
  final Robotron gameRef;
  static final Size screenSize = WidgetsBinding.instance.window.physicalSize;
  static final double aspectRatio =
      WidgetsBinding.instance.window.devicePixelRatio;
  static final double deviceWidth = screenSize.width / aspectRatio;
  static final double deviceHeight = screenSize.height / aspectRatio;
  PauseButton({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: ((deviceHeight - gameRef.world.level.height) / 2) + 20,
          left: ((deviceWidth - gameRef.world.level.width) / 2) - 62,
          child: IconButton(
            icon: Icon(
              Icons.pause,
              color: Colors.yellow,
              size: 45,
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith(
                (states) => Color.fromARGB(255, 179, 76, 20),
              ),
            ),
            onPressed: () {
              gameRef.pauseEngine();
              gameRef.overlays.add(PauseMenu.ID);
              gameRef.overlays.remove(PauseButton.ID);
            },
          ),
        )
      ],
    );
  }
}

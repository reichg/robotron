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
  //((deviceWidth / 2) - 320 - deviceWidth * 0.027), (deviceHeight / 2)
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: (deviceHeight / 2) - (deviceHeight * 0.35),
          left: (deviceWidth / 2) - 320 - (deviceWidth * 0.075),
          child: ElevatedButton(
            child: Text(
              "Pause",
              style: TextStyle(
                  fontFamily: "Playfair",
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
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

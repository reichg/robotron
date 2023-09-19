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
    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Text("Paused"),
          ),
          ElevatedButton(
            onPressed: () {
              gameRef.resumeEngine();
              gameRef.overlays.remove(PauseMenu.ID);
              gameRef.overlays.add(PauseButton.ID);
            },
            child: Text("Resume"),
          ),
          ElevatedButton(
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
            child: Text("Main Menu"),
          )
        ],
      ),
    );
  }
}

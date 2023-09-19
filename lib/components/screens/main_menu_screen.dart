import 'package:flutter/material.dart';
import 'package:robotron/components/screens/gameplay_screen.dart';
import 'package:robotron/components/screens/level_select_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Text("Robotron"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LevelSelectScreen(),
                  ),
                );
              },
              child: Text("Play"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("Settings"),
            )
          ],
        ),
      ),
    );
  }
}

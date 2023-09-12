import 'package:flutter/material.dart';
import 'package:robotron/components/screens/gameplay_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Text("Robotron"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Text("Tab To Play!"),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GamePlayScreen(),
          ),
        );
      },
    );
  }
}

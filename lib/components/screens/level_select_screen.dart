import 'package:flutter/material.dart';
import 'package:robotron/components/screens/gameplay_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({Key? key}) : super(key: key);

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  var levelNames = ["level-02"];
  int _selectedIndex = 0;
  String levelName = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Text("Level Select"),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: levelNames.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Center(child: Text('Item ${levelNames[index]}')),
                  selected: index == _selectedIndex,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                      levelName = levelNames[index];
                      print("level name: $levelName");
                    });
                  },
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GamePlayScreen(levelName: levelName),
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

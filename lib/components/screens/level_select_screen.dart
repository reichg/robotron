import 'package:flutter/material.dart';
import 'package:robotron/components/screens/gameplay_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({Key? key}) : super(key: key);

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  static final levelNames = ["level-01", "level-02"];
  List<Image> levelImages = [];
  int _selectedIndex = 0;
  String levelName = levelNames[0];

  @override
  void initState() {
    // TODO: implement initState
    loadLevelImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Level Select"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 850,
                  height: 200,
                  color: Color.fromARGB(43, 7, 255, 243),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: levelImages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        width: 350,
                        height: 100,
                        child: ListTile(
                          title: Image(
                            image: levelImages[index].image,
                            fit: BoxFit.contain,
                          ),
                          selectedTileColor: Colors.blue,
                          selected: index == _selectedIndex,
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                              levelName = levelNames[index];
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
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

  void loadLevelImages() {
    levelImages.addAll(
      [
        const Image(
          image: AssetImage("assets/images/Level Images/level_1_image.png"),
        ),
        const Image(
          image: AssetImage("assets/images/Level Images/level_2_image.png"),
        ),
      ],
    );
  }
}

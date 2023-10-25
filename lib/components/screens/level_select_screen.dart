import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:robotron/components/screens/gameplay_screen.dart';
import 'package:robotron/components/screens/main_menu_screen.dart';
import 'package:robotron/components/screens/settings_screen.dart';

var pixelRatio = window.devicePixelRatio;

//Size in physical pixels
var physicalScreenSize = window.physicalSize;
var physicalWidth = physicalScreenSize.width;
var physicalHeight = physicalScreenSize.height;

//Size in logical pixels
var logicalScreenSize = window.physicalSize / pixelRatio;
var logicalWidth = logicalScreenSize.width;
var logicalHeight = logicalScreenSize.height;

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({Key? key}) : super(key: key);

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  static final levelNames = ["level-02"];
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
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) {
                              return const MainMenuScreen();
                            },
                          ),
                        );
                      },
                      icon: Icon(Icons.arrow_back)),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "Level Select",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Playfair",
                          fontSize: 40,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      color: const Color.fromARGB(0, 0, 0, 0),
                      onPressed: () {},
                      icon: Icon(Icons.arrow_back)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: logicalWidth * 0.9,
                    height: 200,
                    color: Color.fromARGB(255, 11, 11, 11),
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: levelImages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          width: 350,
                          height: 100,
                          child: Material(
                            child: ListTile(
                              title: Image(
                                image: levelImages[index].image,
                                fit: BoxFit.contain,
                              ),
                              selectedTileColor:
                                  Color.fromARGB(255, 35, 68, 146),
                              selected: index == _selectedIndex,
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                  levelName = levelNames[index];
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Color.fromARGB(255, 28, 27, 27),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                GamePlayScreen(levelName: levelName),
                          ),
                        );
                      },
                      child: Text(
                        "Play",
                        style: TextStyle(
                            fontFamily: "Playfair",
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Color.fromARGB(255, 28, 27, 27),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) {
                            return const SettingsScreen();
                          },
                        ),
                      );
                    },
                    child: Text(
                      "Settings",
                      style: TextStyle(
                          fontFamily: "Playfair",
                          fontSize: 20,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loadLevelImages() {
    levelImages.addAll(
      [
        const Image(
          image: AssetImage("assets/images/Level Images/level_2_image.png"),
        ),
      ],
    );
  }
}

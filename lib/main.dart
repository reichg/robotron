import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:robotron/components/screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  runApp(
    MaterialApp(
      home: MainMenuScreen(),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
    ),
  );
}

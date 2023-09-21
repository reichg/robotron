// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:robotron/components/joystick/left_joystick.dart';
import 'package:robotron/components/joystick/right_joystick.dart';
import 'package:robotron/levels/level.dart';

class Robotron extends FlameGame {
  final String levelName;

  @override
  Color backgroundColor() => Color(0xFF211F30);
  late final CameraComponent cam;
  late final LeftJoystick leftJoystick;
  late final RightJoystick rightJoystick;
  late TextComponent leftJoystickTextComponent;
  late TextComponent rightJoystickTextComponent;
  late Level world;
  bool gameOver = false;

  // @override
  // TODO: implement debugMode
  // final debugMode = true;

  Robotron({required this.levelName});
  static final Size screenSize = WidgetsBinding.instance.window.physicalSize;
  static final double aspectRatio =
      WidgetsBinding.instance.window.devicePixelRatio;
  static final double deviceWidth = screenSize.width / aspectRatio;
  static final double deviceHeight = screenSize.height / aspectRatio;

  @override
  FutureOr<void> onLoad() async {
    //images to cache
    await images.loadAllImages();
    await loadWorld();
    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([
      cam,
      world,
    ]);
    createJoysticksAndText();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  Future<void> loadWorld() async {
    world = Level(levelName: levelName);
  }

  // Create and add joysticks and their components to game.
  void createJoysticksAndText() {
    leftJoystick = LeftJoystick();
    leftJoystick.anchor = Anchor.center;
    leftJoystick.position = Vector2(
        ((deviceWidth / 2) - 320 - deviceWidth * 0.027), (deviceHeight / 2));
    rightJoystick = RightJoystick();
    rightJoystick.position = Vector2(
        ((deviceWidth / 2) + 320 + deviceWidth * 0.027), deviceHeight / 2);
    rightJoystick.anchor = Anchor.center;

    leftJoystickTextComponent = TextComponent(
      text: "Move",
      anchor: Anchor.center,
      position: Vector2(((deviceWidth / 2) - 320 - deviceWidth * 0.027),
          (deviceHeight / 2) - 60),
    );

    rightJoystickTextComponent = TextComponent(
      text: "Shoot",
      anchor: Anchor.center,
      position: Vector2(((deviceWidth / 2) + 320 + deviceWidth * 0.027),
          (deviceHeight / 2) - 60),
    );
    addAll([
      leftJoystick,
      rightJoystick,
      leftJoystickTextComponent,
      rightJoystickTextComponent
    ]);
  }
}

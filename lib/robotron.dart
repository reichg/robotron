import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:robotron/components/joystick/left_joystick.dart';
import 'package:robotron/components/joystick/right_joystick.dart';
import 'package:robotron/levels/level.dart';

class Robotron extends FlameGame {
  @override
  Color backgroundColor() => Color(0xFF211F30);
  late final CameraComponent cam;
  late final LeftJoystick leftJoystick;
  late final RightJoystick rightJoystick;
  late TextComponent leftJoystickTextComponent;
  late TextComponent rightJoystickTextComponent;
  bool gameOver = false;

  static final Size screenSize = WidgetsBinding.instance.window.physicalSize;
  static final double aspectRatio =
      WidgetsBinding.instance.window.devicePixelRatio;
  final double deviceWidth = screenSize.width / aspectRatio;
  final double deviceHeight = screenSize.height / aspectRatio;

  final world = Level(levelName: 'level-02');

  @override
  FutureOr<void> onLoad() async {
    //images to cache
    await images.loadAllImages();
    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;

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

    // overlays.add('Main Menu');
    addAll([
      cam,
      world,
      leftJoystick,
      rightJoystick,
      leftJoystickTextComponent,
      rightJoystickTextComponent
    ]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}

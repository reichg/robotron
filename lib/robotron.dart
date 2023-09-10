import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    leftJoystick.position = Vector2(68, 200);

    rightJoystick = RightJoystick();
    rightJoystick.position = Vector2(770, 200);
    rightJoystick.anchor = Anchor.center;

    leftJoystickTextComponent = TextComponent(
      text: "Move",
      anchor: Anchor.center,
      position: Vector2(68, 140),
    );

    rightJoystickTextComponent = TextComponent(
      text: "Shoot",
      anchor: Anchor.center,
      position: Vector2(768, 140),
    );

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
}

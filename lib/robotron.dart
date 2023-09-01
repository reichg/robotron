import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:robotron/joystick/left_joystick.dart';
import 'package:robotron/joystick/right_joystick.dart';
import 'package:robotron/levels/level.dart';

class Robotron extends FlameGame {
  @override
  Color backgroundColor() => Color(0xFF211F30);
  late final CameraComponent cam;
  late final LeftJoystick leftJoystick;
  late final RightJoystick rightJoystick;

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
    rightJoystick = RightJoystick();
    addAll([cam, world, leftJoystick, rightJoystick]);

    return super.onLoad();
  }
}

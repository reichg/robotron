// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:robotron/levels/level.dart';

class Robotron extends FlameGame {
  final String levelName;

  Color backgroundColor() => Color(0xFF211F30);
  late final CameraComponent cam;
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
      width: deviceWidth,
      height: deviceHeight,
    );
    cam.viewfinder.anchor = Anchor.center;

    addAll([
      cam,
      world,
    ]);

    return super.onLoad();
  }

  Future<void> loadWorld() async {
    world = Level(levelName: levelName);
  }
}

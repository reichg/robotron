import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class LeftJoystick extends JoystickComponent {
  LeftJoystick()
      : super(
          knob: CircleComponent(
            radius: 32,
            paint: BasicPalette.blue.withAlpha(200).paint(),
          ),
          background: CircleComponent(
            radius: 24,
            paint: BasicPalette.blue.withAlpha(200).paint(),
          ),
          // margin: const EdgeInsets.only(left: 30, bottom: 30),
          position: Vector2(70, 180),
          anchor: Anchor.center,
        );
}

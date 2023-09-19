import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class LeftJoystick extends JoystickComponent {
  LeftJoystick()
      : super(
          knob: CircleComponent(
            radius: 32,
            paint: BasicPalette.blue.withAlpha(200).paint(),
          ),
          size: 64,
          // margin: const EdgeInsets.only(left: 30, bottom: 30),
          position: Vector2(70, 180),
          anchor: Anchor.center,
          knobRadius: 16,
        );
}

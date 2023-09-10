import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class RightJoystick extends JoystickComponent {
  RightJoystick()
      : super(
          knob: CircleComponent(
            radius: 32,
            paint: BasicPalette.blue.withAlpha(200).paint(),
          ),
          size: 64,
          position: Vector2(750, 180),
          anchor: Anchor.center,
          knobRadius: 7,
        );
}

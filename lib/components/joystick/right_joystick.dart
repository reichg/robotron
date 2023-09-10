import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class RightJoystick extends JoystickComponent {
  RightJoystick()
      : super(
          knob: CircleComponent(
            radius: 32,
            paint: BasicPalette.blue.withAlpha(200).paint(),
          ),
          background: CircleComponent(
            radius: 12,
            paint: BasicPalette.blue.withAlpha(200).paint(),
          ),
          position: Vector2(750, 180),
          anchor: Anchor.center,
        );
}

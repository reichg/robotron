import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:robotron/robotron.dart';

enum PlayerState { idle }

class GunPowerup extends SpriteAnimationGroupComponent
    with HasGameRef<Robotron>, CollisionCallbacks {
  late final String character;
  late final SpriteAnimation idleAnimation;
  bool collided = false;

  GunPowerup({
    required position,
    required anchor,
  }) : super(position: position, anchor: anchor);

  @override
  // ignore: overridden_fields
  // bool debugMode = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle');

    //List all animations
    animations = {
      PlayerState.idle: idleAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Arrow/$state (18x18).png'),
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.05,
        textureSize: Vector2.all(18),
      ),
    );
  }
}

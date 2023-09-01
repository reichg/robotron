import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:robotron/collision/collision_objects.dart';
import 'package:robotron/robotron.dart';

enum PlayerState { idle, running }

class Character extends SpriteAnimationGroupComponent
    with HasGameRef<Robotron>, CollisionCallbacks {
  String character;

  Character({position, anchor, required this.character})
      : super(position: position, anchor: anchor);
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;
  double moveSpeed = 180;
  bool isFacingLeft = false;
  bool collisionLeft = false;
  bool collisionRight = false;
  bool collisionUp = false;
  bool collisionDown = false;

  @override
  bool debugMode = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    super.onCollision(intersectionPoints, other);
    if (other is CollisionObject) {}
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    // TODO: implement onCollisionEnd
    super.onCollisionEnd(other);
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool moveLeft = gameRef.leftJoystick.relativeDelta[0] < 0;
    bool moveRight = gameRef.leftJoystick.relativeDelta[0] > 0;
    bool moveUp = gameRef.leftJoystick.relativeDelta[1] < 0;
    bool moveDown = gameRef.leftJoystick.relativeDelta[1] > 0;
    double vecX = (gameRef.leftJoystick.relativeDelta * moveSpeed * dt)[0];
    double vecY = (gameRef.leftJoystick.relativeDelta * moveSpeed * dt)[1];

    // horizontal movement bounds
    if ((moveLeft && position.x > 16 && collisionLeft == false) ||
        (moveRight &&
            position.x <
                gameRef.cam.viewport.camera.visibleWorldRect.right - 16 &&
            collisionRight == false)) {
      position.add(
        Vector2(vecX, 0),
      );
    }

    //vertical movement bounds
    if ((moveUp && position.y > 16 && collisionUp == false) ||
        (moveDown &&
            position.y <
                gameRef.cam.viewport.camera.visibleWorldRect.bottom - 16 &&
            collisionDown == false)) {
      position.add(
        Vector2(0, vecY),
      );
    }
    if (gameRef.leftJoystick.relativeDelta[0] < 0 && isFacingLeft == false) {
      flipHorizontallyAroundCenter();
      isFacingLeft = true;
    }
    if (gameRef.leftJoystick.relativeDelta[0] > 0 && isFacingLeft == true) {
      flipHorizontallyAroundCenter();
      isFacingLeft = false;
    }

    if (gameRef.leftJoystick.direction == JoystickDirection.idle) {
      current = PlayerState.idle;
    } else {
      current = PlayerState.running;
    }
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);

    runningAnimation = _spriteAnimation('Run', 12);

    //List all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
    };

    // Set current animation
    current = PlayerState.running;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
}

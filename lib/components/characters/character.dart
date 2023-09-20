import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_noise/flame_noise.dart';
import 'package:flutter/material.dart';
import 'package:robotron/components/Powerups/gun_powerup.dart';
import 'package:robotron/components/characters/enemy_character.dart';
import 'package:robotron/components/collision/collision_objects.dart';
import 'package:robotron/robotron.dart';

enum PlayerState { idle, running }

class MainCharacter extends SpriteAnimationGroupComponent
    with HasGameRef<Robotron>, CollisionCallbacks {
  String character;

  MainCharacter({position, anchor, required this.character})
      : super(position: position, anchor: anchor);
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  bool isFacingLeft = false;
  final double stepTime = 0.05;
  double moveSpeed = 70;
  bool collided = false;
  bool gunPowerupEnabled = false;
  int score = 0;
  int health = 100;
  Timer gunPowerupTimer = Timer(8);

  static final Size screenSize = WidgetsBinding.instance.window.physicalSize;
  static final double aspectRatio =
      WidgetsBinding.instance.window.devicePixelRatio;
  final double deviceWidth = screenSize.width / aspectRatio;
  final double deviceHeight = screenSize.height / aspectRatio;

  Vector2 bottomLeft = Vector2(63, 304);
  Vector2 topRight = Vector2(576, 47);

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
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CollisionObject) {
      if (intersectionPoints.length == 2) {
        var pointA = intersectionPoints.elementAt(0);
        var pointB = intersectionPoints.elementAt(1);
        final mid = (pointA + pointB) / 2;
        final collisionVector = absoluteCenter - mid;
        // collided = true;
        if (pointA.x == pointB.x || pointA.y == pointB.y) {
          // Hitting a side without touching a corner
          double penetrationDepth = (size.x / 2) - collisionVector.length;
          collisionVector.normalize();
          position += collisionVector.scaled(penetrationDepth);
        } else {
          position += _cornerBumpDistance(collisionVector, pointA, pointB);
        }
      }
    }
    if (other is GunPowerup) {
      gunPowerupEnabled = true;
      gunPowerupTimer.start();
      other.removeFromParent();
    }
    if (other is EnemyCharacter) {
      gameRef.cam.viewfinder.add(
        MoveEffect.by(
          Vector2(5, 5),
          PerlinNoiseEffectController(duration: 0.2, frequency: 400),
        ),
      );
      health -= 25;

      other.removeFromParent();
      if (health < 0) {
        health = 0;
      }

      gameRef.world.healthTextComponent.text = "Health: ${health.toString()}%";
      gameRef.world.healthBar.width = 150 * (health.toDouble() / 100);
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    // TODO: implement onCollisionEnd
    super.onCollisionEnd(other);
    collided = false;
    JoystickDirection.idle;
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

    // horizontal movement left
    if (moveLeft && position.x > width / 2 && !collided) {
      x += vecX;
    }
    // horizontal movement right
    if (moveRight &&
        position.x <
            gameRef.cam.viewport.camera.visibleWorldRect.right - width / 2 &&
        !collided) {
      x += vecX;
    }

    //vertical movement up
    if (moveUp && position.y > height / 2 && !collided) {
      y += vecY;
    }
    //vertical movement down
    if (moveDown &&
        position.y <
            gameRef.cam.viewport.camera.visibleWorldRect.bottom - height / 2 &&
        !collided) {
      y += vecY;
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

    gunPowerupTimer.update(dt);
    if (gunPowerupTimer.finished) {
      gunPowerupEnabled = false;
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

  Vector2 _cornerBumpDistance(
      Vector2 directionVector, Vector2 pointA, Vector2 pointB) {
    var dX = pointA.x - pointB.x;
    var dY = pointA.y - pointB.y;
    // The order of the two intersection points differs per corner
    // The following if statements negates the necessary values to make the
    // player move back to the right position
    if (directionVector.x > 0 && directionVector.y < 0) {
      // Top right corner
      dX = -dX;
    } else if (directionVector.x > 0 && directionVector.y > 0) {
      // Bottom right corner
      dX = -dX;
    } else if (directionVector.x < 0 && directionVector.y > 0) {
      // Bottom left corner
      dY = -dY;
    } else if (directionVector.x < 0 && directionVector.y < 0) {
      // Top left corner
      dY = -dY;
    }
    // The absolute smallest of both values determines from which side the player bumps
    // and therefor determines the needed displacement
    if (dX.abs() < dY.abs()) {
      return Vector2(dX, 0);
    } else {
      return Vector2(0, dY);
    }
  }

  void reset() {
    MainCharacter character = gameRef.world.character;
    character.health = 100;
    character.position = Vector2(
      topRight.x - ((topRight.x - bottomLeft.x) / 2),
      bottomLeft.y - ((bottomLeft.y - topRight.y) / 2),
    );
    gameRef.world.healthTextComponent.text = "Health: $health%";
    gameRef.world.healthBar.width = 150 * (health.toDouble() / 100);
    gameRef.world.character.score = 0;
    gameRef.world.scoreTextComponent.text = "Score: $score";
  }
}

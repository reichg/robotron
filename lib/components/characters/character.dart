import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_noise/flame_noise.dart';
import 'package:flutter/material.dart';
import 'package:robotron/components/Powerups/gun_powerup.dart';
import 'package:robotron/components/characters/enemy_character.dart';
import 'package:robotron/robotron.dart';
import 'package:robotron/utils/movement_utils.dart';

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
  bool gunPowerupEnabled = false;
  int health = 100;
  Timer gunPowerupTimer = Timer(8);
  CollisionMovementChecker movementChecker = CollisionMovementChecker();

  // Screen size calculations
  static final Size screenSize = Robotron.screenSize;
  static final double aspectRatio = Robotron.aspectRatio;
  final double deviceWidth = Robotron.deviceWidth;
  final double deviceHeight = Robotron.deviceHeight;

  Vector2 bottomLeft = Vector2(63, 304);
  Vector2 topRight = Vector2(576, 47);

  @override
  // ignore: overridden_fields
  // bool debugMode = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    add(
      RectangleHitbox(
        anchor: Anchor.center,
        position: Vector2(width / 2, height / 2),
        size: Vector2.all(16),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
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
      other.pathToMainCharacterVisualization.removeFromParent();
      other.removeFromParent();
      if (health < 0) {
        health = 0;
      }

      gameRef.world.healthTextComponent.text =
          "Health \n  ${health.toString()}%";
      gameRef.world.healthBar.width = 70 * (health.toDouble() / 100);
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final originalPosition = position.clone();

    double vecX =
        (gameRef.world.leftJoystick.relativeDelta * moveSpeed * dt)[0];
    double vecY =
        (gameRef.world.leftJoystick.relativeDelta * moveSpeed * dt)[1];

    final movementThisFrame = Vector2(vecX, vecY);

    movementChecker.checkMovement(
        component: this,
        movementThisFrame: movementThisFrame,
        originalPosition: originalPosition,
        collisionObjects: gameRef.world.collisionObjects);

    if (gameRef.world.leftJoystick.relativeDelta[0] < 0 &&
        isFacingLeft == false) {
      flipHorizontallyAroundCenter();
      isFacingLeft = true;
    }
    if (gameRef.world.leftJoystick.relativeDelta[0] > 0 &&
        isFacingLeft == true) {
      flipHorizontallyAroundCenter();
      isFacingLeft = false;
    }

    if (gameRef.world.leftJoystick.direction == JoystickDirection.idle) {
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

  void reset() {
    MainCharacter character = gameRef.world.character;
    character.health = 100;
    character.position = Vector2(
      topRight.x - ((topRight.x - bottomLeft.x) / 2),
      bottomLeft.y - ((bottomLeft.y - topRight.y) / 2),
    );
    gameRef.world.healthTextComponent.text = "Health \n  $health%";
    gameRef.world.healthBar.width = 70 * (health.toDouble() / 100);
  }
}

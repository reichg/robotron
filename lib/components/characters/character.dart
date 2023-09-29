import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/geometry.dart';
import 'package:flame_noise/flame_noise.dart';
import 'package:flame_tiled/flame_tiled.dart';
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
  bool collisionBottom = false;
  bool collisionTop = false;
  bool collisionLeft = false;
  bool collisionRight = false;

  // Screen size calculations
  static final Size screenSize = Robotron.screenSize;
  static final double aspectRatio = Robotron.aspectRatio;
  final double deviceWidth = Robotron.deviceWidth;
  final double deviceHeight = Robotron.deviceHeight;
  List<PositionComponent> collisionObjects = [];

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
    getCollisionComponents();
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
  void update(double dt) {
    super.update(dt);
    resetCollisions();

    final originalPosition = position.clone();

    double vecX = (gameRef.leftJoystick.relativeDelta * moveSpeed * dt)[0];
    double vecY = (gameRef.leftJoystick.relativeDelta * moveSpeed * dt)[1];

    final movementThisFrame = Vector2(vecX, vecY);

    for (final collisionObject in collisionObjects) {
      checkCollision(collisionObject, originalPosition, movementThisFrame);
      if (collided) {
        break;
      }
    }
    if (collisionBottom || collisionTop) {
      movementThisFrame.y = 0;
    }
    if (collisionLeft || collisionRight) {
      movementThisFrame.x = 0;
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

    position = originalPosition + movementThisFrame;
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
    gameRef.world.healthTextComponent.text = "Health: $health%";
    gameRef.world.healthBar.width = 150 * (health.toDouble() / 100);
    gameRef.world.character.score = 0;
    gameRef.world.scoreTextComponent.text = "Score: $score";
  }

  // Checks for collisions with all "CollisionObjects"
  void checkCollision(PositionComponent collisionComponent,
      Vector2 originalPosition, Vector2 movementThisFrame) {
    // Main character bounding coordinates for collisions before updating position.
    var rightThisFrameX = center.x + ((width - 10) / 2);
    var leftThisFrameX = center.x - ((width - 10) / 2);
    var topThisFrameY = center.y - ((height - 10) / 2);
    var bottomThisFrameY = center.y + ((height - 4) / 2);

    // Collision object bounds
    var collisionComponentRightX =
        collisionComponent.center.x + (collisionComponent.width / 2);
    var collisionComponentLeftX =
        collisionComponent.center.x - (collisionComponent.width / 2);
    var collisionComponentTopY =
        collisionComponent.center.y - (collisionComponent.height / 2);
    var collisionComponentBottomY =
        collisionComponent.center.y + (collisionComponent.height / 2);

    // Updated Main character bounds after joystick movement has been applied.
    var rightNextframeX = rightThisFrameX + movementThisFrame.x;
    var topNextframeY = topThisFrameY + movementThisFrame.y;
    var leftNextframeX = leftThisFrameX + movementThisFrame.x;
    var bottomNextFrameY = bottomThisFrameY + movementThisFrame.y;

    // No overlap between Main character and Collision Object.
    if (bottomNextFrameY < collisionComponentTopY ||
        topNextframeY > collisionComponentBottomY ||
        leftNextframeX > collisionComponentRightX ||
        rightNextframeX < collisionComponentLeftX) {
      return;
    }

    // Collision bottom check
    if (bottomNextFrameY >= collisionComponentTopY &&
        bottomThisFrameY < collisionComponentTopY) {
      collisionBottom = true;
    }
    // Collision top check
    else if (topNextframeY <= collisionComponentBottomY &&
        topThisFrameY > collisionComponentBottomY) {
      collisionTop = true;
    }
    // Collision right check
    else if (rightNextframeX >= collisionComponentLeftX &&
        rightThisFrameX < collisionComponentLeftX) {
      collisionRight = true;
    }
    // Collision left check
    else if (leftNextframeX <= collisionComponentRightX &&
        leftThisFrameX > collisionComponentRightX) {
      collisionLeft = true;
    }
  }

  // Adds all world CollisionObjects to $collisionObjects list for collision detection
  void getCollisionComponents() {
    collisionObjects.addAll(gameRef.world.children
        .where((element) => element is CollisionObject)
        .cast());
  }

  // If any collision occurs then collided is true
  void updateCollided() {
    if (collisionBottom || collisionLeft || collisionRight || collisionTop) {
      collided = true;
    }
  }

  // Resets all collision detection. Implemented at the beginning of each update frame.
  void resetCollisions() {
    collisionBottom = false;
    collisionLeft = false;
    collisionRight = false;
    collisionTop = false;
  }
}

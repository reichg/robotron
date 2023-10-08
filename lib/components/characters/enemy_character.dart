import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:robotron/components/bullet/bullet.dart';
import 'package:robotron/components/characters/character.dart';
import 'package:robotron/components/line/line_component.dart';
import 'package:robotron/robotron.dart';
import 'package:robotron/utils/movement_utils.dart';

enum PlayerState { running }

class EnemyCharacter extends SpriteAnimationGroupComponent
    with HasGameRef<Robotron>, CollisionCallbacks {
  String character;
  MainCharacter characterToChase;
  double moveSpeed;

  EnemyCharacter(
      {position,
      anchor,
      required this.character,
      required this.characterToChase,
      required this.moveSpeed})
      : super(position: position, anchor: anchor);

  bool collisionBottom = false;
  bool collisionTop = false;
  bool collisionRight = false;
  bool collisionLeft = false;
  bool collided = false;
  late final SpriteAnimation runningAnimation;
  late LineComponent pathToMainCharacter;
  bool isFacingLeft = false;
  final double stepTime = 0.05;

  CollisionMovementChecker movementChecker = CollisionMovementChecker();

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
    pathToMainCharacter = LineComponent(
      LineSegment(center, gameRef.world.character.center),
    );
    gameRef.world.add(pathToMainCharacter);

    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet) {
      removeFromParent();
      pathToMainCharacter.removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);

    current = PlayerState.running;
    LineSegment pathToPlayerLine =
        LineSegment(center, gameRef.world.character.center);
    Vector2 direction = (characterToChase.position - position).normalized();
    moveAlongPath(direction, pathToPlayerLine, dt);

    if (!isFacingLeft && direction[0] < 0) {
      flipHorizontallyAroundCenter();
      isFacingLeft = true;
    }
    if (isFacingLeft && direction[0] > 0) {
      flipHorizontallyAroundCenter();
      isFacingLeft = false;
    }
  }

  void _loadAllAnimations() {
    runningAnimation = _spriteAnimation('Run', 12);

    //List all animations
    animations = {
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

  // Controls path of zombie
  // Need to implement pathing to edge of collision object
  void moveAlongPath(Vector2 direction, LineSegment pathToPlayer, double dt) {
    final originalPosition = position.clone();
    final movementThisFrame = direction * dt * moveSpeed;

    getCollision(pathToPlayer);

    movementChecker.checkMovement(
        component: this,
        movementThisFrame: movementThisFrame,
        originalPosition: originalPosition,
        collisionObjects: gameRef.world.collisionObjects);
  }

  Line? getCollision(LineSegment pathToPlayer) {
    Vector2 nearestIntersection;
    double shortestLength;
    Line collisionBoundary;

    // To do
    // Complete zombie pathfinding here.
    for (final collisionBoundaryLine in gameRef.world.collisionBoundaries) {
      List<Vector2?> intersection =
          pathToPlayer.intersections(collisionBoundaryLine);
      if (intersection.isNotEmpty) {
        print("line: $collisionBoundaryLine");
        print("path to player: $pathToPlayer");
        print("intersection points: $intersection");
      }
    }
    return null;
  }
}

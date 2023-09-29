import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:robotron/components/bullet/bullet.dart';
import 'package:robotron/components/characters/character.dart';
import 'package:robotron/robotron.dart';

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
  late final SpriteAnimation runningAnimation;
  bool isFacingLeft = false;
  final double stepTime = 0.05;
  bool collided = false;

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
    if (other is Bullet) {
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    // TODO: implement onCollisionEnd
    super.onCollisionEnd(other);
    collided = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    current = PlayerState.running;
    Vector2 direction = (characterToChase.position - position).normalized();

    position += direction * dt * moveSpeed;
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
}

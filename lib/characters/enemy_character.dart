import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:robotron/bullet/bullet.dart';
import 'package:robotron/characters/character.dart';
import 'package:robotron/robotron.dart';

enum PlayerState { running }

class EnemyCharacter extends SpriteAnimationGroupComponent
    with HasGameRef<Robotron>, CollisionCallbacks {
  String character;
  Character characterToChase;

  EnemyCharacter(
      {position,
      anchor,
      required this.character,
      required this.characterToChase})
      : super(position: position, anchor: anchor);
  late final SpriteAnimation runningAnimation;
  bool isFacingLeft = false;
  final double stepTime = 0.05;
  double moveSpeed = 75;
  bool collided = false;

  @override
  // ignore: overridden_fields
  bool debugMode = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet) {
      print("Hit with bullet");
      other.removeFromParent();
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
    print("direction: $direction");
  }

  void _loadAllAnimations() {
    // idleAnimation = _spriteAnimation('Idle', 11);

    runningAnimation = _spriteAnimation('Run', 12);

    //List all animations
    animations = {
      // PlayerState.idle: idleAnimation,
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

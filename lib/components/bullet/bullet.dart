// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:robotron/components/characters/enemy_character.dart';
import 'package:robotron/components/collision/collision_objects.dart';

import 'package:robotron/robotron.dart';

class Bullet extends SpriteComponent
    with HasGameRef<Robotron>, CollisionCallbacks {
  final double vecX;
  final double vecY;

  Bullet({
    required this.vecX,
    required this.vecY,
  });

  // @override
  // bool debugMode = true;
  double speed = 150;

  @override
  FutureOr<void> onLoad() async {
    anchor = Anchor.center;
    sprite = Sprite(game.images.fromCache("Items/Bullet/Bullet.png"));
    size = Vector2.all(10);
    add(CircleHitbox(radius: 5));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CollisionObject) {
      removeFromParent();
    }
    if (other is EnemyCharacter) {
      removeFromParent();
      gameRef.world.killCountTotal += 1;
      gameRef.world.killCountThisRound += 1;
      gameRef.world.killCountTotalComponent.text =
          "Kills \n  ${gameRef.world.killCountTotal.toString()}";
      gameRef.world.killCountThisRoundComponent.text =
          "Round Kills: ${gameRef.world.killCountThisRound.toString()}";
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(
      Vector2(vecX * speed * dt, vecY * speed * dt),
    );
    if (position.x >
        gameRef.cam.viewport.camera.visibleWorldRect.right - width) {
      removeFromParent();
    }

    if (position.x <
        gameRef.cam.viewport.camera.visibleWorldRect.left + width) {
      removeFromParent();
    }

    if (position.y < gameRef.cam.viewport.camera.visibleWorldRect.top + width) {
      removeFromParent();
    }

    if (position.y >
        gameRef.cam.viewport.camera.visibleWorldRect.bottom - width) {
      removeFromParent();
    }
  }
}

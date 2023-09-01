import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:robotron/bullet/bullet.dart';
import 'package:robotron/characters/character.dart';
import 'package:robotron/collision/collision_objects.dart';
import 'package:robotron/joystick/right_joystick.dart';
import 'package:robotron/robotron.dart';

class Level extends World with HasGameRef<Robotron>, HasCollisionDetection {
  final String levelName;

  Level({required this.levelName});
  late TiledComponent level;
  late Character character;
  late RightJoystick rightJoystick;

  Timer bulletSpawnTimer = Timer(0.4, repeat: true);

  @override
  bool debugMode = true;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      "$levelName.tmx",
      Vector2.all(16),
    );
    rightJoystick = gameRef.rightJoystick;

    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case "Character":
          character = Character(
            character: 'Ninja Frog',
            position: Vector2(spawnPoint.x, spawnPoint.y),
            anchor: Anchor.center,
          );
          add(character);
          break;
        default:
      }
    }

    final collisionObjects =
        level.tileMap.getLayer<ObjectGroup>('collisionObjects');

    for (final collisionObject in collisionObjects!.objects) {
      add(
        CollisionObject(
          size: Vector2(collisionObject.width, collisionObject.height),
          position: Vector2(
            collisionObject.x,
            collisionObject.y,
          ),
        ),
      );
    }
    bulletSpawnTimer.start();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    bulletSpawnTimer.update(dt);
    bulletSpawnTimer.onTick = () {
      if (rightJoystick.direction != JoystickDirection.idle) {
        var intensity = gameRef.rightJoystick.intensity;
        if (intensity > .95) {
          double vecX = (gameRef.rightJoystick.relativeDelta)[0];
          double vecY = (gameRef.rightJoystick.relativeDelta)[1];
          var bullet = Bullet(vecX: vecX, vecY: vecY);
          bullet.anchor = Anchor.center;
          bullet.position = character.absoluteCenter;
          add(bullet);
        }
      }
    };
  }
}

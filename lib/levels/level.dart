import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:robotron/components/Powerups/gun_powerup.dart';
import 'package:robotron/components/bullet/bullet.dart';
import 'package:robotron/components/characters/character.dart';
import 'package:robotron/components/characters/enemy_character.dart';
import 'package:robotron/components/collision/collision_objects.dart';
import 'package:robotron/components/joystick/right_joystick.dart';
import 'package:robotron/components/screens/gameover_screen.dart';
import 'package:robotron/robotron.dart';

class Level extends World with HasGameRef<Robotron>, HasCollisionDetection {
  final String levelName;

  Level({required this.levelName});
  late TiledComponent level;
  late MainCharacter character;
  late RightJoystick rightJoystick;
  late TextComponent scoreTextComponent;
  late TextComponent healthTextComponent;
  late TextComponent countdownTextComponent;
  late TextComponent timeLeftTextComponent;
  late TextComponent newRoundTextComponent;
  late GunPowerup gunPowerup;

  Timer startCountdown = Timer(1, repeat: true, autoStart: false);
  Timer gameTimer = Timer(1, repeat: true, autoStart: false);
  Timer bulletSpawnTimer = Timer(0.2, repeat: true, autoStart: false);
  Timer enemySpawnTimer = Timer(2, repeat: true, autoStart: false);
  Timer betweenRoundTimer = Timer(1, repeat: true, autoStart: false);

  bool roundWin = false;
  int currentRound = 1;

  static final Size screenSize = WidgetsBinding.instance.window.physicalSize;
  static final double aspectRatio =
      WidgetsBinding.instance.window.devicePixelRatio;
  final double deviceWidth = screenSize.width / aspectRatio;
  final double deviceHeight = screenSize.height / aspectRatio;

  bool gameStarted = false;
  bool gameTimerStarted = false;
  int timerCountdownToStart = 3;
  int timeLeft = 45;
  bool gameOver = false;
  int timeBetweenRounds = 5;

  double enemyMoveSpeed = 70;

  RectangleComponent healthBar = RectangleComponent.fromRect(
    Rect.fromLTWH(405, 5, 150, 30),
    paint: Paint()..color = Colors.red.withOpacity(1),
  );

  int killCount = 0;
  int totalSpawned = 0;

  Random rnd = Random();

  Vector2 bottomLeft = Vector2(63, 304);
  Vector2 topRight = Vector2(576, 47);

  // @override
  // bool debugMode = true;

  @override
  FutureOr<void> onLoad() async {
    print(levelName);
    level = await TiledComponent.load(
      "$levelName.tmx",
      Vector2.all(16),
    );
    add(level);

    // final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    // for (final spawnPoint in spawnPointsLayer!.objects) {
    //   switch (spawnPoint.class_) {
    //     case "Character":
    //       character = MainCharacter(
    //         character: 'Ninja Frog',
    //         position: Vector2(spawnPoint.x, spawnPoint.y),
    //         anchor: Anchor.center,
    //       );
    //       add(character);
    //       break;
    //     default:
    //   }
    // }

    character = MainCharacter(
      character: "Ninja Frog",
      anchor: Anchor.center,
      position: Vector2(
        topRight.x - ((topRight.x - bottomLeft.x) / 2),
        bottomLeft.y - ((bottomLeft.y - topRight.y) / 2),
      ),
    );
    add(character);

    add(healthBar);
    scoreTextComponent = TextComponent(
        text: "Score: 0", anchor: Anchor.topLeft, position: Vector2(70, 10));
    add(scoreTextComponent);
    healthTextComponent = TextComponent(
      text: "Health: 100%",
      anchor: Anchor.topRight,
      position: Vector2(550, 5),
    );
    add(healthTextComponent);

    countdownTextComponent = TextComponent(
      text: "Countdown: 3",
      anchor: Anchor.center,
      position: Vector2(
        topRight.x - ((topRight.x - bottomLeft.x) / 2),
        bottomLeft.y - ((bottomLeft.y - topRight.y) / 2),
      ),
    );
    add(countdownTextComponent);

    timeLeftTextComponent = TextComponent(
      text: "Time Left: 5",
      anchor: Anchor.center,
      position:
          Vector2(topRight.x - ((topRight.x - bottomLeft.x) / 2) - 25, 15),
    );

    add(timeLeftTextComponent);

    List<double> gunPowerUpRandomCoords = _randomCoodinatePairInWorldbounds();
    gunPowerup = GunPowerup(
      position:
          Vector2(gunPowerUpRandomCoords.first, gunPowerUpRandomCoords.last),
      anchor: Anchor.center,
    );
    gunPowerup.position = Vector2(400, 270);
    add(gunPowerup);

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
    startCountdown.start();
    bulletSpawnTimer.start();
    gameTimer.start();
    enemySpawnTimer.start();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver) {
      gameRef.pauseEngine();
    }

    startCountdown.update(dt);
    startCountdown.onTick = () {
      if (timerCountdownToStart == 0) {
        gameStarted = true;
        countdownTextComponent.text = "GO!";
      }
      if (timerCountdownToStart > 0) {
        countdownTextComponent.text = "Countdown: $timerCountdownToStart";
      }
      if (timerCountdownToStart < 0) {
        gameTimer.start();
        enemySpawnTimer.start();
        bulletSpawnTimer.start();
        startCountdown.stop();
        countdownTextComponent.removeFromParent();
      }
      timerCountdownToStart -= 1;
    };
    startCountdown.isRunning()
        ? null
        : countdownTextComponent.removeFromParent();

    if (gameStarted) {
      gameTimer.update(dt);
      gameTimer.onTick = () {
        timeLeft -= 1;
        timeLeftTextComponent.text = "Time Left: $timeLeft";
        if (timeLeft == 0) {
          gameTimer.stop();
          gameOver = true;
        }
      };

      enemySpawnTimer.update(dt);
      enemySpawnTimer.onTick = () {
        if (totalSpawned < 5) {
          List<double> coordinates =
              _randomCoodinatePairInWorldbounds100PxFromMainCharacter(
                  characterLocation: gameRef.world.character.position);
          var enemyCharacter = EnemyCharacter(
              character: "Pink Man",
              anchor: Anchor.center,
              position: Vector2(coordinates.first, coordinates.last),
              characterToChase: character,
              moveSpeed: enemyMoveSpeed);

          add(enemyCharacter);
          totalSpawned += 1;
        }
      };

      if (gameRef.world.character.score == 1) {
        roundWin = true;
      }

      character.gunPowerupEnabled
          ? bulletSpawnTimer.limit = 0.1
          : bulletSpawnTimer.limit = 0.2;

      bulletSpawnTimer.update(dt);

      bulletSpawnTimer.onTick = () {
        if (gameRef.rightJoystick.direction != JoystickDirection.idle) {
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

      if (roundWin) {
        betweenRoundsGameState();
        betweenRoundTimer.start();
        betweenRoundTimer.update(dt);

        roundWin = false;
      }
      if (betweenRoundTimer.isRunning()) {
        betweenRoundTimer.update(dt);
        betweenRoundTimer.onTick = () {
          timeBetweenRounds -= 1;
          if (timeBetweenRounds > 2) {}
          if (timeBetweenRounds <= 0) {
            startRound();
            increaseDifficulty();
            betweenRoundTimer.stop();
            newRoundTextComponent.removeFromParent();
          }
        };
      }

      if (gameRef.world.character.health <= 0) {
        gameOver = true;
      }

      if (gameOver) {
        gameRef.overlays.add(GameOverScreen.ID);
      }
    }
  }

  // Get random coordinate pair within the playable world bounds
  List<double> _randomCoodinatePairInWorldbounds() {
    double randomX = 66 + rnd.nextInt(545 - 63).toDouble();
    double randomY = 44 + rnd.nextInt(304 - 44).toDouble();
    List<double> coordinates = [randomX, randomY];

    return coordinates;
  }

  // Get position for enemy spawn that is 125 units away and in playable world bounds
  List<double> _randomCoodinatePairInWorldbounds100PxFromMainCharacter(
      {required Vector2 characterLocation}) {
    double randomX = 66 + rnd.nextInt(545 - 66).toDouble();
    double randomY = 44 + rnd.nextInt(304 - 44).toDouble();
    List<double> coordinates = [randomX, randomY];
    var distance = Vector2(coordinates.first, coordinates.last)
        .distanceTo(characterLocation);

    if (distance > 125) {
      return coordinates;
    }

    return _randomCoodinatePairInWorldbounds100PxFromMainCharacter(
        characterLocation: characterLocation);
  }

  void betweenRoundsGameState() {
    reset();

    currentRound += 1;
    newRoundTextComponent = TextComponent(
      text: "Round #$currentRound",
      anchor: Anchor.center,
      position: Vector2(
        topRight.x - ((topRight.x - bottomLeft.x) / 2),
        bottomLeft.y - ((bottomLeft.y - topRight.y) / 2),
      ),
    );
    add(newRoundTextComponent);
    betweenRoundTimer.start();
  }

  void startRound() {
    startCountdown.start();
    countdownTextComponent.text = "Countdown: $timerCountdownToStart";
    add(countdownTextComponent);
  }

  void reset() {
    for (var child in gameRef.world.children) {
      if (child is Bullet || child is EnemyCharacter) {
        child.removeFromParent();
      }
    }
    character.reset();

    timeLeft = 45;
    totalSpawned = 0;
    timerCountdownToStart = 3;
    timeBetweenRounds = 5;
    gameRef.world.timeLeftTextComponent.text = "Time Left: $timeLeft";
    character.reset();
    startCountdown.stop();
    gameTimer.stop();
    enemySpawnTimer.stop();
  }

  void increaseDifficulty() {
    if (gameRef.world.enemySpawnTimer.limit - 0.259 > 0) {
      gameRef.world.enemySpawnTimer.limit -= 0.25;
    }
    enemyMoveSpeed += 20;
  }
}

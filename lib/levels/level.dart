import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'package:flutter/material.dart';
import 'package:pathfinding/finders/astar.dart';
import 'package:robotron/components/Powerups/gun_powerup.dart';
import 'package:robotron/components/bullet/bullet.dart';
import 'package:robotron/components/characters/character.dart';
import 'package:robotron/components/characters/enemy_character.dart';
import 'package:robotron/components/collision/collision_objects.dart';
import 'package:robotron/components/joystick/left_joystick.dart';
import 'package:robotron/components/joystick/right_joystick.dart';
import 'package:robotron/components/line/line_component.dart';
import 'package:robotron/components/screens/gameover_screen.dart';
import 'package:robotron/robotron.dart';

class Level extends World with HasGameRef<Robotron>, HasCollisionDetection {
  final String levelName;

  Level({required this.levelName});

  // Components
  late TiledComponent level;
  late MainCharacter character;
  late TextComponent healthTextComponent;
  late TextComponent countdownTextComponent;
  late TextComponent timeLeftTextComponent;
  late TextComponent newRoundTextComponent;
  late TextComponent currentRoundTextComponent;
  late TextComponent killCountTotalComponent;
  late TextComponent killCountThisRoundComponent;
  late RectangleComponent healthBar;
  late LineComponent visualPathToPlayerFromEnemy;
  late GunPowerup gunPowerup;
  late int worldTileSize;

  late final LeftJoystick leftJoystick;
  late final RightJoystick rightJoystick;
  late TextComponent leftJoystickTextComponent;
  late TextComponent rightJoystickTextComponent;

  // Game information
  bool gameStarted = false;
  bool gameTimerStarted = false;
  bool gameOver = false;
  int timerCountdownToStart = 3;
  int timeLeft = 20;
  int timeBetweenRounds = 5;
  double enemyMoveSpeed = 30;
  int killCountTotal = 0;
  int killCountThisRound = 0;
  int totalSpawned = 0;
  int spawnLimit = 10;
  var grid = <List<int>>[];

  // Pathfinder
  AStarFinder pathfinder =
      AStarFinder(dontCrossCorners: true, allowDiagonal: true);

  // All Game Timers
  Timer startCountdown = Timer(1, repeat: true, autoStart: false);
  Timer gameTimer = Timer(1, repeat: true, autoStart: false);
  Timer bulletSpawnTimer = Timer(0.2, repeat: true, autoStart: false);
  Timer enemySpawnTimer = Timer(2, repeat: true, autoStart: false);
  Timer betweenRoundTimer = Timer(1, repeat: true, autoStart: false);

  // Round information
  bool roundWin = false;
  int currentRound = 1;

  // Will be used for zombie movement calculations
  List<LineSegment> collisionBoundaries = [];
  List<PositionComponent> collisionObjects = [];

  // Screen size calculations
  static final Size screenSize = Robotron.screenSize;
  static final double aspectRatio = Robotron.aspectRatio;
  final double deviceWidth = Robotron.deviceWidth;
  final double deviceHeight = Robotron.deviceHeight;

  // Viewport coordinates
  late Vector2 bottomLeft;
  late Vector2 topRight;

  Random rnd = Random();

  // @override
  // bool debugMode = true;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      "$levelName.tmx",
      Vector2.all(16),
    );

    add(level);

    topRight = level.positionOfAnchor(Anchor.topRight);

    bottomLeft = level.positionOfAnchor(Anchor.bottomLeft);

    // Create components
    createJoysticksAndText();
    createCollisionObjects();
    createHealthBar();
    createCharacter();
    createTextComponents();
    createGunPowerup();
    getCollisionComponents();
    getCollisionBoundaries();
    createGrid();

    // level.position = Vector2(
    //     (deviceWidth - level.width) / 2, (deviceHeight - level.height) / 2);
    print("$deviceHeight, $deviceWidth, $screenSize");
    gameRef.cam.viewfinder.position =
        Vector2(level.width / 2, level.height / 2);
    // print("top right: $topRight, bottom left: $bottomLeft");
    // print("level width: ${level.width}, level height: ${level.height}");
    worldTileSize = 16;

    // Start timers
    startCountdown.start();
    bulletSpawnTimer.start();
    gameTimer.start();
    enemySpawnTimer.start();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    clearLineComponents();
    // If gameover pause the engine
    if (gameOver) {
      gameRef.pauseEngine();
    }

    // 3 second countdown to start of game
    startCountdown.update(dt);
    startCountdown.onTick = () {
      // Add "go" text at 0
      if (timerCountdownToStart == 0) {
        countdownTextComponent.text = "GO!";
      }

      // Countdown text is number until 0
      if (timerCountdownToStart > 0) {
        countdownTextComponent.text = "Countdown: $timerCountdownToStart";
      }

      // After "go" start all timers and game and remove countdown text
      if (timerCountdownToStart < 0) {
        gameStarted = true;
        gameTimer.start();
        enemySpawnTimer.start();
        bulletSpawnTimer.start();
        startCountdown.stop();
        countdownTextComponent.removeFromParent();
      }
      timerCountdownToStart -= 1;
    };

    if (gameStarted) {
      // Round timer
      gameTimer.update(dt);
      gameTimer.onTick = () {
        timeLeft -= 1;
        timeLeftTextComponent.text = "Time: $timeLeft";
        if (timeLeft == 0) {
          gameTimer.stop();
          gameOver = true;
        }
      };

      // Controls enemy spawn time
      enemySpawnTimer.update(dt);
      enemySpawnTimer.onTick = () {
        if (totalSpawned < spawnLimit) {
          createEnemyCharacter();
        }
      };

      // Controls when a round is won
      if (killCountThisRound == 5) {
        roundWin = true;
      }

      // Enables gun powerup
      character.gunPowerupEnabled
          ? bulletSpawnTimer.limit = 0.1
          : bulletSpawnTimer.limit = 0.2;

      // Controls bullet spawn time
      bulletSpawnTimer.update(dt);
      bulletSpawnTimer.onTick = () {
        if (gameRef.world.rightJoystick.direction != JoystickDirection.idle) {
          var intensity = gameRef.world.rightJoystick.intensity;

          // Want all bullets moving same speed so added the joystick intensity
          if (intensity > .95) {
            createBullet();
          }
        }
      };

      // Set between round state if round won
      if (roundWin) {
        betweenRoundsGameState();
        betweenRoundTimer.start();
        betweenRoundTimer.update(dt);
        roundWin = false;
      }

      // Intermission between rounds then start round and increase difficulty.
      if (betweenRoundTimer.isRunning()) {
        betweenRoundTimer.update(dt);
        betweenRoundTimer.onTick = () {
          timeBetweenRounds -= 1;

          if (timeBetweenRounds <= 0) {
            startRound();
            increaseDifficulty();
            betweenRoundTimer.stop();
            newRoundTextComponent.removeFromParent();
          }
        };
      }

      // Game over if health goes to zero
      if (gameRef.world.character.health <= 0) {
        gameOver = true;
      }

      // Show game over overlay if gameover
      if (gameOver) {
        gameRef.overlays.add(GameOverScreen.ID);
      }
    }
  }

  // Get position for enemy spawn that is 125 units away and in playable world bounds
  List<double> _randomCoodinatePairInWorldbounds125PxFromMainCharacter(
      {required Vector2 characterLocation}) {
    double randomX = 66 + rnd.nextInt(545 - 66).toDouble();
    double randomY = 44 + rnd.nextInt(304 - 44).toDouble();
    List<double> coordinates = [randomX, randomY];
    var distance = Vector2(coordinates.first, coordinates.last)
        .distanceTo(characterLocation);
    for (var child in children) {
      if (child is CollisionObject) {
        if (child
            .containsLocalPoint(Vector2(coordinates.first, coordinates.last))) {
          return _randomCoodinatePairInWorldbounds125PxFromMainCharacter(
              characterLocation: characterLocation);
        }
      }
    }
    if (distance > 125) {
      // print(coordinates);
      return coordinates;
    }

    return _randomCoodinatePairInWorldbounds125PxFromMainCharacter(
        characterLocation: characterLocation);
  }

  // Set state between rounds, resetting positions, score, health, etc
  void betweenRoundsGameState() {
    reset();

    currentRound += 1;
    currentRoundTextComponent.text = "Round: $currentRound";
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

  // Start round with countdown timer and add countdown text back to game
  void startRound() {
    startCountdown.start();
    countdownTextComponent.text = "Countdown: $timerCountdownToStart";
    add(countdownTextComponent);
  }

  // Reset game, remove enemies and bullets, stop timers, spawn count, ect
  void reset() {
    startCountdown.stop();
    gameTimer.stop();
    enemySpawnTimer.stop();
    character.reset();
    for (var child in children) {
      if (child is Bullet ||
          child is EnemyCharacter ||
          child is LineComponent) {
        remove(child);
      }
    }
    killCountThisRound = 0;
    timeLeft = 45;
    totalSpawned = 0;
    timerCountdownToStart = 3;
    timeBetweenRounds = 5;
    gameRef.world.timeLeftTextComponent.text = "Time: $timeLeft";
    gameRef.world.killCountThisRoundComponent.text =
        "Round Kills: ${killCountThisRound.toString()}";
  }

  // Increase enemy move speed by 20 units and decrease enemy spawn time each round
  void increaseDifficulty() {
    if (gameRef.world.enemySpawnTimer.limit - 0.259 > 0) {
      gameRef.world.enemySpawnTimer.limit -= 0.25;
    }
    if (enemyMoveSpeed < 50) {
      enemyMoveSpeed += 5;
    }
    if (spawnLimit < 25) {
      spawnLimit += 2;
    }
  }

  // Create all text components in the game (score, health, countdown, and time left)
  void createTextComponents() {
    killCountTotalComponent = TextComponent(
        textRenderer: TextPaint(
            style: TextStyle(
          fontSize: 25,
        )),
        text: """Kills\n  $killCountTotal""",
        anchor: Anchor.topLeft,
        position: Vector2((deviceWidth - level.width) / 2 - 60,
            ((deviceHeight - level.height) / 2) + 20));
    gameRef.add(killCountTotalComponent);

    killCountThisRoundComponent = TextComponent(
        textRenderer: TextPaint(style: TextStyle(fontSize: 20)),
        text: "Round Kills: $killCountThisRound",
        anchor: Anchor.topLeft,
        position:
            Vector2(topRight.x - ((topRight.x - bottomLeft.x) / 2) + 30, 320));
    add(killCountThisRoundComponent);

    healthTextComponent = TextComponent(
        textRenderer: TextPaint(style: TextStyle(fontSize: 23)),
        text: "Health \n ${gameRef.world.character.health}%",
        anchor: Anchor.topRight,
        position: Vector2((deviceWidth + level.width) / 2 + 70,
            ((deviceHeight - level.height) / 2) + 20));
    gameRef.add(healthTextComponent);

    currentRoundTextComponent = TextComponent(
      textRenderer: TextPaint(style: TextStyle(fontSize: 20)),
      text: "Round: 1",
      anchor: Anchor.topCenter,
      position:
          Vector2(topRight.x - ((topRight.x - bottomLeft.x) / 2) - 100, 320),
    );
    add(currentRoundTextComponent);

    countdownTextComponent = TextComponent(
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 23,
          background: Paint()..color = const Color.fromARGB(141, 0, 0, 0),
        ),
      ),
      text: "Countdown: 3",
      anchor: Anchor.center,
      position: Vector2(
        topRight.x - ((topRight.x - bottomLeft.x) / 2),
        bottomLeft.y - ((bottomLeft.y - topRight.y) / 2),
      ),
    );
    add(countdownTextComponent);

    timeLeftTextComponent = TextComponent(
        text: "Time: $timeLeft",
        anchor: Anchor.center,
        position: Vector2((deviceWidth) / 2, 50));

    gameRef.add(timeLeftTextComponent);
  }

  // Create character and add to game
  void createCharacter() {
    character = MainCharacter(
      character: "Ninja Frog",
      anchor: Anchor.center,
      position: Vector2(
        topRight.x - ((topRight.x - bottomLeft.x) / 2),
        bottomLeft.y - ((bottomLeft.y - topRight.y) / 2),
      ),
    );
    add(character);
  }

  // Create gun powerup and add to game
  void createGunPowerup() {
    List<double> gunPowerUpRandomCoords =
        _randomCoodinatePairInWorldbounds125PxFromMainCharacter(
            characterLocation: character.position);
    gunPowerup = GunPowerup(
      position:
          Vector2(gunPowerUpRandomCoords.first, gunPowerUpRandomCoords.last),
      anchor: Anchor.center,
    );

    add(gunPowerup);
  }

  // Create collision objects and add to game
  void createCollisionObjects() {
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
  }

  void createEnemyCharacter() {
    // must put coordinates back into spawn point.
    //coordinates.first, coordinates.last
    List<double> coordinates =
        _randomCoodinatePairInWorldbounds125PxFromMainCharacter(
            characterLocation: gameRef.world.character.position);
    var enemyCharacter = EnemyCharacter(
        character: "Pink Man",
        anchor: Anchor.center,
        position: Vector2(coordinates.first, coordinates.last),
        characterToChase: character,
        moveSpeed: enemyMoveSpeed,
        aStarPathfinder: pathfinder);

    add(enemyCharacter);
    totalSpawned += 1;
  }

  void createBullet() {
    double vecX = (gameRef.world.rightJoystick.relativeDelta)[0];
    double vecY = (gameRef.world.rightJoystick.relativeDelta)[1];
    var bullet = Bullet(vecX: vecX, vecY: vecY);
    bullet.anchor = Anchor.center;
    bullet.position = character.absoluteCenter;
    add(bullet);
  }

  void createHealthBar() {
    // Healthbar visual
    healthBar = RectangleComponent.fromRect(
      Rect.fromLTWH(638, 45, 70, 30),
      paint: Paint()..color = Colors.red.withOpacity(1),
    );
    add(healthBar);
  }

  // Adds all world CollisionObjects to $collisionObjects list for collision detection
  void getCollisionComponents() {
    collisionObjects.addAll(gameRef.world.children
        .where((element) => element is CollisionObject)
        .cast());
  }

  // Get collision boundaries for zombie movement calculation
  void getCollisionBoundaries() {
    for (final child in gameRef.world.children) {
      if (child is CollisionObject) {
        LineSegment right = LineSegment(
            child.positionOfAnchor(Anchor.bottomRight),
            child.positionOfAnchor(Anchor.topRight));
        LineSegment left = LineSegment(
            child.positionOfAnchor(Anchor.bottomLeft),
            child.positionOfAnchor(Anchor.topLeft));
        LineSegment bottom = LineSegment(
            child.positionOfAnchor(Anchor.bottomLeft),
            child.positionOfAnchor(Anchor.bottomRight));
        LineSegment top = LineSegment(child.positionOfAnchor(Anchor.topLeft),
            child.positionOfAnchor(Anchor.topRight));

        collisionBoundaries.addAll([right, left, bottom, top]);
      }
    }
  }

  void createGrid() {
    int walkableTile = getWalkableTileInteger(levelName);
    TileLayer background =
        level.tileMap.getLayer<TileLayer>("background") as TileLayer;

    var tileData = background.tileData;
    for (int i = 0; i < background.tileData!.length; i++) {
      final row = <int>[];
      for (int j = 0; j < background.tileData!.first.length; j++) {
        var tile = tileData![i][j].tile == walkableTile ? 0 : 1;
        row.add(tile);
      }

      grid.add(row);
    }
  }

  void clearLineComponents() {
    for (var child in children) {
      if (child is LineComponent) {
        remove(child);
      }
    }
  }

  int getWalkableTileInteger(String levelName) {
    switch (levelName) {
      case "level-01":
        return 118;
      case "level-02":
        return 24;
      default:
    }
    return 0;
  }

  // Create and add joysticks and their components to game.
  void createJoysticksAndText() {
    leftJoystick = LeftJoystick();
    leftJoystick.anchor = Anchor.center;
    leftJoystick.position =
        Vector2(((deviceWidth - level.width) / 2) - 32, deviceHeight / 2);
    rightJoystick = RightJoystick();
    rightJoystick.position =
        Vector2(((deviceWidth + level.width) / 2) + 32, deviceHeight / 2);
    rightJoystick.anchor = Anchor.center;

    leftJoystickTextComponent = TextComponent(
      text: "Move",
      anchor: Anchor.center,
      position: Vector2(
          ((deviceWidth - level.width) / 2) - 32, deviceHeight / 2 + 55),
    );

    rightJoystickTextComponent = TextComponent(
      text: "Shoot",
      anchor: Anchor.center,
      position: Vector2(
          ((deviceWidth + level.width) / 2) + 32, (deviceHeight / 2) + 55),
    );
    gameRef.addAll([
      leftJoystick,
      rightJoystick,
      leftJoystickTextComponent,
      rightJoystickTextComponent
    ]);
  }
}

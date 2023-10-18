import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:robotron/components/bullet/bullet.dart';
import 'package:robotron/components/characters/character.dart';
import 'package:robotron/components/line/line_component.dart';
import 'package:robotron/robotron.dart';
import 'package:robotron/utils/movement_utils.dart';

import 'package:pathfinding/finders/astar.dart';
import 'package:pathfinding/core/grid.dart';

enum PlayerState { running }

class EnemyCharacter extends SpriteAnimationGroupComponent
    with HasGameRef<Robotron>, CollisionCallbacks {
  String character;
  MainCharacter characterToChase;
  double moveSpeed;
  AStarFinder aStarPathfinder;

  EnemyCharacter(
      {position,
      anchor,
      required this.character,
      required this.characterToChase,
      required this.moveSpeed,
      required this.aStarPathfinder})
      : super(position: position, anchor: anchor);

  late Grid grid;
  late final SpriteAnimation runningAnimation;
  late LineComponent pathToMainCharacter;
  late LineSegment pathToPlayerLine;
  List<List<double>> path = [];
  List<LineComponent> visualizedPath = [];

  AStarFinder aStarFinder = AStarFinder();
  List<dynamic> nextMove = [];

  bool collisionBottom = false;
  bool collisionTop = false;
  bool collisionRight = false;
  bool collisionLeft = false;
  bool collided = false;

  bool isFacingLeft = false;
  final double stepTime = 0.05;
  LineSegment? collisionSegment;
  double delay = 0;
  bool turnedCorner = true;
  AStarFinder pathfinder =
      AStarFinder(dontCrossCorners: true, allowDiagonal: true);

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
      LineSegment(center, characterToChase.center),
    );
    pathToPlayerLine = LineSegment(center, characterToChase.center);
    gameRef.world.add(pathToMainCharacter);
    grid = Grid(gameRef.world.grid.first.length, gameRef.world.grid.length,
        gameRef.world.grid);

    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet) {
      pathToMainCharacter.removeFromParent();
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);
    removeLineComponents();
    path.clear();
    List<int> currentMainCharacterPosition = [
      (characterToChase.x.toInt() / 16).round(),
      (characterToChase.y.toInt() / 16).round()
    ];
    if (path.isEmpty || path.last != currentMainCharacterPosition) {
      // Recalculate the path when the AI reaches the current target or on startup
      final startPoint =
          Point(position.x.toInt() / 16, position.y.toInt() / 16);
      final endPoint = Point(
          characterToChase.x.toInt() / 16, characterToChase.y.toInt() / 16);
      List<dynamic> tempPath = pathfinder.findPath(
          startPoint.x.round(),
          startPoint.y.round(),
          endPoint.x.round(),
          endPoint.y.round(),
          grid.clone());

      convertAndAddCoordinatesToPath(tempPath, path);
    }

    if (path.isNotEmpty) {
      // Move the AI towards the next step in the path
      addAStarPathVisualization(path);

      // List<List<double>> pathCasted = path;
      final nextStep = path[1];
      // addAStarPathVisualization(path);

      current = PlayerState.running;
      LineSegment? pathToPlayerLine =
          LineSegment(center, characterToChase.position);

      Vector2 direction =
          (Vector2(nextStep[0].toDouble() * 16, nextStep[1].toDouble() * 16) -
                  position)
              .normalized();
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

    movementChecker.checkMovement(
        component: this,
        movementThisFrame: movementThisFrame,
        originalPosition: originalPosition,
        collisionObjects: gameRef.world.collisionObjects);
  }

  void removeLineComponents() {
    for (final child in gameRef.world.children) {
      if (child is LineComponent) {
        gameRef.world.remove(child);
      }
    }
  }

  void addAStarPathVisualization(List<List<double>> path) {
    int pathLength = path.length;

    for (int i = 0; i < pathLength - 2; i++) {
      List<double> from = path[i];
      List<double> to = path[i + 1];
      LineComponent newComponent = LineComponent(LineSegment(
          Vector2(from.first * 16, from.last * 16),
          Vector2(to.first * 16, to.last * 16)));
      gameRef.world.add(newComponent);
    }
    LineComponent lastSegment = LineComponent(
      LineSegment(
        Vector2(path.last.first * 16, path.last.last * 16),
        Vector2(characterToChase.center.x, characterToChase.center.y),
      ),
    );
    gameRef.world.add(lastSegment);
  }

  void convertAndAddCoordinatesToPath(List tempPath, List path) {
    for (List<dynamic> thing in tempPath) {
      List<int> coordinates = thing.map((e) => e as int).toList();
      List<double> myDoubleList = [];
      coordinates.forEach((element) {
        myDoubleList.add(element.toDouble());
      });

      path.add(myDoubleList);
    }
  }
}

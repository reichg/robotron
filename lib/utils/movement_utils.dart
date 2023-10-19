import 'package:flame/components.dart';

class CollisionMovementChecker {
  bool collisionBottom = false;
  bool collisionTop = false;
  bool collisionLeft = false;
  bool collisionRight = false;
  bool collided = false;
  void checkMovement({
    required PositionComponent component,
    required Vector2 movementThisFrame,
    required Vector2 originalPosition,
    required List<PositionComponent> collisionObjects,
  }) {
    resetCollisions();
    // Collision logic for bools collisionBottom/Top/Left/Right
    for (final collisionObject in collisionObjects) {
      checkCollision(
          component, collisionObject, originalPosition, movementThisFrame);
      if (collided) {
        break;
      }
    }

    // Stop vertical movement
    if (collisionBottom || collisionTop) {
      movementThisFrame.y = 0;
    }

    // Stop horizontal movement
    if (collisionLeft || collisionRight) {
      movementThisFrame.x = 0;
    }

    component.position = originalPosition + movementThisFrame;
  }

  // Checks for collisions with all "CollisionObjects"
  void checkCollision(
      PositionComponent component,
      PositionComponent collisionComponent,
      Vector2 originalPosition,
      Vector2 movementThisFrame) {
    // Main character bounding coordinates for collisions before updating position.
    var rightThisFrameX = component.center.x + ((component.width - 10) / 2);
    var leftThisFrameX = component.center.x - ((component.width - 10) / 2);
    var topThisFrameY = component.center.y - ((component.height - 10) / 2);
    var bottomThisFrameY = component.center.y + ((component.height - 4) / 2);

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

  // Resets all collision detection. Implemented at the beginning of each update frame.
  void resetCollisions() {
    collisionBottom = false;
    collisionLeft = false;
    collisionRight = false;
    collisionTop = false;
  }
}

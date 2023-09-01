import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionObject extends PositionComponent {
  CollisionObject({required size, required position})
      : super(size: size, position: position);

  @override
  bool debugMode = true;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }
}

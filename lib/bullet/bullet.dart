// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:flame/components.dart';

import 'package:robotron/robotron.dart';

class Bullet extends SpriteComponent with HasGameRef<Robotron> {
  final double vecX;
  final double vecY;

  Bullet({
    required this.vecX,
    required this.vecY,
  });

  @override
  bool debugMode = true;
  double speed = 150;

  @override
  FutureOr<void> onLoad() async {
    anchor = Anchor.center;
    sprite = Sprite(game.images.fromCache("Items/Bullet/Bullet.png"));
    size = Vector2.all(10);

    return super.onLoad();
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

  Bullet copyWith({
    double? vecX,
    double? vecY,
  }) {
    return Bullet(
      vecX: vecX ?? this.vecX,
      vecY: vecY ?? this.vecY,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'vecX': vecX,
      'vecY': vecY,
    };
  }

  factory Bullet.fromMap(Map<String, dynamic> map) {
    return Bullet(
      vecX: map['vecX'] as double,
      vecY: map['vecY'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory Bullet.fromJson(String source) =>
      Bullet.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Bullet(vecX: $vecX, vecY: $vecY)';

  @override
  bool operator ==(covariant Bullet other) {
    if (identical(this, other)) return true;

    return other.vecX == vecX && other.vecY == vecY;
  }

  @override
  int get hashCode => vecX.hashCode ^ vecY.hashCode;
}

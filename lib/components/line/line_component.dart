import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

import 'package:flutter/material.dart';

class LineComponent extends ShapeComponent {
  LineSegment segment;
  Paint paint = Paint()..color = Colors.red;

  final DEFAULT_LINE = LineSegment(Vector2(0.0, 0.0), Vector2(1.0, 0.0));

  LineComponent(this.segment) : super(size: Vector2.all(1));

  @override
  bool containsPoint(Vector2 point) {
    return false;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawLine(segment.from.toOffset(), segment.to.toOffset(), paint);
  }
}

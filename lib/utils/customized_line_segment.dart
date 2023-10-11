import 'dart:math';

import 'package:flame/geometry.dart';

class CustomizedLineSegment extends LineSegment {
  CustomizedLineSegment(super.from, super.to);

  double calculateDistance2() {
    return pow((this.to.x - this.from.x), 2).toDouble() +
        pow((this.to.y - this.from.y), 2).toDouble();
  }
}

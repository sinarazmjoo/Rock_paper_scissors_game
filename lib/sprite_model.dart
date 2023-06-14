import 'package:flutter/material.dart';

enum SpriteType {
  rock,
  paper,
  scissors,
}

class SpriteModel {
  SpriteModel({
    required this.type,
    required this.id,
    required this.color,
    required this.icon,
    required this.position,
    required this.direction,
    this.size = const Size(30, 30),
  });

  final SpriteType type;
  final Size size;
  final int id;
  final Color color;
  final Icon icon;
  Offset position;
  Offset direction;

  void move(double velocity) {
    position =
        position + (Offset(velocity * direction.dx, velocity * direction.dy));
  }
}

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:alienbattle/utils/constants.dart';

class Alien extends BodyComponent with ContactCallbacks {
  final bool isMine;
  final int playerIndex;
  final void Function() onHpChange;

  late final Sprite sprite;
  double healthPoints = initialHealthPoints;
  bool isAttacking = false;

  Alien({
    required this.isMine,
    required this.playerIndex,
    required this.onHpChange,
  }) {
    paint = Paint()..color = Colors.transparent;
  }

  String get getImagePath {
    return 'alien$playerIndex.png';
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final image = await Flame.images.load(getImagePath);
    if (isMine) {
      add(MyAlienCircle());
    }
    sprite = Sprite(image);
    add(SpriteComponent(
      sprite: sprite,
      size: Vector2(6, 6),
      anchor: Anchor.center,
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // sprite.render(
    //   canvas,
    // size: Vector2(6, 6),
    // anchor: Anchor.center,
    // );
  }

  Vector2 get _getInitialPosition {
    final sixthOfField = gameRef.size.x / 6;
    switch (playerIndex) {
      case 0:
        return Vector2(sixthOfField * 1, sixthOfField);

      case 1:
        return Vector2(sixthOfField * 5, sixthOfField);

      case 2:
        return Vector2(sixthOfField * 1, sixthOfField * 5);

      case 3:
        return Vector2(sixthOfField * 5, sixthOfField * 5);

      case 4:
        return Vector2(sixthOfField * 2, sixthOfField * 3);

      case 5:
        return Vector2(sixthOfField * 4, sixthOfField * 3);
      default:
        return Vector2(sixthOfField * 4, sixthOfField * 3);
    }
  }

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = 3;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0,
      density: 1,
      friction: 0,
    );

    final bodyDef = BodyDef(
      userData: this,
      linearDamping: 0.2,
      position: _getInitialPosition,
      type: BodyType.dynamic,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);
    if (other is Alien && other.isAttacking) {
      healthPoints -= 10;
      if (healthPoints <= 0) {
        removeFromParent();
      }
      onHpChange();
    }
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    super.renderCircle(canvas, center, radius);
  }

  /// Released the alien to move in certain direction
  void release(Vector2 releaseVelocity) {
    body.linearVelocity = releaseVelocity;
    isAttacking = true;
    // add(Some());
    Future.delayed(const Duration(seconds: 2)).then((_) => isAttacking = false);
  }
}

class MyAlienCircle extends PositionComponent {
  static const strokeWidth = 0.5;
  static const _radius = 3.25;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke; //important set stroke style

    final path = Path()
      ..moveTo(strokeWidth, strokeWidth)
      ..addOval(Rect.fromCircle(
        center: const Offset(0, 0),
        radius: _radius,
      ));

    canvas.drawPath(path, paint);
  }
}

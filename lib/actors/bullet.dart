import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:tankwar/actors/base_tank.dart';
import 'package:tankwar/actors/explosion.dart';
import 'package:tankwar/actors/metal_wall.dart';
import 'package:tankwar/actors/wood_wall.dart';
import 'package:tankwar/tank_game.dart';

class Bullet extends SpriteComponent
    with HasGameRef<TankGame>, CollisionCallbacks {
  static const double maxSpeed = 800;

  Bullet({
    required this.owner,
    required this.velocity,
  }) : super(anchor: Anchor.center) {
    angle += angleTo(velocity + position);
  }
  final Vector2 velocity;
  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('bullet_${owner.type}_1.png'));
    size = sprite!.image.size.scaled(0.6);
    add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (velocity != Vector2.zero()) {
      position += velocity * maxSpeed * dt;
    }
    if (game.mapComponent != null) {
      final leftTopCorner = absolutePositionOfAnchor(Anchor.topLeft);
      final rightDownCorner = absolutePositionOfAnchor(Anchor.bottomRight);
      if (leftTopCorner.x > game.mapComponent!.size.x ||
          leftTopCorner.y > game.mapComponent!.size.y ||
          rightDownCorner.x < 0 ||
          rightDownCorner.y < 0) {
        removeFromParent();
      }
    }
    super.update(dt);
  }

  final BaseTank owner;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is BaseTank && other != owner) {
      game.world.add(Explosion(position: (other.position + position) / 2));
      other.removeFromParent();
      removeFromParent();
    }
    if (other is MetalWall) {
      removeFromParent();
    }
    if (other is WoodWall) {
      other.removeFromParent();
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}

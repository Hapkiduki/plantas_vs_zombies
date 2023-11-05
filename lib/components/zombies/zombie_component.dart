import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:plantas_vs_zombies/components/plants/plant_component.dart';
import 'package:plantas_vs_zombies/components/plants/projectile_component.dart';
import 'package:plantas_vs_zombies/helpers/enemies/movements.dart';
import 'package:plantas_vs_zombies/main.dart';
import 'package:plantas_vs_zombies/map/seed_component.dart';

const alignZombie = 10;

class ZombieComponent extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<MyGame> {
  ZombieComponent({required super.position}) {
    debugMode = true;
    scale = Vector2.all(1);
    positionCopy = position;
  }

  late SpriteAnimation walkingAnimation, walkingHurtAnimation, eatingAnimation;

  bool isAtacking = false;
  bool atack = false;
  double elapsedTimeAtacking = 0;

  int life = 100;
  int damage = 20;

  double speed = 15;
  double spriteSheetWidth = 430;
  double spriteSheetHeight = 519;
  late RectangleHitbox body;

  Vector2 positionCopy = Vector2(0, 0);

  @override
  FutureOr<void> onLoad() {
    countEnemiesInMap++;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (game.resetGame) {
      removeFromParent();
    }

    if (!isAtacking) {
      position.add(Vector2(-dt * speed, 0));
      positionCopy.add(Vector2(-dt * speed, 0));
    }

    if (elapsedTimeAtacking > 2) {
      elapsedTimeAtacking = 0;
      atack = true;
    }
    elapsedTimeAtacking += dt;

    if (position.x <= -size.x) {
      // el zombie ya no esta en el mapa
      // zombie GANO
      removeFromParent();
      _setChannel(false);
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PlantComponent) {
      animation = eatingAnimation;
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is SeedComponent) {
      other.busy = true;
      _setChannel(true);
    }

    if (other is ProjectileComponent) {
      other.removeFromParent();
      life -= other.damage;
      if (life <= 50) {
        animation = walkingHurtAnimation;
      }
      if (life <= 0) {
        removeFromParent();
      }
    }

    // if (other is PeashooterComponent || other is CactusComponent) {
    if (other is PlantComponent) {
      isAtacking = true;
      if (atack) {
        other.life -= damage;
        if (other.life <= 0) {
          other.removeFromParent();
        }

        atack = false;
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is SeedComponent) {
      other.busy = false;
      other.sown = false;
    }
    if (other is PlantComponent) {
      isAtacking = false;
      atack = false;

      if (life <= 50) {
        animation = walkingHurtAnimation;
      } else {
        animation = walkingAnimation;
      }
    }
    super.onCollisionEnd(other);
  }

  @override
  void onGameResize(Vector2 size) {
    scale = Vector2.all(game.factScale);
    position = positionCopy * game.factScale;
    super.onGameResize(size);
  }

  @override
  void onRemove() {
    _setChannel(false);
    countEnemiesInMap--;
    super.onRemove();
  }

  void _setChannel(bool value) {
    switch (positionCopy.y + alignZombie) {
      case 48:
        enemiesInChannel[0] = value;
        break;
      case 96:
        enemiesInChannel[1] = value;
        break;
      case 144:
        enemiesInChannel[2] = value;
        break;
      case 192:
        enemiesInChannel[3] = value;
        break;
      case 240:
        enemiesInChannel[4] = value;
        break;
      case 288:
        enemiesInChannel[5] = value;
        break;
      case 336:
        enemiesInChannel[6] = value;
        break;
      default:
    }
  }
}

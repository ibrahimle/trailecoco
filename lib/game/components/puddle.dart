import 'package:eco_trail/config/constants.dart';
import 'package:eco_trail/game/components/hiker.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';

class Puddle extends SpriteComponent
    with HasGameReference<EcoTrailGame>, TapCallbacks, CollisionCallbacks {
  
  Puddle({
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await game.loadSprite(GameConstants.itemPuddle);

    // Size - puddles are flat and wide
    final targetHeight = game.size.y * 0.08;
    size = Vector2(targetHeight * 2.5, targetHeight);

    // Smaller hitbox for fairness
    add(RectangleHitbox(
      size: size * 0.8,
      position: Vector2(size.x * 0.1, size.y * 0.2),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x -= game.currentScrollSpeed * dt;

    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _clean();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Hiker) {
      _triggerSlowDown();
    }
  }

  void _clean() {
    FlameAudio.play(GameConstants.sfxCollect); 
    
    game.showSplashParticles(position);

    removeFromParent();
  }

  void _triggerSlowDown() {
    FlameAudio.play(GameConstants.sfxMud);
    
    game.showSplashParticles(position);

    game.triggerSlowDown();
    
    removeFromParent();
  }
}


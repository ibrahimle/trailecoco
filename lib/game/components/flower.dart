import 'package:eco_trail/config/constants.dart';
import 'package:eco_trail/game/components/hiker.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class Flower extends SpriteComponent
    with HasGameReference<EcoTrailGame>, CollisionCallbacks {
  bool _bloomed = false;

  Flower({
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await game.loadSprite(GameConstants.itemFlowerWithered);

    // Size relative to screen
    final targetHeight = game.size.y * 0.12;
    size = Vector2(targetHeight, targetHeight);

    add(RectangleHitbox());

    // Add pulsing glow effect to help player see the target
    _addGlowEffect();
  }

  void _addGlowEffect() {
    // Pulsing scale effect to draw attention
    add(
      ScaleEffect.by(
        Vector2.all(1.1),
        EffectController(
          duration: 0.6,
          reverseDuration: 0.6,
          infinite: true,
        ),
      ),
    );

    // Subtle color tint to make it stand out
    add(
      ColorEffect(
        const Color(0xFFFFEB3B), // Yellow glow
        EffectController(
          duration: 0.8,
          reverseDuration: 0.8,
          infinite: true,
        ),
        opacityFrom: 0.0,
        opacityTo: 0.3,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x -= game.currentScrollSpeed * dt;

    // If flower goes off-screen without being bloomed, it's a miss
    if (position.x < -size.x) {
      if (!_bloomed) {
        // Penalty for missing the flower
        game.onFlowerMissed();
      }
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (!_bloomed && other is Hiker) {
      _bloom();
    }
  }

  Future<void> _bloom() async {
    _bloomed = true;
    sprite = await game.loadSprite(GameConstants.itemFlowerBloomed);
    
    FlameAudio.play(GameConstants.sfxBloom);
    
    game.showSparkleParticles(position);
    
    game.onFlowerBloomed();
  }
}


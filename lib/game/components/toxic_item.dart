import 'package:eco_trail/config/constants.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

/// Toxic barrels are decoy items that damage the player when tapped.
/// They safely exit the screen if ignored (no penalty).
class ToxicItem extends SpriteComponent
    with HasGameReference<EcoTrailGame>, TapCallbacks {
  
  ToxicItem({
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await game.loadSprite(GameConstants.itemToxicBarrel);
    
    // Set size based on sprite, scaled appropriately (same as trash)
    final targetHeight = game.size.y * 0.1; // 10% of screen height
    size = Vector2(targetHeight, targetHeight); 
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move left with the world
    position.x -= game.currentScrollSpeed * dt;

    // Toxic barrels safely exit screen - no penalty for ignoring
    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _onTapped();
  }

  void _onTapped() {
    // Play a negative feedback sound
    if (game.playerProgress.sfxEnabled) {
      FlameAudio.play(GameConstants.sfxMud);
    }
    
    // Visual feedback - red flash
    add(
      ColorEffect(
        const Color(0xFFE53935), // EcoTheme.ecoRed
        EffectController(duration: 0.15),
        opacityFrom: 0,
        opacityTo: 0.7,
      ),
    );

    // Damage the eco-meter (same as missing trash)
    game.damageEcoMeter(GameConstants.toxicDamage);

    // Show toxic splash particles (greenish)
    game.showToxicParticles(position);

    removeFromParent();
  }
}

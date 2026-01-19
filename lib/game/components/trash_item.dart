import 'dart:math';

import 'package:eco_trail/config/constants.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

/// Movement patterns for trash items
enum MovementType {
  straight,   // Default: moves left in a straight line
  zigzag,     // Sine wave oscillation while moving left
  bouncing,   // Bounces off top/bottom screen edges
  speedBurst, // Random bursts of 2x speed
}

class TrashItem extends SpriteComponent
    with HasGameReference<EcoTrailGame>, TapCallbacks, CollisionCallbacks {
  final Random _random = Random();
  final bool isMovingVariant;
  final int requiredTaps;
  final bool isCritical;
  final double criticalTimer;
  final MovementType movementType;
  final double shrinkMinScale; // 1.0 = no shrink, 0.5 = shrink to 50%
  
  double _sineWaveTime = 0;
  int _currentTaps = 0;
  double _tapResetTimer = 0;
  
  // Critical item state
  double _criticalTimeRemaining = 0;
  bool _isExpired = false;
  bool _pulseDirection = true; // true = growing, false = shrinking
  double _pulseScale = 1.0;
  
  // Bouncing movement state
  double _bounceDirection = 1.0; // 1 = down, -1 = up
  
  // Speed burst state
  double _speedBurstTimer = 0;
  bool _isSpeedBurst = false;
  double _nextBurstTime = 0;
  
  // Shrinking state
  double _startX = 0;
  double _currentShrinkScale = 1.0;
  late Vector2 _baseSize;

  TrashItem({
    required Vector2 position,
    this.isMovingVariant = false,
    this.requiredTaps = 1,
    this.isCritical = false,
    this.criticalTimer = 3.0,
    this.movementType = MovementType.straight,
    this.shrinkMinScale = 1.0,
  }) : super(position: position, anchor: Anchor.center) {
    _criticalTimeRemaining = criticalTimer;
    // Randomize initial bounce direction
    _bounceDirection = _random.nextBool() ? 1.0 : -1.0;
    // Randomize first speed burst timing
    _nextBurstTime = _random.nextDouble() * 2.0 + 0.5;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Randomly select sprite
    String spritePath;
    if (isMovingVariant) {
      spritePath = GameConstants.itemBag;
    } else {
      final variants = [
        GameConstants.itemTrashCan,
        GameConstants.itemTrashBottle,
        GameConstants.itemTrashWrapper,
      ];
      spritePath = variants[_random.nextInt(variants.length)];
    }

    sprite = await game.loadSprite(spritePath);
    
    // Set size based on sprite, scaled appropriately
    final targetHeight = game.size.y * 0.1; // 10% of screen height
    size = Vector2(targetHeight, targetHeight);
    
    // Store base size and start position for shrinking calculation
    _baseSize = size.clone();
    _startX = position.x;

    // Add collision hitbox for hiker collision detection
    add(RectangleHitbox(
      size: size * 0.7, // Slightly smaller hitbox for fairness
      position: size * 0.15,
      anchor: Anchor.topLeft,
    ));
    
    // Critical items start with a pulsing red tint effect
    if (isCritical) {
      _startCriticalGlow();
    }
  }

  void _startCriticalGlow() {
    // Continuous pulsing red glow effect
    add(
      ColorEffect(
        const Color(0xFFE53935), // EcoTheme.ecoRed
        EffectController(
          duration: 0.5,
          reverseDuration: 0.5,
          infinite: true,
        ),
        opacityFrom: 0.1,
        opacityTo: 0.4,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Calculate current speed (may be modified by speed burst)
    double currentSpeed = game.currentScrollSpeed;
    
    // Speed burst logic
    if (movementType == MovementType.speedBurst) {
      _speedBurstTimer += dt;
      
      if (_isSpeedBurst) {
        currentSpeed *= GameConstants.speedBurstMultiplier;
        if (_speedBurstTimer >= GameConstants.speedBurstDuration) {
          _isSpeedBurst = false;
          _speedBurstTimer = 0;
          _nextBurstTime = _random.nextDouble() * 1.5 + 0.5; // Next burst in 0.5-2 seconds
        }
      } else {
        if (_speedBurstTimer >= _nextBurstTime) {
          _isSpeedBurst = true;
          _speedBurstTimer = 0;
        }
      }
    }

    // Move left with the world
    position.x -= currentSpeed * dt;

    // Handle movement patterns
    switch (movementType) {
      case MovementType.zigzag:
        _sineWaveTime += dt;
        // Oscillate Y position with sine wave
        position.y += sin(_sineWaveTime * 3) * 100 * dt;
        position.y = position.y.clamp(game.size.y * 0.1, game.size.y * 0.9);
        break;
        
      case MovementType.bouncing:
        // Move vertically and bounce off edges
        const bounceSpeed = 80.0;
        position.y += bounceSpeed * _bounceDirection * dt;
        
        // Check bounds and reverse direction
        final minY = game.size.y * 0.1;
        final maxY = game.size.y * 0.85;
        if (position.y <= minY) {
          position.y = minY;
          _bounceDirection = 1.0; // Start moving down
        } else if (position.y >= maxY) {
          position.y = maxY;
          _bounceDirection = -1.0; // Start moving up
        }
        break;
        
      case MovementType.speedBurst:
        // Horizontal movement already handled above
        break;
        
      case MovementType.straight:
        // Sine wave movement for legacy moving variant (bag)
        if (isMovingVariant) {
          _sineWaveTime += dt;
          position.y += sin(_sineWaveTime * 3) * 100 * dt;
          position.y = position.y.clamp(game.size.y * 0.1, game.size.y * 0.9);
        }
        break;
    }

    // Size shrinking logic
    if (shrinkMinScale < 1.0) {
      // Calculate progress across screen (1.0 at start, 0.0 at left edge)
      final screenWidth = game.size.x + 100; // Total travel distance
      final distanceTraveled = _startX - position.x;
      final progress = (distanceTraveled / screenWidth).clamp(0.0, 1.0);
      
      // Interpolate scale: 1.0 at start -> shrinkMinScale at end
      _currentShrinkScale = 1.0 - (progress * (1.0 - shrinkMinScale));
      
      // Apply shrink to size (affects hitbox)
      size = _baseSize * _currentShrinkScale;
      
      // Apply shrink to visual scale (only if not critical, since critical has its own pulse)
      if (!isCritical) {
        scale = Vector2.all(_currentShrinkScale);
      }
    }

    // Multi-tap reset timer
    if (_currentTaps > 0 && _currentTaps < requiredTaps) {
      _tapResetTimer += dt;
      if (_tapResetTimer >= GameConstants.multiTapResetTime) {
        _currentTaps = 0;
        _tapResetTimer = 0;
      }
    }

    // Critical item timer and visual effect
    if (isCritical && !_isExpired) {
      _criticalTimeRemaining -= dt;
      
      // Pulsing scale effect (combined with shrink scale)
      const pulseSpeed = 4.0;
      const pulseAmount = 0.08;
      if (_pulseDirection) {
        _pulseScale += pulseSpeed * dt * pulseAmount;
        if (_pulseScale >= 1.0 + pulseAmount) {
          _pulseDirection = false;
        }
      } else {
        _pulseScale -= pulseSpeed * dt * pulseAmount;
        if (_pulseScale <= 1.0 - pulseAmount) {
          _pulseDirection = true;
        }
      }
      // Combine critical pulse with shrink scale
      scale = Vector2.all(_pulseScale * _currentShrinkScale);
      
      // Check if expired
      if (_criticalTimeRemaining <= 0) {
        _isExpired = true;
        // Flash red to indicate expiration
        add(
          ColorEffect(
            const Color(0xFFE53935), // EcoTheme.ecoRed
            EffectController(duration: 0.2),
            opacityFrom: 0,
            opacityTo: 0.6,
          ),
        );
      }
    }

    // Check if off-screen (missed)
    if (position.x < -size.x) {
      _onMiss();
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _currentTaps++;
    _tapResetTimer = 0; // Reset the timer on each tap
    
    if (_currentTaps >= requiredTaps) {
      _collect();
    } else {
      _showHitFeedback();
    }
  }

  void _showHitFeedback() {
    // Play a softer tap sound for partial hits
    if (game.playerProgress.sfxEnabled) {
      FlameAudio.play(GameConstants.sfxButton);
    }
    
    // Visual pulse effect - scale up then back down
    add(
      ScaleEffect.by(
        Vector2.all(1.15),
        EffectController(
          duration: 0.08,
          reverseDuration: 0.08,
        ),
      ),
    );
    
    // Tint flash effect
    add(
      ColorEffect(
        const Color(0xFFFFFFFF),
        EffectController(duration: 0.1),
        opacityFrom: 0,
        opacityTo: 0.5,
      ),
    );
  }

  void _collect() {
    if (game.playerProgress.sfxEnabled) {
      FlameAudio.play(GameConstants.sfxCollect);
    }

    game.showCollectionParticles(position);

    game.onTrashCollected();

    removeFromParent();
  }

  void _onMiss() {
    // Critical items that expired deal double damage
    if (isCritical && _isExpired) {
      game.damageEcoMeter(GameConstants.ecoPenaltyMiss * GameConstants.criticalDamageMultiplier);
    } else {
      game.damageEcoMeter(GameConstants.ecoPenaltyMiss);
    }
  }
}


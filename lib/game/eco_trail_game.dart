import 'dart:math';

import 'package:eco_trail/config/constants.dart';
import 'package:eco_trail/game/components/flower.dart';
import 'package:eco_trail/game/components/hiker.dart';
import 'package:eco_trail/game/components/level_background.dart';
import 'package:eco_trail/game/components/puddle.dart';
import 'package:eco_trail/game/components/toxic_item.dart';
import 'package:eco_trail/game/components/trash_item.dart';
import 'package:eco_trail/game/spawner_manager.dart';
import 'package:eco_trail/providers/player_progress_provider.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class EcoTrailGame extends FlameGame with HasCollisionDetection {
  final PlayerProgressProvider playerProgress;

  late final Hiker hiker;
  late final LevelBackground background;
  late SpawnerManager spawner;
  final Random _random = Random();

  // --- Game Configuration ---
  late int currentDay;

  // --- Game State ---
  double currentScrollSpeed = GameConstants.scrollSpeedEasy;
  double _ecoMeter = GameConstants.maxEcoMeter;
  double _distanceTraveled = 0.0;

  // Stats
  int _trashCollected = 0;
  int _sessionTokens = 0;

  // Flags
  bool _isGameOver = false;
  bool _isLevelComplete = false;
  bool _isPaused = false;
  bool _isMenu = true; // Start in menu

  // Hiker Slowdown
  Timer? _slowDownTimer;
  bool _isSlowedDown = false;

  // Track if hiker has been initialized (for safe access in _initializeLevel)
  bool _hikerInitialized = false;

  // Getters for UI/Logic
  double get ecoMeter => _ecoMeter;
  int get score => _trashCollected;
  double get distance => _distanceTraveled;
  bool get isGameOver => _isGameOver;
  bool get isLevelComplete => _isLevelComplete;
  bool get isMenu => _isMenu;
  bool get isPaused => _isPaused;

  /// Get the trash collection goal for the current day
  int get trashGoal => GameConstants.getTrashGoalForDay(currentDay);

  // Helper to access ground level for spawners
  double get groundLevel => size.y - (size.y * 0.15);

  EcoTrailGame({required this.playerProgress});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Initialize Level Parameters from Provider
    currentDay = playerProgress.currentDay;
    _initializeLevel();

    // 2. Setup Background
    background = LevelBackground(baseSpeed: currentScrollSpeed);
    add(background);

    // 3. Setup Hiker
    final groundY = size.y - (size.y * 0.15);
    final hikerHeight = size.y * 0.2;
    final hikerWidth = hikerHeight * 0.8;

    hiker = Hiker(
      position: Vector2(size.x * 0.2, groundY),
      size: Vector2(hikerWidth, hikerHeight),
    );
    add(hiker);
    _hikerInitialized = true;

    // 4. Setup Spawner
    spawner = SpawnerManager();
    spawner.currentDay = currentDay;
    add(spawner);

    // 5. Audio
    if (playerProgress.musicEnabled) {
      FlameAudio.bgm.play(GameConstants.bgmGameplay);
    }

    // 6. Start in Menu
    startMenu();
  }

  void startMenu() {
    _isMenu = true;
    _isPaused = false;
    _isGameOver = false;
    _isLevelComplete = false;

    // Hiker Sits
    if (hiker.isMounted) {
      hiker.sit();
    }

    // Show MainMenu
    overlays.add('MainMenu');
    overlays.remove('HUD');
    overlays.remove('GameOver');
    overlays.remove('LevelComplete');
    overlays.remove('PauseMenu');
  }

  void startHike() {
    _isMenu = false;
    _initializeLevel();
    hiker.run();
    spawner.updateDifficulty(currentDay);

    overlays.remove('MainMenu');
    overlays.add('HUD');

    resumeEngine();
  }

  /// Start a specific level/day (used by level selection)
  void startLevel(int day) {
    currentDay = day;
    _isMenu = false;

    // Clear any existing game entities (trash, flowers, etc.)
    _clearGameEntities();

    _initializeLevel();

    // Update spawner with new day settings (don't recreate, just update)
    spawner.updateDifficulty(currentDay);

    hiker.run();

    overlays.remove('MainMenu');
    overlays.remove('LevelSelect');
    overlays.add('HUD');

    resumeEngine();
  }

  /// Clear all game entities (trash, flowers, puddles, particles)
  /// Uses whitelist approach to only remove game entities, preserving Flame internals
  void _clearGameEntities() {
    // Only remove game entities (whitelist approach)
    // This preserves Flame internal components like MultiDragDispatcher, MultiTapDispatcher, World
    children.whereType<Component>().toList().forEach((c) {
      if (c is TrashItem ||
          c is Flower ||
          c is Puddle ||
          c is ToxicItem ||
          c is ParticleSystemComponent) {
        c.removeFromParent();
      }
    });
  }

  void pauseGame() {
    if (_isMenu || _isGameOver || _isLevelComplete) return;
    _isPaused = true;
    pauseEngine();
    overlays.add('PauseMenu');
    overlays.remove('HUD');
    FlameAudio.bgm.pause();
  }

  void resumeGame() {
    if (!_isPaused) return;
    _isPaused = false;
    resumeEngine();
    overlays.remove('PauseMenu');
    overlays.add('HUD');
    if (playerProgress.musicEnabled) {
      FlameAudio.bgm.resume();
    }
  }

  void retireToCamp() {
    _isPaused = false;
    resumeEngine();

    // Reset everything
    restartLevel();
    startMenu();
  }

  void updateMusicState() {
    if (playerProgress.musicEnabled) {
      if (!FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.play(GameConstants.bgmGameplay);
      } else {
        FlameAudio.bgm.resume();
      }
    } else {
      FlameAudio.bgm.pause();
    }
  }

  void _initializeLevel() {
    // Reset State
    _ecoMeter = GameConstants.maxEcoMeter;
    _distanceTraveled = 0.0;
    _trashCollected = 0;
    _sessionTokens = 0;
    _isGameOver = false;
    _isLevelComplete = false;
    _isPaused = false;
    _isSlowedDown = false;

    // Set Difficulty Parameters based on Day using progressive scaling
    currentScrollSpeed = GameConstants.getScrollSpeedForDay(currentDay);

    // Reset hiker position when starting a new level (only if already initialized)
    if (_hikerInitialized && hiker.isMounted) {
      hiker.resetPosition();
    }
  }

  @override
  void update(double dt) {
    if (_isMenu) {
      super.update(dt); // Keep animations (sitting) running
      return;
    }

    if (_isGameOver || _isLevelComplete || _isPaused) return;

    super.update(dt);

    // Update Timers
    if (_slowDownTimer != null) {
      _slowDownTimer!.update(dt);
    }

    // 1. Update Distance (scale pixels to game "meters": 10 pixels = 1 meter)
    _distanceTraveled += (currentScrollSpeed * dt) / 10.0;

    // 2. Eco-Meter Drain - uses progressive scaling based on day
    final drainRate = GameConstants.getDrainRateForDay(currentDay);
    _ecoMeter -= drainRate * dt;
    _ecoMeter = _ecoMeter.clamp(0.0, GameConstants.maxEcoMeter);

    // 3. Check Game Over
    if (_ecoMeter <= 0) {
      _triggerGameOver();
    }

    // 4. Check Level Complete - ALL days use trash collection goal
    // Goal increases with each day for proper difficulty progression
    final trashGoal = GameConstants.getTrashGoalForDay(currentDay);
    if (_trashCollected >= trashGoal) {
      _triggerLevelComplete();
    }
  }

  // --- Game Interaction Methods ---

  void onTrashCollected() {
    _trashCollected++;
    _sessionTokens += GameConstants.tokenRewardTrash;
    restoreEcoMeter(GameConstants.ecoRestorationTrash);
  }

  void onFlowerBloomed() {
    _sessionTokens += GameConstants.tokenRewardFlower;
    restoreEcoMeter(GameConstants.ecoRestorationFlower);
  }

  /// Called when a flower passes off-screen without being bloomed (missed)
  void onFlowerMissed() {
    if (_isGameOver || _isLevelComplete) return;

    // Penalty for missing a flower - scales with day
    final penalty = GameConstants.getFlowerMissPenaltyForDay(currentDay);
    damageEcoMeter(penalty);
  }

  /// Called when hiker collides with trash (avoidance failure)
  void onTrashCollision(Component trash) {
    if (_isGameOver || _isLevelComplete) return;

    // Damage eco-meter (higher than regular miss)
    damageEcoMeter(GameConstants.ecoPenaltyTrashCollision);

    // Visual feedback - splash particles at collision point
    if (trash is PositionComponent) {
      showSplashParticles(trash.position);
    }

    // Play collision sound
    if (playerProgress.sfxEnabled) {
      FlameAudio.play(GameConstants.sfxMud);
    }

    // Remove the trash item
    trash.removeFromParent();
  }

  void restoreEcoMeter(double amount) {
    if (_isGameOver) return;
    _ecoMeter = (_ecoMeter + amount).clamp(0.0, GameConstants.maxEcoMeter);
  }

  void damageEcoMeter(double amount) {
    if (_isGameOver) return;
    _ecoMeter = (_ecoMeter - amount).clamp(0.0, GameConstants.maxEcoMeter);

    camera.viewfinder.add(
      MoveByEffect(
        Vector2(4, 4),
        EffectController(duration: 0.05, reverseDuration: 0.05, repeatCount: 6),
      ),
    );

    if (_ecoMeter <= 0) {
      _triggerGameOver();
    }
  }

  void triggerSlowDown() {
    if (_isSlowedDown) return; // Already slowed
    _isSlowedDown = true;

    // Slow down visual animation of hiker
    // Assuming Hiker uses stepTime property in its animation
    // But SpriteAnimationComponent doesn't expose stepTime setter directly on the animation easily without recreating or iterating frames.
    // Actually, SpriteAnimation has stepTime.

    // Simple visual cue:
    hiker.animation?.stepTime = 0.3; // Slower (default is 0.15)

    _slowDownTimer = Timer(
      2.0,
      onTick: () {
        _isSlowedDown = false;
        hiker.animation?.stepTime = 0.15; // Restore
      },
    );
  }

  // --- Game Flow Methods ---

  void _triggerGameOver() {
    if (_isGameOver) return;
    _isGameOver = true;

    if (playerProgress.sfxEnabled) {
      FlameAudio.play(GameConstants.sfxLose);
    }
    FlameAudio.bgm.stop();

    // Note: Not calling pauseEngine() here - game state flags handle stopping game logic
    // This avoids breaking drag input on Flutter Web
    overlays.add('GameOver');
  }

  void _triggerLevelComplete() {
    if (_isLevelComplete) return;
    _isLevelComplete = true;

    // Bonus Tokens
    _sessionTokens += GameConstants.tokenRewardLevelComplete;

    // Save progress
    _saveProgress();

    if (playerProgress.sfxEnabled) {
      FlameAudio.play(GameConstants.sfxWin);
    }
    FlameAudio.bgm.stop();

    // Note: Not calling pauseEngine() here - game state flags handle stopping game logic
    // This avoids breaking drag input on Flutter Web
    overlays.add('LevelComplete');
  }

  void _saveProgress() {
    playerProgress.saveRun(_sessionTokens, _trashCollected);

    // Unlock next day if not just tutorial grinding
    // Actually simpler: always unlock next day on completion
    playerProgress.unlockNextDay();
  }

  void restartLevel() {
    // Clear all existing entities
    _clearGameEntities();

    _initializeLevel();

    // Update spawner difficulty (this also resets spawn counts)
    spawner.updateDifficulty(currentDay);

    // Start the hiker running
    hiker.run();

    resumeEngine();
    overlays.remove('GameOver');
    overlays.remove('LevelComplete');
    overlays.add('HUD');

    if (playerProgress.musicEnabled) {
      FlameAudio.bgm.play(GameConstants.bgmGameplay);
    }
  }

  void nextLevel() {
    // Increment day locally so the reload picks it up
    // Or just reload level, using provider's updated day (which we updated in _saveProgress)
    currentDay = playerProgress.currentDay;

    restartLevel();

    // Resume game flow
    _isLevelComplete = false;
    _isPaused = false;
    resumeEngine();
    overlays.remove('LevelComplete');
    overlays.add('HUD');

    if (playerProgress.musicEnabled) {
      FlameAudio.bgm.play(GameConstants.bgmGameplay);
    }
  }

  // --- Particle Effects ---

  void showCollectionParticles(Vector2 position) {
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 10,
          lifespan: 0.5,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 100),
            speed: Vector2(
              (_random.nextDouble() - 0.5) * 200,
              (_random.nextDouble() - 0.5) * 200,
            ),
            child: CircleParticle(
              radius: 3,
              paint: Paint()..color = const Color(0xFF8BC34A),
            ),
          ),
        ),
      ),
    );
  }

  void showSparkleParticles(Vector2 position) {
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 8,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(
              (_random.nextDouble() - 0.5) * 50,
              -100 - (_random.nextDouble() * 50),
            ),
            child: CircleParticle(
              radius: 2,
              paint: Paint()..color = const Color(0xFFFFEB3B),
            ),
          ),
        ),
      ),
    );
  }

  void showSplashParticles(Vector2 position) {
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 12,
          lifespan: 0.4,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 300),
            speed: Vector2(
              (_random.nextDouble() - 0.5) * 150,
              -150 - (_random.nextDouble() * 100),
            ),
            child: CircleParticle(
              radius: 2.5,
              paint: Paint()..color = const Color(0xFF795548),
            ),
          ),
        ),
      ),
    );
  }

  void showToxicParticles(Vector2 position) {
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 10,
          lifespan: 0.6,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 80),
            speed: Vector2(
              (_random.nextDouble() - 0.5) * 120,
              -80 - (_random.nextDouble() * 60),
            ),
            child: CircleParticle(
              radius: 3,
              paint: Paint()..color = const Color(0xFF4CAF50), // Toxic green
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:eco_trail/config/constants.dart';
import 'package:eco_trail/game/components/flower.dart';
import 'package:eco_trail/game/components/puddle.dart';
import 'package:eco_trail/game/components/toxic_item.dart';
import 'package:eco_trail/game/components/trash_item.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:flame/components.dart';

class SpawnerManager extends Component with HasGameReference<EcoTrailGame> {
  final Random _random = Random();
  late Timer _spawnTimer;

  // Tracking difficulty - updated by Game
  int currentDay = 1;
  
  // Spawn tracking for limited trash spawning
  int _trashSpawned = 0;
  int _maxTrashSpawns = 0;
  bool _trashLimitReached = false;

  SpawnerManager() {
    _spawnTimer = Timer(2.0, repeat: true, onTick: _spawnObject);
  }

  void updateDifficulty(int day) {
    currentDay = day;
    _updateSpawnRate();
    _resetSpawnCounts();
  }
  
  void _resetSpawnCounts() {
    _trashSpawned = 0;
    _maxTrashSpawns = GameConstants.getMaxTrashSpawnsForDay(currentDay);
    _trashLimitReached = false;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateSpawnRate();
    _resetSpawnCounts();
  }

  @override
  void update(double dt) {
    if (game.isMenu) return; // Don't spawn while in menu
    
    super.update(dt);
    _spawnTimer.update(dt);
  }

  void _updateSpawnRate() {
    double interval = GameConstants.spawnIntervalEasy;
    
    if (currentDay == 1) {
      interval = GameConstants.spawnIntervalTutorial;
    } else if (currentDay <= 5) {
      interval = GameConstants.spawnIntervalEasy;
    } else if (currentDay <= 10) {
      interval = GameConstants.spawnIntervalMedium;
    } else {
      interval = GameConstants.spawnIntervalHardBase; 
    }

    _spawnTimer.limit = interval;
  }

  void _spawnObject() {
    final roll = _random.nextDouble();
    
    // Check if we've reached the trash limit
    if (_trashSpawned >= _maxTrashSpawns) {
      _trashLimitReached = true;
    }

    // If trash limit reached, only spawn flowers (which still drain energy if missed)
    if (_trashLimitReached) {
      // 70% flower (player must grow them or lose energy), 30% puddle (obstacle)
      if (currentDay > 5 && roll >= 0.7) {
        _spawnPuddle();
      } else {
        _spawnFlower();
      }
      return;
    }

    // Normal spawning with difficulty scaling
    // Higher days spawn more trash proportionally
    double trashChance = _getTrashChanceForDay();
    
    if (currentDay > 5 && roll >= 0.95) {
      // 5% puddle chance on Day 6+
      _spawnPuddle();
    } else if (roll >= trashChance) {
      // Flower spawns
      _spawnFlower();
    } else {
      // Trash spawns (including toxic)
      if (_shouldSpawnToxic()) {
        _spawnToxic();
      } else {
        _spawnTrash();
      }
    }
  }
  
  /// Get trash spawn chance based on day (higher days = more trash)
  double _getTrashChanceForDay() {
    // Day 1: 60% trash, Day 5: 70%, Day 10: 80%, Day 15+: 85%
    if (currentDay == 1) return 0.60;
    if (currentDay <= 5) return 0.65 + (currentDay - 1) * 0.01;
    if (currentDay <= 10) return 0.70 + (currentDay - 5) * 0.02;
    return 0.85; // Max 85% trash chance
  }

  bool _shouldSpawnToxic() {
    if (currentDay < GameConstants.toxicMinDay) return false;
    
    final toxicChance = currentDay >= 11
        ? GameConstants.toxicSpawnChanceLate
        : GameConstants.toxicSpawnChanceEarly;
    
    return _random.nextDouble() < toxicChance;
  }

  void _spawnTrash() {
    // Track spawn count
    _trashSpawned++;
    
    final groundY = game.groundLevel;
    final minY = game.size.y * 0.2; 
    final maxY = groundY - (game.size.y * 0.1);

    // Complex positioning based on day - make trash harder to avoid
    double yPos = _getStrategicYPosition(minY, maxY);
    
    // Determine movement type based on day - earlier introduction of erratic movement
    MovementType movementType = MovementType.straight;
    bool isMovingVariant = false;
    
    // Erratic movement starts from Day 3 now (was Day 6)
    if (currentDay >= 3) {
      final movementRoll = _random.nextDouble();
      
      if (currentDay >= 11) {
        // Days 11+: 60% erratic (was 40%)
        if (movementRoll < 0.60) {
          final typeRoll = _random.nextDouble();
          if (typeRoll < 0.4) {
            movementType = MovementType.zigzag;
          } else if (typeRoll < 0.6) {
            movementType = MovementType.bouncing;
          } else if (typeRoll < 0.75) {
            movementType = MovementType.speedBurst;
          } else {
            movementType = MovementType.zigzag;
          }
        }
        if (movementType == MovementType.straight && _random.nextBool()) {
          isMovingVariant = true;
        }
      } else if (currentDay >= 6) {
        // Days 6-10: 45% have erratic movement (was 30%)
        if (movementRoll < 0.45) {
          movementType = MovementType.zigzag;
        }
      } else {
        // Days 3-5: 25% have zigzag movement (new)
        if (movementRoll < 0.25) {
          movementType = MovementType.zigzag;
        }
      }
    }

    // Determine multi-tap requirement based on day - starts earlier
    int requiredTaps = 1;
    if (currentDay >= 4) { // Was Day 6
      final multiTapChance = currentDay >= 11 
          ? 0.40  // Was 0.30
          : (currentDay >= 6 ? 0.30 : 0.15); // Gradual increase
      
      if (_random.nextDouble() < multiTapChance) {
        if (currentDay >= 11) {
          requiredTaps = _random.nextBool() ? 2 : 3;
        } else {
          requiredTaps = 2;
        }
      }
    }

    // Determine if this is a critical item - starts earlier
    bool isCritical = false;
    double criticalTimer = GameConstants.criticalTimerEarly;
    if (currentDay >= 4) { // Was Day 6
      final criticalChance = currentDay >= 11
          ? 0.35  // Was 0.25
          : (currentDay >= 6 ? 0.25 : 0.12);
      
      if (_random.nextDouble() < criticalChance) {
        isCritical = true;
        criticalTimer = currentDay >= 11
            ? GameConstants.criticalTimerLate
            : GameConstants.criticalTimerEarly;
      }
    }

    // Determine shrink scale based on day
    double shrinkMinScale = 1.0;
    if (currentDay >= GameConstants.shrinkMinDay) {
      shrinkMinScale = currentDay >= 11
          ? GameConstants.shrinkMinScaleLate
          : GameConstants.shrinkMinScaleEarly;
    }

    game.add(TrashItem(
      position: Vector2(game.size.x + 100, yPos),
      isMovingVariant: isMovingVariant,
      requiredTaps: requiredTaps,
      isCritical: isCritical,
      criticalTimer: criticalTimer,
      movementType: movementType,
      shrinkMinScale: shrinkMinScale,
    ));
  }
  
  /// Get strategic Y position to make trash harder to avoid on higher days
  double _getStrategicYPosition(double minY, double maxY) {
    final range = maxY - minY;
    
    if (currentDay <= 2) {
      // Days 1-2: Predictable middle positions
      return minY + range * (0.3 + _random.nextDouble() * 0.4);
    } else if (currentDay <= 5) {
      // Days 3-5: Wider spread, sometimes at edges
      return minY + _random.nextDouble() * range;
    } else if (currentDay <= 10) {
      // Days 6-10: Strategic positioning - often at extremes to force dodging
      final positionType = _random.nextInt(4);
      switch (positionType) {
        case 0: return minY + range * 0.1; // Near top
        case 1: return minY + range * 0.9; // Near bottom
        case 2: return minY + range * 0.5; // Center
        default: return minY + _random.nextDouble() * range; // Random
      }
    } else {
      // Days 11+: Unpredictable with bias toward player's likely position
      final bias = _random.nextDouble();
      if (bias < 0.3) {
        // 30% at random extremes
        return _random.nextBool() ? minY + range * 0.05 : minY + range * 0.95;
      } else {
        // 70% random but weighted toward center where player often is
        return minY + range * (0.2 + _random.nextDouble() * 0.6);
      }
    }
  }

  void _spawnToxic() {
    final groundY = game.groundLevel;
    final minY = game.size.y * 0.2;
    final maxY = groundY - (game.size.y * 0.1);

    final yPos = minY + _random.nextDouble() * (maxY - minY);

    game.add(ToxicItem(
      position: Vector2(game.size.x + 100, yPos),
    ));
  }

  void _spawnFlower() {
    // Randomize Y position - flowers can appear at different heights
    final minY = game.size.y * 0.25;
    final maxY = game.groundLevel - (game.size.y * 0.05);
    final randomY = minY + _random.nextDouble() * (maxY - minY);

    game.add(Flower(
      position: Vector2(game.size.x + 100, randomY),
    ));
  }

  void _spawnPuddle() {
    game.add(Puddle(
      position: Vector2(game.size.x + 100, game.groundLevel),
    ));
  }
}


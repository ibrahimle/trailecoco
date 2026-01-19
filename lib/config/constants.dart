/// Game Constants and Configuration parameters
/// as defined in the GDD and Implementation Plan.
class GameConstants {
  // Prevent instantiation
  GameConstants._();

  // -- Gameplay Parameters --

  // Eco-Meter (Health)
  static const double maxEcoMeter = 100.0;
  static const double ecoRestorationTrash = 5.0;
  static const double ecoRestorationFlower = 3.0;
  static const double ecoPenaltyMiss = 10.0;
  
  // Flower Miss Penalty - penalty for not growing a flower (scales with day)
  static const double flowerMissPenaltyBase = 5.0;      // Day 1-3: 5 damage
  static const double flowerMissPenaltyMedium = 8.0;    // Day 4-7: 8 damage
  static const double flowerMissPenaltyHard = 12.0;     // Day 8+: 12 damage
  
  // Helper to get flower miss penalty for a day
  static double getFlowerMissPenaltyForDay(int day) {
    if (day <= 3) return flowerMissPenaltyBase;
    if (day <= 7) return flowerMissPenaltyMedium;
    return flowerMissPenaltyHard;
  }
  
  // Base Drain Rates (per second) - increases with difficulty
  // These values are significant enough to create real challenge
  static const double drainRateTutorial = 1.0;    // Day 1: gentle but noticeable
  static const double drainRateEasy = 2.0;        // Day 2-5: steady pressure
  static const double drainRateMedium = 3.0;      // Day 6-10: challenging
  static const double drainRateHard = 4.0;        // Day 11+: intense

  // Scroll Speeds (pixels per second) - increases with day for more challenge
  static const double scrollSpeedTutorial = 100.0;
  static const double scrollSpeedEasy = 150.0;
  static const double scrollSpeedMedium = 200.0;
  static const double scrollSpeedHard = 250.0;
  static const double scrollSpeedHardBase = 250.0;
  static const double scrollSpeedMax = 350.0;

  // Spawn Intervals (seconds)
  static const double spawnIntervalTutorial = 3.0;
  static const double spawnIntervalEasy = 2.0;
  static const double spawnIntervalMedium = 1.5;
  static const double spawnIntervalHardBase = 1.0;
  static const double spawnIntervalMin = 0.5;

  // Trash Collection Goals - increases with day for proper difficulty progression
  // Base trash requirement and increment per day
  static const int trashGoalBase = 10;         // Day 1: 10 trash
  static const int trashGoalIncrement = 2;     // Each day adds 2 more trash requirement
  static const int trashGoalMax = 30;          // Maximum trash goal cap
  
  // Spawn Limits - spawn slightly more than needed to force intentional gameplay
  static const int trashSpawnBuffer = 3;       // Spawn 3 extra trash beyond goal (was 2, gives slight margin)
  
  // Helper to calculate trash goal for any day
  static int getTrashGoalForDay(int day) {
    final goal = trashGoalBase + ((day - 1) * trashGoalIncrement);
    return goal.clamp(trashGoalBase, trashGoalMax);
  }
  
  // Helper to get max trash spawns for a day (goal + buffer)
  static int getMaxTrashSpawnsForDay(int day) {
    return getTrashGoalForDay(day) + trashSpawnBuffer;
  }

  // Helper to get scroll speed for a day - progressive scaling
  static double getScrollSpeedForDay(int day) {
    if (day == 1) return scrollSpeedTutorial;
    if (day <= 3) return scrollSpeedEasy;
    if (day <= 5) return scrollSpeedEasy + 25; // 175
    if (day <= 7) return scrollSpeedMedium;    // 200
    if (day <= 10) return scrollSpeedMedium + 25; // 225
    // Day 11+: scales up to max
    final extraSpeed = (day - 10) * 10.0;
    return (scrollSpeedHard + extraSpeed).clamp(scrollSpeedTutorial, scrollSpeedMax);
  }

  // Helper to get drain rate for a day - progressive scaling
  static double getDrainRateForDay(int day) {
    if (day == 1) return drainRateTutorial;
    if (day <= 5) return drainRateEasy;
    if (day <= 10) return drainRateMedium;
    return drainRateHard;
  }

  // Distance Goals (meters/units) - legacy, keeping for reference
  static const double distanceGoalEasy = 500.0;
  static const double distanceGoalMedium = 750.0;
  static const double distanceGoalHard = 1000.0;

  // -- Economy --
  
  static const int tokenRewardTrash = 1;
  static const int tokenRewardFlower = 2;
  static const int tokenRewardLevelComplete = 50;

  // Shop Costs
  static const int costCleanRiver = 200;
  static const int costPlantTrees = 500;
  static const int costAttractWildlife = 1000;

  // -- Asset Paths --
  
  // Backgrounds
  static const String bgSky = 'backgrounds/bg_sky.png';
  static const String bgMountains = 'backgrounds/bg_mountains.png';
  static const String bgNature = 'backgrounds/bg_nature.png';
  static const String bgPath = 'backgrounds/bg_path.png';
  static const String bgRiverBlue = 'backgrounds/bg_river_blue.png';
  static const String bgRiverBrown = 'backgrounds/bg_river_brown.png';

  // Characters
  static const String charHikerRun = 'characters/char_hiker_run_1.png'; // Using frame 1 as base
  static const String charHikerSit = 'characters/char_hiker_sit_1.png';
  
  // Items
  static const String itemTrashCan = 'items/item_trash_can.png';
  static const String itemTrashBottle = 'items/item_trash_bottle.png';
  static const String itemTrashWrapper = 'items/item_trash_wrapper.png';
  static const String itemBag = 'items/item_trash_bag.png';
  
  static const String itemFlowerWithered = 'items/item_flower_withered.png';
  static const String itemFlowerBloomed = 'items/item_flower_bloomed.png';
  static const String itemPuddle = 'items/item_puddle.png';

  // Audio
  static const String bgmGameplay = 'bgm_gameplay.mp3';
  static const String sfxCollect = 'sfx_collect.mp3';
  static const String sfxBloom = 'sfx_bloom.mp3';
  static const String sfxMud = 'sfx_mud.mp3';
  static const String sfxWin = 'sfx_win.mp3';
  static const String sfxLose = 'sfx_lose.mp3';
  static const String sfxPurchase = 'sfx_purchase.mp3';
  static const String sfxButton = 'sfx_button.mp3';

  // -- Multi-Tap Trash --
  static const int multiTapMinDay = 6;
  static const double multiTapChanceEarly = 0.2;  // Days 6-10
  static const double multiTapChanceLate = 0.3;   // Days 11+
  static const int multiTapRequiredEarly = 2;     // Days 6-10
  static const int multiTapRequiredMax = 3;       // Days 11+
  static const double multiTapResetTime = 1.0;    // Seconds before tap progress resets

  // -- Toxic Waste (Decoy Items) --
  static const int toxicMinDay = 8;
  static const double toxicSpawnChanceEarly = 0.10;  // Days 8-10
  static const double toxicSpawnChanceLate = 0.15;   // Days 11+
  static const double toxicDamage = 10.0;            // Same as ecoPenaltyMiss
  static const String itemToxicBarrel = 'items/item_toxic_barrel.png';

  // -- Critical Trash (Timed Items) --
  static const int criticalMinDay = 6;
  static const double criticalChanceEarly = 0.15;    // Days 6-10
  static const double criticalChanceLate = 0.25;     // Days 11+
  static const double criticalTimerEarly = 3.0;      // Days 6-10: 3 seconds
  static const double criticalTimerLate = 2.0;       // Days 11+: 2 seconds
  static const double criticalDamageMultiplier = 2.0;

  // -- Erratic Movement --
  static const int erraticMinDay = 6;
  static const double zigzagChanceEarly = 0.30;      // Days 6-10
  static const double zigzagChanceLate = 0.40;       // Days 11+
  static const double bounceChance = 0.15;           // Chance for bouncing (Days 11+)
  static const double speedBurstChance = 0.10;       // Chance for speed bursts (Days 11+)
  static const double speedBurstMultiplier = 2.0;    // 2x speed during burst
  static const double speedBurstDuration = 0.5;      // 0.5 second bursts

  // -- Size Shrinking --
  static const int shrinkMinDay = 8;
  static const double shrinkMinScaleEarly = 0.70;    // Days 8-10: shrink to 70%
  static const double shrinkMinScaleLate = 0.50;     // Days 11+: shrink to 50%

  // -- Hiker Movement (Drag) --
  static const double hikerMoveSpeed = 300.0;        // Pixels per second when dragging
  static const double hikerReturnSpeed = 150.0;      // Speed to return to default position

  // -- Trash Collision --
  static const double ecoPenaltyTrashCollision = 15.0; // Penalty when hiker touches trash

  // -- Eco Facts --
  static const List<String> ecoFacts = [
    'A single plastic bottle can take up to 450 years to decompose.',
    'Recycling one aluminum can saves enough energy to run a TV for 3 hours.',
    'Over 8 million tons of plastic end up in our oceans every year.',
    'Trees absorb CO2 and release oxygen - one tree can absorb 48 pounds of CO2 per year.',
    'Turning off the tap while brushing your teeth can save up to 8 gallons of water a day.',
    'Glass is 100% recyclable and can be recycled endlessly without loss of quality.',
    'The average person generates over 4 pounds of trash every single day.',
    'Composting food scraps can reduce landfill waste by up to 30%.',
    'LED bulbs use 75% less energy than traditional incandescent bulbs.',
    'A reusable water bottle can replace over 150 plastic bottles per year.',
    'Paper can be recycled up to 7 times before the fibers become too short.',
    'Bees pollinate approximately 75% of the fruits, nuts, and vegetables we eat.',
    'Planting native plants helps local wildlife thrive and reduces water usage.',
    'E-waste is the fastest growing waste stream in the world.',
    'Walking or biking instead of driving reduces your carbon footprint significantly.',
    'One gallon of used motor oil can contaminate one million gallons of fresh water.',
    'Coral reefs support 25% of all marine species despite covering less than 1% of the ocean floor.',
    'Reducing meat consumption by one day a week can save significant amounts of water and reduce emissions.',
  ];
}


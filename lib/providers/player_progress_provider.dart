import 'package:flutter/foundation.dart';
import 'package:eco_trail/services/storage_service.dart';

class PlayerProgressProvider extends ChangeNotifier {
  final StorageService _storage;

  PlayerProgressProvider(this._storage);

  int get currentDay => _storage.currentDay;
  int get totalTokens => _storage.totalTokens;
  int get highScore => _storage.highScore;
  bool get upgradeRiver => _storage.upgradeRiver;
  bool get upgradeTrees => _storage.upgradeTrees;
  bool get upgradeWildlife => _storage.upgradeWildlife;
  bool get musicEnabled => _storage.musicEnabled;
  bool get sfxEnabled => _storage.sfxEnabled;

  Future<void> saveRun(int tokensEarned, int runScore) async {
    int newTotalTokens = totalTokens + tokensEarned;
    await _storage.setTotalTokens(newTotalTokens);
    
    if (runScore > highScore) {
      await _storage.setHighScore(runScore);
    }
    notifyListeners();
  }

  Future<void> unlockNextDay() async {
    await _storage.setCurrentDay(currentDay + 1);
    notifyListeners();
  }
  
  // Also need to allow setting current day if player wants to replay?
  // Plan says: "Player can replay any unlocked Day from a level select or always plays the latest unlocked Day"
  // For now, simpler implementation: just tracks highest day.

  Future<void> purchaseUpgradeRiver(int cost) async {
    if (totalTokens >= cost && !upgradeRiver) {
      await _storage.setTotalTokens(totalTokens - cost);
      await _storage.setUpgradeRiver(true);
      notifyListeners();
    }
  }

  Future<void> purchaseUpgradeTrees(int cost) async {
    if (totalTokens >= cost && !upgradeTrees) {
      await _storage.setTotalTokens(totalTokens - cost);
      await _storage.setUpgradeTrees(true);
      notifyListeners();
    }
  }

  Future<void> purchaseUpgradeWildlife(int cost) async {
    if (totalTokens >= cost && !upgradeWildlife) {
      await _storage.setTotalTokens(totalTokens - cost);
      await _storage.setUpgradeWildlife(true);
      notifyListeners();
    }
  }

  Future<void> toggleMusic(bool enabled) async {
    await _storage.setMusicEnabled(enabled);
    notifyListeners();
  }

  Future<void> toggleSfx(bool enabled) async {
    await _storage.setSfxEnabled(enabled);
    notifyListeners();
  }
  
  Future<void> addTokens(int amount) async {
    await _storage.setTotalTokens(totalTokens + amount);
    notifyListeners();
  }
}


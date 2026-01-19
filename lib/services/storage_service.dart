import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const String keyCurrentDay = 'currentDay';
  static const String keyTotalTokens = 'totalTokens';
  static const String keyHighScore = 'highScore';
  static const String keyUpgradeRiver = 'upgradeRiver';
  static const String keyUpgradeTrees = 'upgradeTrees';
  static const String keyUpgradeWildlife = 'upgradeWildlife';
  static const String keyMusicEnabled = 'musicEnabled';
  static const String keySfxEnabled = 'sfxEnabled';

  // Getters
  int get currentDay => _prefs.getInt(keyCurrentDay) ?? 1;
  int get totalTokens => _prefs.getInt(keyTotalTokens) ?? 0;
  int get highScore => _prefs.getInt(keyHighScore) ?? 0;
  bool get upgradeRiver => _prefs.getBool(keyUpgradeRiver) ?? false;
  bool get upgradeTrees => _prefs.getBool(keyUpgradeTrees) ?? false;
  bool get upgradeWildlife => _prefs.getBool(keyUpgradeWildlife) ?? false;
  bool get musicEnabled => _prefs.getBool(keyMusicEnabled) ?? true;
  bool get sfxEnabled => _prefs.getBool(keySfxEnabled) ?? true;

  // Setters
  Future<void> setCurrentDay(int day) async => await _prefs.setInt(keyCurrentDay, day);
  Future<void> setTotalTokens(int tokens) async => await _prefs.setInt(keyTotalTokens, tokens);
  Future<void> setHighScore(int score) async => await _prefs.setInt(keyHighScore, score);
  Future<void> setUpgradeRiver(bool purchased) async => await _prefs.setBool(keyUpgradeRiver, purchased);
  Future<void> setUpgradeTrees(bool purchased) async => await _prefs.setBool(keyUpgradeTrees, purchased);
  Future<void> setUpgradeWildlife(bool purchased) async => await _prefs.setBool(keyUpgradeWildlife, purchased);
  Future<void> setMusicEnabled(bool enabled) async => await _prefs.setBool(keyMusicEnabled, enabled);
  Future<void> setSfxEnabled(bool enabled) async => await _prefs.setBool(keySfxEnabled, enabled);
}


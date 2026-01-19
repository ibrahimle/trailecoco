import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:eco_trail/providers/player_progress_provider.dart';
import 'package:eco_trail/services/storage_service.dart';
import 'package:eco_trail/ui/overlays/game_over.dart';
import 'package:eco_trail/ui/overlays/how_to_play.dart';
import 'package:eco_trail/ui/overlays/hud.dart';
import 'package:eco_trail/ui/overlays/level_complete.dart';
import 'package:eco_trail/ui/overlays/level_select.dart';
import 'package:eco_trail/ui/overlays/main_menu.dart';
import 'package:eco_trail/ui/overlays/pause_menu.dart';
import 'package:eco_trail/ui/overlays/privacy_policy.dart';
import 'package:eco_trail/ui/overlays/settings.dart';
import 'package:eco_trail/ui/overlays/shop.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to landscape only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlayerProgressProvider(storageService),
        ),
      ],
      child: const EcoTrailApp(),
    ),
  );
}

class EcoTrailApp extends StatelessWidget {
  const EcoTrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: EcoTheme.sproutGreen,
          primary: EcoTheme.sproutGreen,
          secondary: EcoTheme.skyBlue,
          surface: EcoTheme.cloudWhite,
        ),
        scaffoldBackgroundColor: EcoTheme.cloudWhite,
        textTheme: EcoTheme.getTextTheme(),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: EcoTrailGame(
          playerProgress: Provider.of<PlayerProgressProvider>(
            context,
            listen: false,
          ),
        ),
        loadingBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error) => Center(child: Text('Error: $error')),
        // Phase 6: Registered Overlays
        overlayBuilderMap: {
          'MainMenu': (context, EcoTrailGame game) => MainMenu(game: game),
          'HUD': (context, EcoTrailGame game) => HUD(game: game),
          'PauseMenu': (context, EcoTrailGame game) => PauseMenu(game: game),
          'LevelComplete': (context, EcoTrailGame game) =>
              LevelComplete(game: game),
          'GameOver': (context, EcoTrailGame game) => GameOver(game: game),
          'HowToPlay': (context, EcoTrailGame game) => HowToPlay(game: game),
          'Settings': (context, EcoTrailGame game) => Settings(game: game),
          'PrivacyPolicy': (context, EcoTrailGame game) =>
              PrivacyPolicy(game: game),
          'Shop': (context, EcoTrailGame game) => Shop(game: game),
          'LevelSelect': (context, EcoTrailGame game) =>
              LevelSelect(game: game),
        },
      ),
    );
  }
}

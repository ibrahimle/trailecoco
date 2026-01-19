import 'dart:ui';

import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:eco_trail/providers/player_progress_provider.dart';
import 'package:eco_trail/ui/widgets/soft_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  final EcoTrailGame game;

  const Settings({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth * 0.9;
            final cardWidth = maxWidth.clamp(280.0, 300.0);
            
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: cardWidth,
                maxHeight: constraints.maxHeight * 0.9,
              ),
              child: SoftCard(
                child: Consumer<PlayerProgressProvider>(
                  builder: (context, progress, child) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Gear', style: EcoTheme.getTextTheme().headlineLarge),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => game.overlays.remove('Settings'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          SwitchListTile(
                            title: Text('Music', style: EcoTheme.getTextTheme().bodyMedium),
                            value: progress.musicEnabled,
                            activeTrackColor: EcoTheme.sproutGreen,
                            onChanged: (val) {
                              progress.toggleMusic(val);
                              game.updateMusicState();
                            },
                          ),
                          
                          SwitchListTile(
                            title: Text('Sound Effects', style: EcoTheme.getTextTheme().bodyMedium),
                            value: progress.sfxEnabled,
                            activeTrackColor: EcoTheme.sproutGreen,
                            onChanged: (val) {
                              progress.toggleSfx(val);
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextButton(
                            onPressed: () => game.overlays.add('PrivacyPolicy'),
                            child: Text('Privacy Policy', style: EcoTheme.getTextTheme().labelSmall?.copyWith(decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


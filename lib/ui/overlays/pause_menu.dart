import 'dart:ui';

import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:eco_trail/providers/player_progress_provider.dart';
import 'package:eco_trail/ui/widgets/juicy_button.dart';
import 'package:eco_trail/ui/widgets/soft_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PauseMenu extends StatelessWidget {
  final EcoTrailGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.9,
                  maxHeight: constraints.maxHeight * 0.9,
                ),
                child: SoftCard(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rest Stop',
                          style: EcoTheme.getTextTheme().headlineLarge,
                        ),
                        const SizedBox(height: EcoTheme.spacingStandard),
                        
                        // Buttons
                        JuicyButton(
                          label: 'Resume Hike',
                          onPressed: () => game.resumeGame(),
                        ),
                        const SizedBox(height: EcoTheme.spacingStandard),
                        
                        JuicyButton(
                          label: 'Retire to Camp',
                          color: EcoTheme.trailBrown,
                          onPressed: () => game.retireToCamp(),
                        ),
                        
                        const SizedBox(height: EcoTheme.spacingStandard),
                        
                        // Audio Toggles
                        Consumer<PlayerProgressProvider>(
                          builder: (context, progress, child) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    progress.musicEnabled ? Icons.music_note : Icons.music_off,
                                    color: EcoTheme.softCharcoal,
                                  ),
                                  onPressed: () {
                                    progress.toggleMusic(!progress.musicEnabled);
                                    game.updateMusicState();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    progress.sfxEnabled ? Icons.volume_up : Icons.volume_off,
                                    color: EcoTheme.softCharcoal,
                                  ),
                                  onPressed: () {
                                    progress.toggleSfx(!progress.sfxEnabled);
                                  },
                                ),
                              ],
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


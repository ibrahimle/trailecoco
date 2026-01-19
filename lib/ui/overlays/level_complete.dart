import 'dart:math';
import 'dart:ui';

import 'package:eco_trail/config/constants.dart';
import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:eco_trail/ui/widgets/juicy_button.dart';
import 'package:eco_trail/ui/widgets/soft_card.dart';
import 'package:flutter/material.dart';

class LevelComplete extends StatelessWidget {
  final EcoTrailGame game;

  const LevelComplete({super.key, required this.game});

  // Get a random eco fact
  String _getRandomFact() {
    final random = Random();
    return GameConstants.ecoFacts[random.nextInt(GameConstants.ecoFacts.length)];
  }

  @override
  Widget build(BuildContext context) {
    final ecoFact = _getRandomFact();
    
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxHeight < 500;
            final imageHeight = isSmallScreen ? 100.0 : 150.0;
            final spacing = isSmallScreen ? EcoTheme.spacingTight : EcoTheme.spacingStandard;
            
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.9,
                maxHeight: constraints.maxHeight * 0.95,
              ),
              child: SoftCard(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Trail Cleared!',
                        style: EcoTheme.getTextTheme().headlineLarge?.copyWith(color: EcoTheme.sproutGreen),
                      ),
                      SizedBox(height: spacing),
                      
                      // Victory Visual
                      Image.asset(
                        'assets/images/characters/char_hiker_win.png',
                        height: imageHeight,
                      ),
                      SizedBox(height: spacing),
                      
                      // Stats Panel
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: EcoTheme.cloudWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: EcoTheme.softCharcoal.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            _StatRow(label: 'Trash Collected', value: '${game.score}'),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: spacing),
                      
                      // Eco Fact
                      Container(
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: EcoTheme.sproutGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: EcoTheme.sproutGreen.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.eco,
                              color: EcoTheme.sproutGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ecoFact,
                                style: EcoTheme.getTextTheme().labelSmall?.copyWith(
                                  color: EcoTheme.softCharcoal.withValues(alpha: 0.8),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: spacing),
                      
                      // Buttons
                      Wrap(
                        spacing: EcoTheme.spacingTight,
                        runSpacing: EcoTheme.spacingTight,
                        alignment: WrapAlignment.center,
                        children: [
                          JuicyButton(
                            label: 'Base Camp',
                            color: EcoTheme.trailBrown,
                            isSecondary: true,
                            onPressed: () => game.retireToCamp(),
                          ),
                          JuicyButton(
                            label: 'Next Trail',
                            onPressed: () => game.nextLevel(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: EcoTheme.getTextTheme().bodyMedium),
          const SizedBox(width: 24),
          Text(value, style: EcoTheme.getTextTheme().titleLarge),
        ],
      ),
    );
  }
}


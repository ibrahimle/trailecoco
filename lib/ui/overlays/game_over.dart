import 'dart:ui';

import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:eco_trail/ui/widgets/juicy_button.dart';
import 'package:eco_trail/ui/widgets/soft_card.dart';
import 'package:flutter/material.dart';

class GameOver extends StatelessWidget {
  final EcoTrailGame game;

  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxHeight < 400;
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
                        'Too Polluted!',
                        style: EcoTheme.getTextTheme().headlineLarge?.copyWith(color: EcoTheme.ecoRed),
                      ),
                      SizedBox(height: spacing),
                      
                      // Lose Visual
                      Image.asset(
                        'assets/images/characters/char_hiker_tired.png',
                        height: imageHeight,
                      ),
                      SizedBox(height: spacing),
                      
                      Text(
                        "The trail became too polluted.",
                        style: EcoTheme.getTextTheme().bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: spacing),
                      
                      // Buttons
                      Wrap(
                        spacing: EcoTheme.spacingTight,
                        runSpacing: EcoTheme.spacingTight,
                        alignment: WrapAlignment.center,
                        children: [
                          JuicyButton(
                            label: 'Give Up',
                            color: EcoTheme.trailBrown,
                            isSecondary: true,
                            onPressed: () => game.retireToCamp(),
                          ),
                          JuicyButton(
                            label: 'Try Again',
                            onPressed: () => game.restartLevel(),
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


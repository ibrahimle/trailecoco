import 'dart:ui';

import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:eco_trail/ui/widgets/soft_card.dart';
import 'package:flutter/material.dart';

class HowToPlay extends StatelessWidget {
  final EcoTrailGame game;

  const HowToPlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight * 0.85;
            final maxWidth = constraints.maxWidth * 0.9;
            final cardHeight = maxHeight.clamp(250.0, 400.0);
            final cardWidth = maxWidth.clamp(280.0, 350.0);
            
            return SizedBox(
              height: cardHeight,
              width: cardWidth,
              child: SoftCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text("Ranger's Guide", style: EcoTheme.getTextTheme().headlineLarge),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => game.overlays.remove('HowToPlay'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: PageView(
                        children: const [
                          _GuidePage(
                            title: 'Tap to Collect',
                            description: 'Tap trash items to clean the trail and earn tokens.',
                            icon: Icons.touch_app,
                          ),
                          _GuidePage(
                            title: 'Avoid Polluting',
                            description: 'Don\'t let trash pass you! It hurts the environment.',
                            icon: Icons.warning,
                          ),
                          _GuidePage(
                            title: 'Watch Your Step',
                            description: 'Avoid puddles to keep moving fast.',
                            icon: Icons.water_drop,
                          ),
                          _GuidePage(
                            title: 'Heavy Trash',
                            description: 'Some trash needs multiple quick taps to collect! Don\'t stop tapping!',
                            icon: Icons.fitness_center,
                          ),
                          _GuidePage(
                            title: 'Toxic Barrels',
                            description: 'Don\'t tap the green barrels! Let them pass safely.',
                            icon: Icons.dangerous,
                          ),
                          _GuidePage(
                            title: 'Urgent Items',
                            description: 'Red glowing trash expires quickly! Collect it before the timer runs out.',
                            icon: Icons.timer,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GuidePage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _GuidePage({
    required this.title, 
    required this.description, 
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize = constraints.maxHeight < 200 ? 50.0 : 80.0;
        final spacing = constraints.maxHeight < 200 ? 8.0 : 16.0;
        
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: EcoTheme.sproutGreen),
              SizedBox(height: spacing),
              Text(title, style: EcoTheme.getTextTheme().titleLarge),
              SizedBox(height: spacing / 2),
              Text(
                description, 
                style: EcoTheme.getTextTheme().bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}


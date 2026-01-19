import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:eco_trail/ui/widgets/juicy_button.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  final EcoTrailGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 550;
        final logoWidth = isSmallScreen ? 200.0 : 300.0;
        final sectionSpacing = isSmallScreen ? EcoTheme.spacingStandard : EcoTheme.spacingSection;
        final buttonSpacing = isSmallScreen ? EcoTheme.spacingTight : EcoTheme.spacingStandard;
        
        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: EcoTheme.spacingStandard),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/ui/ui_logo.png',
                    width: logoWidth,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  // Buttons
                  SizedBox(
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        JuicyButton(
                          label: 'Start Hike',
                          onPressed: () => game.startHike(),
                        ),
                        SizedBox(height: buttonSpacing),
                        
                        JuicyButton(
                          label: 'Select Day',
                          color: EcoTheme.bloomPink,
                          onPressed: () {
                            game.overlays.add('LevelSelect');
                          },
                        ),
                        SizedBox(height: buttonSpacing),
                        
                        JuicyButton(
                          label: 'Recycle Station',
                          color: EcoTheme.skyBlue,
                          onPressed: () {
                            game.overlays.add('Shop');
                          },
                        ),
                        SizedBox(height: buttonSpacing),
                        
                        JuicyButton(
                          label: "Ranger's Guide",
                          color: EcoTheme.trailBrown,
                          onPressed: () {
                            game.overlays.add('HowToPlay');
                          },
                        ),
                        SizedBox(height: buttonSpacing),
                        
                        JuicyButton(
                          label: 'Gear',
                          color: EcoTheme.mutedGrey,
                          onPressed: () {
                            game.overlays.add('Settings');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


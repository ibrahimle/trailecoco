import 'dart:ui';

import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:eco_trail/ui/widgets/juicy_button.dart';
import 'package:eco_trail/ui/widgets/soft_card.dart';
import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  final EcoTrailGame game;

  const PrivacyPolicy({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: SizedBox(
          width: 320,
          child: SoftCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Ranger's Code", style: EcoTheme.getTextTheme().headlineLarge),
                const SizedBox(height: 16),
                Text(
                  "We respect nature and your privacy. EcoTrail does not collect any personal data. Your progress is stored locally on your device.",
                  style: EcoTheme.getTextTheme().bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                JuicyButton(
                  label: 'Understood',
                  onPressed: () {
                    game.overlays.remove('PrivacyPolicy');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


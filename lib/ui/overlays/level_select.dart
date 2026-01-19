import 'package:eco_trail/config/constants.dart';
import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:eco_trail/ui/widgets/juicy_button.dart';
import 'package:eco_trail/ui/widgets/soft_card.dart';
import 'package:flutter/material.dart';

class LevelSelect extends StatelessWidget {
  final EcoTrailGame game;

  const LevelSelect({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final highestUnlockedDay = game.playerProgress.currentDay;
    // Show a reasonable number of levels (up to 20 or highest + 5)
    final totalLevelsToShow = (highestUnlockedDay + 5).clamp(10, 30);

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight * 0.9;
          final maxWidth = constraints.maxWidth * 0.9;
          final cardHeight = maxHeight.clamp(250.0, 450.0);
          final cardWidth = maxWidth.clamp(280.0, 320.0);

          return SoftCard(
            padding: const EdgeInsets.all(EcoTheme.spacingStandard),
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Column(
                children: [
                  // Header
                  Text(
                    'Select Day',
                    style: EcoTheme.getTextTheme().headlineLarge,
                  ),
                  const SizedBox(height: EcoTheme.spacingStandard),

                  // Scrollable Level List
                  Expanded(
                    child: ListView.builder(
                      itemCount: totalLevelsToShow,
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final isUnlocked = day <= highestUnlockedDay;
                        final isCurrentDay = day == highestUnlockedDay;
                        final isCompleted = day < highestUnlockedDay;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: EcoTheme.spacingTight / 2,
                          ),
                          child: _LevelTile(
                            day: day,
                            isUnlocked: isUnlocked,
                            isCurrentDay: isCurrentDay,
                            isCompleted: isCompleted,
                            onTap: isUnlocked
                                ? () {
                                    game.overlays.remove('LevelSelect');
                                    game.startLevel(day);
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: EcoTheme.spacingStandard),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    child: JuicyButton(
                      label: 'Back',
                      color: EcoTheme.mutedGrey,
                      onPressed: () {
                        game.overlays.remove('LevelSelect');
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int day;
  final bool isUnlocked;
  final bool isCurrentDay;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.day,
    required this.isUnlocked,
    required this.isCurrentDay,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (!isUnlocked) {
      // Locked
      backgroundColor = EcoTheme.mutedGrey.withValues(alpha: 0.3);
      borderColor = EcoTheme.mutedGrey;
      textColor = EcoTheme.mutedGrey;
    } else if (isCurrentDay) {
      // Current (highest unlocked)
      backgroundColor = EcoTheme.skyBlue.withValues(alpha: 0.2);
      borderColor = EcoTheme.skyBlue;
      textColor = EcoTheme.softCharcoal;
    } else if (isCompleted) {
      // Completed
      backgroundColor = EcoTheme.sproutGreen.withValues(alpha: 0.2);
      borderColor = EcoTheme.sproutGreen;
      textColor = EcoTheme.softCharcoal;
    } else {
      // Default unlocked
      backgroundColor = EcoTheme.cloudWhite;
      borderColor = EcoTheme.trailBrown;
      textColor = EcoTheme.softCharcoal;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EcoTheme.smallRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: EcoTheme.spacingStandard,
            vertical: EcoTheme.spacingTight + 4,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(EcoTheme.smallRadius),
            border: Border.all(
              color: borderColor,
              width: isCurrentDay ? EcoTheme.borderThick : EcoTheme.borderThin,
            ),
          ),
          child: Row(
            children: [
              // Day Number Circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked ? borderColor : EcoTheme.mutedGrey,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: EcoTheme.getTextTheme().titleLarge?.copyWith(
                    color: EcoTheme.cloudWhite,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: EcoTheme.spacingStandard),

              // Day Label and Goal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Day $day',
                      style: EcoTheme.getTextTheme().bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: isCurrentDay
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Collect ${GameConstants.getTrashGoalForDay(day)} items',
                      style: EcoTheme.getTextTheme().labelSmall?.copyWith(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Icon
              if (!isUnlocked)
                const Icon(Icons.lock, color: EcoTheme.mutedGrey, size: 24)
              else if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: EcoTheme.sproutGreen,
                  size: 24,
                )
              else
                const Icon(
                  Icons.play_circle_filled,
                  color: EcoTheme.skyBlue,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

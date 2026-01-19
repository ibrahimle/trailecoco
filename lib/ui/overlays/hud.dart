import 'dart:async';

import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:flutter/material.dart';

class HUD extends StatefulWidget {
  final EcoTrailGame game;

  const HUD({super.key, required this.game});

  @override
  State<HUD> createState() => _HUDState();
}

class _HUDState extends State<HUD> {
  late Timer _timer;
  Color _borderColor = EcoTheme.trailBrown; // Initial border color
  
  @override
  void initState() {
    super.initState();
    // Refresh UI every 100ms
    double lastEcoMeter = widget.game.ecoMeter;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      
      // Check for health changes to flash
      if (widget.game.ecoMeter < lastEcoMeter) {
        // Damage: Flash Red
        _flashBorder(Colors.red);
      } else if (widget.game.ecoMeter > lastEcoMeter) {
         // Heal: Flash Green
        _flashBorder(EcoTheme.sproutGreen);
      }
      lastEcoMeter = widget.game.ecoMeter;

      setState(() {});
    });
  }

  void _flashBorder(Color color) {
    setState(() => _borderColor = color);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _borderColor = EcoTheme.trailBrown); // Reset to default? 
      // Actually frame image is used, so we might need to wrap it in a Container or ColorFilter
      // For now, let's just assume we want to tint it or wrap in a border.
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EcoTheme.spacingStandard),
      child: Column(
        children: [
          // Top Bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eco-Meter (Top Left)
              Container(
                decoration: BoxDecoration(
                  border: _borderColor != EcoTheme.trailBrown ? Border.all(color: _borderColor, width: 3) : null,
                  borderRadius: BorderRadius.circular(8), // approximate radius of frame
                ),
                width: 200,
                height: 40,
                child: Stack(
                  children: [
                    // Frame
                    Image.asset('assets/images/ui/ui_health_frame.png', fit: BoxFit.contain),
                    // Fill (Clipped)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), // Tuned padding
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                             return FractionallySizedBox(
                               alignment: Alignment.centerLeft,
                               widthFactor: (widget.game.ecoMeter / 100.0).clamp(0.0, 1.0),
                               child: Image.asset(
                                 'assets/images/ui/ui_health_fill.png', 
                                 fit: BoxFit.cover,
                               ),
                             );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: EcoTheme.spacingStandard),
              
              // Day Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: EcoTheme.bloomPink,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: EcoTheme.softCharcoal, width: 2),
                ),
                child: Text(
                  'Day ${widget.game.currentDay}',
                  style: EcoTheme.getTextTheme().labelSmall?.copyWith(
                    color: EcoTheme.cloudWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Progress Bar (Top Center) - shows trash collection goal for all days
              Container(
                width: 150,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: EcoTheme.trailBrown, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${widget.game.score}/${widget.game.trashGoal} Items", 
                  style: EcoTheme.getTextTheme().labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              const Spacer(),

              // Score Display (Top Right)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: EcoTheme.softCharcoal, width: 2),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/images/ui/ui_icon_bag.png', width: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.game.score}',
                      style: EcoTheme.getTextTheme().titleLarge?.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: EcoTheme.spacingStandard),
              
              // Pause Button
              IconButton(
                icon: const Icon(Icons.pause_circle_filled, size: 48, color: EcoTheme.softCharcoal),
                onPressed: () => widget.game.pauseGame(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

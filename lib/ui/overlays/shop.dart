import 'dart:ui';

import 'package:eco_trail/config/constants.dart';
import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:eco_trail/providers/player_progress_provider.dart';
import 'package:eco_trail/ui/widgets/soft_card.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Shop extends StatelessWidget {
  final EcoTrailGame game;

  const Shop({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: SizedBox(
          width: 340,
          height: 600,
          child: SoftCard(
            child: Consumer<PlayerProgressProvider>(
              builder: (context, progress, child) {
                return Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recycle Station',
                            style: EcoTheme.getTextTheme()
                                .headlineLarge
                                ?.copyWith(fontSize: 24)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => game.overlays.remove('Shop'),
                        ),
                      ],
                    ),
                    const Divider(),
                    // Balance
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/ui/ui_icon_token.png',
                              width: 32),
                          const SizedBox(width: 8),
                          Text('${progress.totalTokens}',
                              style: EcoTheme.getTextTheme()
                                  .headlineMedium
                                  ?.copyWith(color: EcoTheme.trailBrown)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // List
                    Expanded(
                      child: ListView(
                        children: [
                          _buildShopItem(
                            context,
                            name: 'Clean the River',
                            description: 'Restores the river to pristine blue.',
                            cost: GameConstants.costCleanRiver,
                            isOwned: progress.upgradeRiver,
                            onBuy: () {
                              _buy(context, progress.purchaseUpgradeRiver,
                                  GameConstants.costCleanRiver, progress.totalTokens);
                            },
                          ),
                          _buildShopItem(
                            context,
                            name: 'Plant More Trees',
                            description: 'Adds more greenery to the forest.',
                            cost: GameConstants.costPlantTrees,
                            isOwned: progress.upgradeTrees,
                            onBuy: () {
                              _buy(context, progress.purchaseUpgradeTrees,
                                  GameConstants.costPlantTrees, progress.totalTokens);
                            },
                          ),
                          _buildShopItem(
                            context,
                            name: 'Attract Wildlife',
                            description: 'Bring birds and butterflies back.',
                            cost: GameConstants.costAttractWildlife,
                            isOwned: progress.upgradeWildlife,
                            onBuy: () {
                              _buy(context, progress.purchaseUpgradeWildlife,
                                  GameConstants.costAttractWildlife, progress.totalTokens);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _buy(BuildContext context, Future<void> Function(int) buyAction, int cost, int balance) {
     if (balance >= cost) {
       buyAction(cost);
       FlameAudio.play(GameConstants.sfxPurchase);
     } else {
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Not enough tokens!"), duration: Duration(milliseconds: 500)),
       );
     }
  }

  Widget _buildShopItem(BuildContext context,
      {required String name,
      required String description,
      required int cost,
      required bool isOwned,
      required VoidCallback onBuy}) {
    return Card(
      color: EcoTheme.cloudWhite,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: EcoTheme.getTextTheme().titleMedium),
                if (isOwned)
                  const Icon(Icons.check_circle, color: EcoTheme.sproutGreen)
                else
                   Row(
                    children: [
                      Image.asset('assets/images/ui/ui_icon_token.png', width: 16),
                      const SizedBox(width: 4),
                      Text('$cost'),
                    ],
                   )
              ],
            ),
            const SizedBox(height: 4),
            Text(description, style: EcoTheme.getTextTheme().bodyMedium),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOwned ? Colors.grey : EcoTheme.sproutGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: isOwned ? null : onBuy,
                child: Text(isOwned ? 'Owned' : 'Purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

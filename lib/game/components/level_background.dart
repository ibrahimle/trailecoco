import 'package:eco_trail/config/constants.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

class LevelBackground extends ParallaxComponent {
  final double baseSpeed;

  LevelBackground({required this.baseSpeed});

  @override
  Future<void> onLoad() async {
    // Determine layer speeds relative to base speed
    // Sky: Very slow (0.1x)
    // Mountains: Slow (0.2x)
    // Nature: Medium (0.5x)
    // Path: Base speed (1.0x) - matches gameplay speed

    parallax = await game.loadParallax(
      [
        ParallaxImageData(GameConstants.bgSky),
        ParallaxImageData(GameConstants.bgMountains),
        ParallaxImageData(GameConstants.bgNature),
        ParallaxImageData(GameConstants.bgPath),
      ],
      baseVelocity: Vector2(baseSpeed, 0),
      velocityMultiplierDelta: Vector2(1.0, 0),
      // We manually set multipliers to control depth perception precisely
    );
    
    // Set custom multipliers for depth effect
    // Note: layers are 0-indexed based on the list above
    parallax?.layers[0].velocityMultiplier = Vector2(0.1, 0); // Sky
    parallax?.layers[1].velocityMultiplier = Vector2(0.2, 0); // Mountains
    parallax?.layers[2].velocityMultiplier = Vector2(0.5, 0); // Nature
    parallax?.layers[3].velocityMultiplier = Vector2(1.0, 0); // Path
  }
}

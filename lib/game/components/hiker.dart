import 'package:eco_trail/game/components/flower.dart';
import 'package:eco_trail/game/components/trash_item.dart';
import 'package:eco_trail/game/eco_trail_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class Hiker extends SpriteAnimationComponent
    with CollisionCallbacks, DragCallbacks, HasGameReference<EcoTrailGame> {
  late SpriteAnimation _runAnimation;
  late SpriteAnimation _sitAnimation;

  // Drag movement state - simplified for smooth, stable dragging
  bool _isBeingDragged = false;
  late Vector2 _defaultPosition;

  Hiker({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Store default position for resetting on level restart
    _defaultPosition = position.clone();

    // Load Run Animation
    final runSprites = [
      await game.loadSprite('characters/char_hiker_run_1.png'),
      await game.loadSprite('characters/char_hiker_run_2.png'),
      await game.loadSprite('characters/char_hiker_run_3.png'),
      await game.loadSprite('characters/char_hiker_run_4.png'),
    ];

    _runAnimation = SpriteAnimation.spriteList(
      runSprites,
      stepTime: 0.15,
      loop: true,
    );

    // Load Sit Animation
    // Assuming sitting sprites exist or using a placeholder frame
    // For now using single sitting frame if animation not available
    final sitSprites = [
      await game.loadSprite('characters/char_hiker_sit_1.png'),
      // Add more if they exist, Phase 2 said "sit_1..4"
    ];

    _sitAnimation = SpriteAnimation.spriteList(
      sitSprites,
      stepTime: 0.5,
      loop: true,
    );

    animation = _runAnimation;

    // Add collision hitbox
    add(RectangleHitbox(
      size: size * 0.6,
      position: Vector2(size.x * 0.2, size.y * 0.2),
      anchor: Anchor.topLeft,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Skip movement updates in menu or when game is paused
    if (game.isMenu || game.isPaused || game.isGameOver || game.isLevelComplete) {
      return;
    }

    // Clamp position within playable bounds (in case of any drift)
    _clampPosition();
  }

  void _clampPosition() {
    final minX = size.x * 0.5;
    final maxX = game.size.x - size.x * 0.5;
    final minY = game.size.y * 0.2; // Top boundary
    final maxY = game.groundLevel; // Ground level

    position.x = position.x.clamp(minX, maxX);
    position.y = position.y.clamp(minY, maxY);
  }

  // --- Drag Callbacks ---
  // Dragging is smooth and stable: character stays where you drag it

  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    // Allow dragging only during active gameplay
    if (game.isMenu || game.isPaused || game.isGameOver || game.isLevelComplete) {
      return false;
    }
    _isBeingDragged = true;
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_isBeingDragged) return false;

    // Directly update position using drag delta for smooth, responsive dragging
    position += event.localDelta;
    
    // Immediately clamp to valid bounds
    _clampPosition();

    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isBeingDragged = false;
    // Character stays at the current position - no auto-return!
    return true;
  }

  @override
  bool onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _isBeingDragged = false;
    // Character stays at the current position - no auto-return!
    return true;
  }

  // --- Collision Callbacks ---

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // Skip collision handling in menu or when game is over
    if (game.isMenu || game.isGameOver || game.isLevelComplete) {
      return;
    }

    if (other is TrashItem) {
      // Hiker touched trash - trigger penalty
      game.onTrashCollision(other);
    } else if (other is Flower) {
      // Flower collision is handled by the Flower component itself
      // This is just for reference - flowers bloom on contact
    }
  }

  void run() {
    animation = _runAnimation;
  }

  void sit() {
    animation = _sitAnimation;
  }

  /// Reset hiker to default position (used when restarting level)
  void resetPosition() {
    _isBeingDragged = false;
    position = _defaultPosition.clone();
  }
}

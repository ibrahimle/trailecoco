import 'package:eco_trail/config/theme.dart';
import 'package:eco_trail/providers/player_progress_provider.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';

class JuicyButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Widget? icon;
  final bool isSecondary;

  const JuicyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = EcoTheme.sproutGreen,
    this.icon,
    this.isSecondary = false,
  });

  @override
  State<JuicyButton> createState() => _JuicyButtonState();
}

class _JuicyButtonState extends State<JuicyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    if (context.read<PlayerProgressProvider>().sfxEnabled) {
      FlameAudio.play(GameConstants.sfxButton);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSecondary ? Colors.white : widget.color,
            borderRadius: BorderRadius.circular(EcoTheme.buttonRadius),
            border: Border.all(
              color: EcoTheme.softCharcoal,
              width: EcoTheme.borderThin,
            ),
            boxShadow: const [
              BoxShadow(
                color: EcoTheme.softCharcoal,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Text(
                widget.label.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: widget.isSecondary ? EcoTheme.softCharcoal : EcoTheme.cloudWhite,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


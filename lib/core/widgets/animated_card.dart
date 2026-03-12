import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;
  final int animationIndex;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.radius = 16,
    this.animationIndex = 0,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: ()  => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color ??
                (isDark ? AppColors.darkCard : AppColors.surface),
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
            boxShadow: _pressed ? [] : [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 12, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.animationIndex * 60))
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.08, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}
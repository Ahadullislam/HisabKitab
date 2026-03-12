import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CategoryIcon extends StatelessWidget {
  final String emoji;
  final int colorValue;
  final double size;
  final bool elevated;

  const CategoryIcon({
    super.key,
    required this.emoji,
    required this.colorValue,
    this.size = 44,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: elevated ? [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 8, offset: const Offset(0, 3),
          ),
        ] : null,
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.45)),
      ),
    );
  }
}
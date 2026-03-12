import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 48)),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.06,
                duration: 2000.ms, curve: Curves.easeInOut),
            const SizedBox(height: 24),
            Text(title, style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ).animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, end: 0),
      ),
    );
  }
}
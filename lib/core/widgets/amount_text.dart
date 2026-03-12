import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../utils/currency_formatter.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final bool isIncome;
  final double fontSize;
  final bool showSign;
  final bool animate;

  const AmountText({
    super.key,
    required this.amount,
    this.isIncome = false,
    this.fontSize = 16,
    this.showSign = false,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? AppColors.income : AppColors.expense;
    final text  = showSign
        ? CurrencyFormatter.formatSigned(amount, isIncome: isIncome)
        : CurrencyFormatter.format(amount);

    Widget w = Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.3,
      ),
    );

    if (animate) {
      w = w.animate()
          .fadeIn(duration: 600.ms)
          .shimmer(duration: 1200.ms, color: color.withOpacity(0.3));
    }
    return w;
  }
}
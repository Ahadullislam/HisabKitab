import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';

class SummaryBar extends StatelessWidget {
  final double income;
  final double expense;

  const SummaryBar({
    super.key, required this.income, required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _item('💰', 'Income',
              income, AppColors.income, true)),
          Container(width: 1, height: 48,
              color: Colors.white.withOpacity(0.25)),
          Expanded(child: _item('💸', 'Expense',
              expense, AppColors.expense, false)),
          Container(width: 1, height: 48,
              color: Colors.white.withOpacity(0.25)),
          Expanded(child: _item('⚖️', 'Balance',
              income - expense,
              (income - expense) >= 0
                  ? Colors.white : Colors.red.shade200,
              (income - expense) >= 0)),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, duration: 500.ms,
        curve: Curves.easeOutCubic);
  }

  Widget _item(String emoji, String label,
      double amount, Color color, bool isPositive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(
            fontSize: 11, color: Colors.white70,
            fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        FittedBox(
          child: Text(
            CurrencyFormatter.formatCompact(amount.abs()),
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: label == 'Balance' ? Colors.white : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
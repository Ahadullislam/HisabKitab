import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';

class SavingsRateCard extends StatelessWidget {
  final double income;
  final double expense;
  final double savingsRate;

  const SavingsRateCard({
    super.key,
    required this.income,
    required this.expense,
    required this.savingsRate,
  });

  Color get _rateColor {
    if (savingsRate >= 0.3) return AppColors.income;
    if (savingsRate >= 0.1) return AppColors.warning;
    return AppColors.expense;
  }

  String get _rateLabel {
    if (savingsRate >= 0.3) return '🎉 Excellent!';
    if (savingsRate >= 0.2) return '👍 Good';
    if (savingsRate >= 0.1) return '⚠️ Fair';
    return '📉 Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          // Circular progress
          CircularPercentIndicator(
            radius:          58,
            lineWidth:       10,
            percent:         savingsRate,
            animation:       true,
            animationDuration: 1200,
            curve:           Curves.easeOutCubic,
            progressColor:   _rateColor,
            backgroundColor: _rateColor.withOpacity(0.12),
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(savingsRate * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _rateColor,
                  ),
                ),
                Text('saved',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Savings Rate',
                    style: AppTextStyles.headlineSmall),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _rateColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_rateLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _rateColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _row('Income', income, AppColors.income),
                const SizedBox(height: 6),
                _row('Expense', expense, AppColors.expense),
                const SizedBox(height: 6),
                _row('Saved',
                    income - expense,
                    (income - expense) >= 0
                        ? AppColors.income : AppColors.expense),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: 450.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.08, end: 0);
  }

  Widget _row(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          CurrencyFormatter.format(amount.abs()),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
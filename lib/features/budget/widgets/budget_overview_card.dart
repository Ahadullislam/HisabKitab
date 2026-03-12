import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../cubit/budget_cubit.dart';

class BudgetOverviewCard extends StatelessWidget {
  final BudgetLoaded state;

  const BudgetOverviewCard({super.key, required this.state});

  Color get _color {
    if (state.totalPercent >= 1.0) return AppColors.expense;
    if (state.totalPercent >= 0.8) return AppColors.warning;
    return AppColors.income;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3460), Color(0xFF1A56A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -20, top: -30,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    CircularPercentIndicator(
                      radius:     52,
                      lineWidth:  9,
                      percent:    state.totalPercent,
                      animation:  true,
                      animationDuration: 1000,
                      curve:      Curves.easeOutCubic,
                      progressColor:   _color,
                      backgroundColor: Colors.white24,
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(state.totalPercent * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text('used',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monthly Budget',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(
                                state.totalBudget),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _statRow('Spent',
                              state.totalSpent, Colors.redAccent.shade100),
                          const SizedBox(height: 4),
                          _statRow('Remaining',
                              (state.totalBudget - state.totalSpent)
                                  .clamp(0, double.infinity),
                              Colors.greenAccent),
                        ],
                      ),
                    ),
                  ],
                ),
                if (state.overspentCount > 0 ||
                    state.nearLimitCount  > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (state.overspentCount > 0)
                        _alertBadge(
                          '🚨',
                          '${state.overspentCount} Over Budget',
                          AppColors.expense,
                        ),
                      if (state.nearLimitCount > 0)
                        _alertBadge(
                          '⚠️',
                          '${state.nearLimitCount} Near Limit',
                          AppColors.warning,
                        ),
                      _alertBadge(
                        '📅',
                        '${state.activeBillCount} Active Bills',
                        Colors.lightBlueAccent,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.06, end: 0, duration: 600.ms,
        curve: Curves.easeOutCubic);
  }

  Widget _statRow(String label, double amount, Color color) {
    return Row(
      children: [
        Text(label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          CurrencyFormatter.formatCompact(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _alertBadge(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
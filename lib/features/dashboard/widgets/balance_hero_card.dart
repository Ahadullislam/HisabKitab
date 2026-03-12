import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class BalanceHeroCard extends StatelessWidget {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final DateTime month;

  const BalanceHeroCard({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final saving = monthlyIncome - monthlyExpense;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3460), Color(0xFF1A56A0), Color(0xFF2E75B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30, top: -30,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 40, bottom: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.format(totalBalance),
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormatter.shortMonth(month),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.15),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _statItem(
                        '💰', 'Income', monthlyIncome, Colors.greenAccent)),
                    Container(
                      width: 1, height: 40,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    Expanded(child: _statItem(
                        '💸', 'Expense', monthlyExpense,
                        Colors.redAccent.shade100)),
                    Container(
                      width: 1, height: 40,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    Expanded(child: _statItem(
                      saving >= 0 ? '📈' : '📉',
                      'Saved',
                      saving,
                      saving >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent.shade100,
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: -0.08, end: 0, duration: 600.ms,
        curve: Curves.easeOutCubic);
  }

  Widget _statItem(String emoji, String label,
      double amount, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          child: Text(
            CurrencyFormatter.formatCompact(amount.abs()),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
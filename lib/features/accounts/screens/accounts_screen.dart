import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/models/account_model.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AccountsView();
  }
}

class _AccountsView extends StatelessWidget {
  const _AccountsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Wallet'),
      body: ValueListenableBuilder(
        valueListenable:
        Hive.box<AccountModel>(HiveBoxes.accounts).listenable(),
        builder: (context, box, _) {
          final accounts = box.values.toList();
          final totalBalance =
          accounts.fold(0.0, (sum, a) => sum + a.balance);

          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('👛', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('No accounts found',
                      style: AppTextStyles.headlineSmall),
                ],
              ),
            );
          }

          return ListView(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // ── Total balance hero ──────────────────────────────
              _TotalBalanceCard(total: totalBalance),
              const SizedBox(height: 24),

              // ── Section header ──────────────────────────────────
              Text('Accounts', style: AppTextStyles.headlineSmall)
                  .animate()
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 12),

              // ── Account cards ───────────────────────────────────
              ...List.generate(accounts.length, (i) {
                final acc = accounts[i];
                return _AccountCard(account: acc, index: i);
              }),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

// ── Total Balance Hero Card ──────────────────────────────────────────
class _TotalBalanceCard extends StatelessWidget {
  final double total;
  const _TotalBalanceCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
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
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
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
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(total),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Across all your accounts',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: -0.06, end: 0, duration: 600.ms,
        curve: Curves.easeOutCubic);
  }
}

// ── Individual Account Card ──────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  final AccountModel account;
  final int index;

  const _AccountCard({required this.account, required this.index});

  String get _emoji {
    switch (account.type) {
      case AccountType.cash:  return '💵';
      case AccountType.bkash: return '📱';
      case AccountType.nagad: return '🟠';
      case AccountType.bank:  return '🏦';
    }
  }

  String get _typeLabel {
    switch (account.type) {
      case AccountType.cash:  return 'Cash';
      case AccountType.bkash: return 'Mobile Banking';
      case AccountType.nagad: return 'Mobile Banking';
      case AccountType.bank:  return 'Bank Account';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Color(account.colorValue);
    final txRepo = TransactionRepository();
    final now = DateTime.now();
    final monthIncome = txRepo
        .getByMonth(now.month, now.year)
        .where((t) => t.accountId == account.id && t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);
    final monthExpense = txRepo
        .getByMonth(now.month, now.year)
        .where((t) => t.accountId == account.id && t.isExpense)
        .fold(0.0, (s, t) => s + t.amount);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Top row
            Row(
              children: [
                // Icon circle
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(_emoji,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(account.name,
                              style: AppTextStyles.headlineSmall),
                          if (account.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Main',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(_typeLabel,
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                // Balance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Balance',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(account.balance),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: account.balance >= 0
                            ? AppColors.income
                            : AppColors.expense,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
            const SizedBox(height: 14),

            // This month stats
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: 'This Month In',
                    amount: monthIncome,
                    isIncome: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatChip(
                    label: 'This Month Out',
                    amount: monthExpense,
                    isIncome: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 + index * 80))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.06, end: 0, duration: 500.ms,
        curve: Curves.easeOutCubic);
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final double amount;
  final bool isIncome;

  const _StatChip({
    required this.label,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? AppColors.income : AppColors.expense;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.8),
              )),
          const SizedBox(height: 4),
          Text(
            '${isIncome ? '+' : '-'}${CurrencyFormatter.format(amount)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
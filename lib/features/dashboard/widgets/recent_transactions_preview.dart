import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/category_model.dart';

class RecentTransactionsPreview extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<CategoryModel>    categories;

  const RecentTransactionsPreview({
    super.key,
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions',
                    style: AppTextStyles.headlineSmall),
                TextButton(
                  onPressed: () => context.go(AppRouter.transactions),
                  child: const Text('See All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Text('📭',
                      style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text('No transactions yet',
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            )
          else
            ...List.generate(transactions.length, (i) {
              final tx  = transactions[i];
              final cat = categories.cast<CategoryModel?>()
                  .firstWhere((c) => c?.id == tx.categoryId,
                  orElse: () => null);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        CategoryIcon(
                          emoji: cat?.icon ?? '💰',
                          colorValue: cat?.colorValue ??
                              AppColors.primary.value,
                          size: 42,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(tx.title,
                                  style: AppTextStyles.labelLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(DateFormatter.relative(tx.date),
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Text(
                          '${tx.isIncome ? '+' : '-'}'
                              '${CurrencyFormatter.format(tx.amount)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: tx.isIncome
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ).animate(
                      delay: Duration(milliseconds: 500 + i * 60))
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.05, end: 0),
                  if (i < transactions.length - 1)
                    Divider(
                      indent: 72, endIndent: 16,
                      height: 1,
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.divider,
                    ),
                ],
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    )
        .animate(delay: 500.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.08, end: 0);
  }
}
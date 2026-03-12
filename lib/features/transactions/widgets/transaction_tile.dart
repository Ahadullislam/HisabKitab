import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/account_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel?   category;
  final AccountModel?    account;
  final VoidCallback?    onEdit;
  final VoidCallback?    onDelete;
  final int              index;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.category,
    this.account,
    this.onEdit,
    this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.isIncome;

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.42,
        children: [
          SlidableAction(
            onPressed: (_) { HapticFeedback.mediumImpact(); onEdit?.call(); },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: 'Edit',
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16)),
          ),
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.heavyImpact();
              _confirmDelete(context);
            },
            backgroundColor: AppColors.expense,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(16)),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              // Icon
              CategoryIcon(
                emoji: category?.icon ?? '💰',
                colorValue: category?.colorValue ??
                    AppColors.primary.value,
                size: 46,
                elevated: true,
              ),
              const SizedBox(width: 12),
              // Title + account
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.title,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 12, color: AppColors.textHint),
                        const SizedBox(width: 3),
                        Text(account?.name ?? '—',
                            style: AppTextStyles.bodySmall),
                        const SizedBox(width: 8),
                        Container(
                          width: 3, height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.textHint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(DateFormatter.relative(transaction.date),
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                    if (transaction.note.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(transaction.note,
                          style: AppTextStyles.bodySmall.copyWith(
                              fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isIncome
                          ? AppColors.income : AppColors.expense,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isIncome
                          ? AppColors.income : AppColors.expense)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isIncome ? 'Income' : 'Expense',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isIncome
                            ? AppColors.income : AppColors.expense,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.05, end: 0, duration: 400.ms,
        curve: Curves.easeOutCubic);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Transaction'),
        content: const Text(
            'Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expense),
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
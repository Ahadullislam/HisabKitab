import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/category_icon.dart';
import '../cubit/budget_cubit.dart';

class BudgetItemCard extends StatelessWidget {
  final BudgetItem   item;
  final int          index;
  final VoidCallback onSetBudget;
  final VoidCallback onDeleteBudget;

  const BudgetItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.onSetBudget,
    required this.onDeleteBudget,
  });

  Color get _barColor {
    if (item.isOverspent) return AppColors.expense;
    if (item.isNearLimit) return AppColors.warning;
    return AppColors.income;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onSetBudget();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isOverspent
                ? AppColors.expense.withOpacity(0.4)
                : item.isNearLimit
                ? AppColors.warning.withOpacity(0.4)
                : isDark
                ? AppColors.darkDivider
                : AppColors.divider,
            width: (item.isOverspent || item.isNearLimit) ? 1.5 : 1,
          ),
          boxShadow: item.isOverspent ? [
            BoxShadow(
              color: AppColors.expense.withOpacity(0.12),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                CategoryIcon(
                  emoji:      item.category.icon,
                  colorValue: item.category.colorValue,
                  size: 42,
                  elevated: item.hasBudget,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item.category.name,
                              style: AppTextStyles.labelLarge),
                          const Spacer(),
                          if (item.isOverspent)
                            _statusChip(
                                '🚨 Over Budget', AppColors.expense)
                          else if (item.isNearLimit)
                            _statusChip(
                                '⚠️ Near Limit', AppColors.warning)
                          else if (!item.hasBudget)
                              _statusChip(
                                  '+ Set Budget', AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (item.hasBudget)
                        Text(
                          '${CurrencyFormatter.format(item.spent)} '
                              'of ${CurrencyFormatter.format(item.budget!.limitAmount)}',
                          style: AppTextStyles.bodyMedium,
                        )
                      else
                        Text(
                          'Spent: ${CurrencyFormatter.format(item.spent)}',
                          style: AppTextStyles.bodyMedium,
                        ),
                    ],
                  ),
                ),
                if (item.hasBudget)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded,
                        color: AppColors.textHint, size: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onSelected: (val) {
                      if (val == 'edit')   onSetBudget();
                      if (val == 'delete') onDeleteBudget();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Budget'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_rounded,
                              size: 18, color: AppColors.expense),
                          SizedBox(width: 8),
                          Text('Remove Budget',
                              style: TextStyle(
                                  color: AppColors.expense)),
                        ]),
                      ),
                    ],
                  ),
              ],
            ),
            if (item.hasBudget) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: item.percent),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: _barColor.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(_barColor),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(item.percent * 100).toStringAsFixed(0)}% used',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _barColor,
                    ),
                  ),
                  Text(
                    'Remaining: ${CurrencyFormatter.format(
                        (item.budget!.limitAmount - item.spent)
                            .clamp(0, double.infinity))}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.06, end: 0, duration: 400.ms,
        curve: Curves.easeOutCubic);
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
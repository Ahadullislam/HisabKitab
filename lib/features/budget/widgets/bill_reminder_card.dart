import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/budget_model.dart';

class BillReminderCard extends StatelessWidget {
  final BillReminderModel bill;
  final int               index;
  final VoidCallback      onToggle;
  final VoidCallback      onDelete;
  final VoidCallback      onEdit;

  const BillReminderCard({
    super.key,
    required this.bill,
    required this.index,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  Color get _urgencyColor {
    if (bill.daysUntilDue <= 2) return AppColors.expense;
    if (bill.daysUntilDue <= 5) return AppColors.warning;
    return AppColors.income;
  }

  String get _urgencyLabel {
    if (bill.daysUntilDue == 0) return 'Due Today!';
    if (bill.daysUntilDue == 1) return 'Due Tomorrow!';
    if (bill.daysUntilDue <= 5) return 'Due in ${bill.daysUntilDue} days';
    return 'Due in ${bill.daysUntilDue} days';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = Color(bill.colorValue);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: bill.isActive && bill.daysUntilDue <= 2
              ? _urgencyColor.withOpacity(0.4)
              : isDark ? AppColors.darkDivider : AppColors.divider,
        ),
        boxShadow: bill.isActive && bill.daysUntilDue <= 2 ? [
          BoxShadow(
            color: _urgencyColor.withOpacity(0.12),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: bill.isActive ? 1.0 : 0.4,
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(bill.icon,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: bill.isActive ? 1.0 : 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(bill.title,
                            style: AppTextStyles.labelLarge),
                        const SizedBox(width: 8),
                        if (bill.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: _urgencyColor.withOpacity(0.1),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(_urgencyLabel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: _urgencyColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${CurrencyFormatter.format(bill.amount)}'
                          '  •  Every ${_ordinal(bill.dayOfMonth)} of month',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            // Toggle + menu
            Column(
              children: [
                Switch(
                  value:    bill.isActive,
                  onChanged: (_) {
                    HapticFeedback.selectionClick();
                    onToggle();
                  },
                  activeColor: AppColors.primary,
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded,
                      color: AppColors.textHint, size: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (val) {
                    if (val == 'edit')   onEdit();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_rounded,
                            size: 18, color: AppColors.expense),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(
                                color: AppColors.expense)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.05, end: 0, duration: 400.ms,
        curve: Curves.easeOutCubic);
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }
}
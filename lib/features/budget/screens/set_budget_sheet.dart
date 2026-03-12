import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../data/models/category_model.dart';
import '../cubit/budget_cubit.dart';

class SetBudgetSheet extends StatefulWidget {
  final BudgetItem item;
  const SetBudgetSheet({super.key, required this.item});

  @override
  State<SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends State<SetBudgetSheet> {
  final _ctrl    = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Quick-pick amounts
  final _quickAmounts = [500.0, 1000.0, 2000.0, 5000.0, 10000.0];

  @override
  void initState() {
    super.initState();
    if (widget.item.hasBudget) {
      _ctrl.text =
          widget.item.budget!.limitAmount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.item.category;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                CategoryIcon(
                  emoji:      cat.icon,
                  colorValue: cat.colorValue,
                  size: 52,
                  elevated: true,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.hasBudget
                        ? 'Edit Budget' : 'Set Budget',
                        style: AppTextStyles.headlineMedium),
                    Text(cat.name,
                        style: AppTextStyles.bodyMedium),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Spent info
            if (widget.item.spent > 0) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Already spent this month:',
                        style: AppTextStyles.bodyMedium),
                    Text(
                      '৳${widget.item.spent.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Amount input
            Text('Budget Limit', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller:   _ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.primary),
              decoration: const InputDecoration(
                prefixText: '৳  ',
                prefixStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                hintText: '0',
              ),
              autofocus: true,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Enter a budget limit';
                }
                if (double.tryParse(v) == null ||
                    double.parse(v) <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ).animate().fadeIn(duration: 300.ms)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: 16),

            // Quick pick
            Text('Quick Pick', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _quickAmounts.map((amount) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _ctrl.text = amount.toStringAsFixed(0);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      '৳${amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Save
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: () => _save(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  widget.item.hasBudget
                      ? 'Update Budget' : 'Set Budget',
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    context.read<BudgetCubit>().setBudget(
      widget.item.category.id,
      double.parse(_ctrl.text),
    );
    Navigator.pop(context);
  }
}
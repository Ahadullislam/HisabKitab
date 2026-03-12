import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/budget_model.dart';
import '../cubit/budget_cubit.dart';

class AddBillSheet extends StatefulWidget {
  final BillReminderModel? existing;
  const AddBillSheet({super.key, this.existing});

  @override
  State<AddBillSheet> createState() => _AddBillSheetState();
}

class _AddBillSheetState extends State<AddBillSheet> {
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _formKey    = GlobalKey<FormState>();
  int    _dayOfMonth = 1;
  String _selectedIcon  = '📄';
  int    _selectedColor = AppColors.catBills.value;

  final _billIcons = [
    ('⚡', 'Electricity',  AppColors.warning.value),
    ('🌐', 'Internet',     AppColors.primary.value),
    ('📱', 'Mobile',       AppColors.catMobile.value),
    ('🏠', 'Rent',         AppColors.catRent.value),
    ('💧', 'Water',        AppColors.catTransport.value),
    ('🔥', 'Gas',          AppColors.catOther.value),
    ('📺', 'Cable/OTT',    AppColors.catShopping.value),
    ('🏥', 'Insurance',    AppColors.catHealth.value),
    ('📄', 'Other',        AppColors.catOther.value),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final b          = widget.existing!;
      _titleCtrl.text  = b.title;
      _amountCtrl.text = b.amount.toStringAsFixed(0);
      _dayOfMonth      = b.dayOfMonth;
      _selectedIcon    = b.icon;
      _selectedColor   = b.colorValue;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
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
              Text(
                widget.existing != null
                    ? 'Edit Bill Reminder' : 'Add Bill Reminder',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 20),

              // Icon picker
              Text('Bill Type', style: AppTextStyles.labelLarge),
              const SizedBox(height: 10),
              SizedBox(
                height: 72,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _billIcons.length,
                  itemBuilder: (_, i) {
                    final (icon, label, color) = _billIcons[i];
                    final isSelected = _selectedIcon == icon;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedIcon  = icon;
                          _selectedColor = color;
                          if (_titleCtrl.text.isEmpty ||
                              _billIcons.any((b) =>
                              b.$2 == _titleCtrl.text)) {
                            _titleCtrl.text = label;
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(color).withOpacity(0.15)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? Color(color) : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(icon,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 2),
                            Text(label,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isSelected
                                    ? FontWeight.w700 : FontWeight.w400,
                                color: isSelected
                                    ? Color(color)
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text('Bill Name', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    hintText: 'e.g. Electricity Bill'),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),

              // Amount
              Text('Amount', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  prefixText: '৳  ',
                  hintText: '0',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Enter an amount';
                  }
                  if (double.tryParse(v) == null ||
                      double.parse(v) <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Day of month
              Text('Due Day (of every month)',
                  style: AppTextStyles.labelLarge),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Decrease
                  _dayButton(Icons.remove_rounded, () {
                    if (_dayOfMonth > 1) {
                      setState(() => _dayOfMonth--);
                    }
                  }),
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _ordinal(_dayOfMonth),
                          key: ValueKey(_dayOfMonth),
                          style: AppTextStyles.headlineMedium
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  // Increase
                  _dayButton(Icons.add_rounded, () {
                    if (_dayOfMonth < 28) {
                      setState(() => _dayOfMonth++);
                    }
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    widget.existing != null
                        ? 'Update Reminder' : 'Add Reminder',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    final bill = BillReminderModel(
      id:         widget.existing?.id,
      title:      _titleCtrl.text.trim(),
      amount:     double.parse(_amountCtrl.text),
      dayOfMonth: _dayOfMonth,
      colorValue: _selectedColor,
      icon:       _selectedIcon,
      categoryId: '',
      isActive:   widget.existing?.isActive ?? true,
    );

    context.read<BudgetCubit>().saveBill(bill);
    Navigator.pop(context);
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